## See the batchtools package for more details about how to configure this file.
## https://mllg.github.io/batchtools/articles/batchtools.html#configuration-file-1
makeClusterFunctionsSlurm <- function (template = "slurm",
                                       clusters = NULL,
                                       array.jobs = TRUE, 
                                       nodename = "localhost",
                                       scheduler.latency = 1,
                                       fs.latency = 65) 
{
  if (!is.null(clusters)) 
    assertString(clusters, min.chars = 1L)
  assertFlag(array.jobs)
  assertString(nodename)
  template = findTemplateFile(template)
  template = cfReadBrewTemplate(template, "##")
  submitJob = function(reg, jc) {
    assertRegistry(reg, writeable = TRUE)
    assertClass(jc, "JobCollection")
    jc$clusters = clusters
    if (jc$array.jobs) {
      logs = sprintf("%s_%i", fs::path_file(jc$log.file), 
                     seq_row(jc$jobs))
      jc$log.file = stri_join(jc$log.file, "_%a")
    }
    outfile = cfBrewTemplate(reg, template, jc)
    res = runOSCommand("sbatch", shQuote(outfile), nodename = nodename)
    output = stri_flatten(stri_trim_both(res$output), "\n")
    if (res$exit.code > 0L) {
      temp.errors = c("Batch job submission failed: Job violates accounting policy (job submit limit, user's size and/or time limits)", 
                      "Socket timed out on send/recv operation", "Submission rate too high, suggest using job arrays")
      i = wf(stri_detect_fixed(output, temp.errors))
      if (length(i) == 1L) 
        return(makeSubmitJobResult(status = i, batch.id = NA_character_, 
                                   msg = temp.errors[i]))
      return(cfHandleUnknownSubmitError("sbatch", res$exit.code, 
                                        res$output))
    }
    id = stri_split_fixed(output[1L], " ")[[1L]][4L]
    if (jc$array.jobs) {
      if (!array.jobs) 
        stop("Array jobs not supported by cluster function")
      makeSubmitJobResult(status = 0L,
                          batch.id = sprintf("%s_%i", 
                                                          id, seq_row(jc$jobs)),
                          log.file = logs)
    }
    else {
      makeSubmitJobResult(status = 0L, batch.id = id)
    }
  }
  listJobs = function(reg, args) {
    assertRegistry(reg, writeable = FALSE)
    if (array.jobs) 
      args = c(args, "-r")
    res = runOSCommand("squeue", args, nodename = nodename)
    if (res$exit.code > 0L) 
      OSError("Listing of jobs failed", res)
    if (!is.null(clusters)) 
      tail(res$output, -1L)
    else res$output
  }
  listJobsQueued = function(reg) {
    args = c("-h", "-o %i", shQuote("-u $USER"), "-t PD", 
             sprintf("--clusters=%s", clusters))
    listJobs(reg, args)
  }
  listJobsRunning = function(reg) {
    args = c("-h", "-o %i", shQuote("-u $USER"), "-t R,S,CG", 
             sprintf("--clusters=%s", clusters))
    listJobs(reg, args)
  }
  killJob = function(reg, batch.id) {
    assertRegistry(reg, writeable = TRUE)
    assertString(batch.id)
    cfKillJob(reg, "scancel", c(sprintf("--clusters=%s", 
                                        clusters), batch.id),
              nodename = nodename)
  }
  removeResultFiles <- function(reg, updates, cache, ...) {
    if (length(updates$job.id)) {
      result_files <- batchtools:::getResultFiles(reg = reg,
                                                  ids = updates$job.id)
      #file.remove(result_files)
    }
  }
  makeClusterFunctions(name = "Slurm", submitJob = submitJob, 
                       killJob = killJob, listJobsRunning = listJobsRunning, 
                       listJobsQueued = listJobsQueued,
                       array.var = "SLURM_ARRAY_TASK_ID", 
                       store.job.collection = TRUE,
                       store.job.files = !isLocalHost(nodename), 
                       scheduler.latency = scheduler.latency,
                       fs.latency = fs.latency,
                       hooks = list(post.do.collection = removeResultFiles))
}

cluster.functions = makeClusterFunctionsSlurm(template = template,
                                              nodename = nodename)
sleep = 3
default.resources = list(ntasks = 1, ncpus = 1,
                         memory = 6000, partition = partition,
                         chunks.as.arrayjobs = TRUE)