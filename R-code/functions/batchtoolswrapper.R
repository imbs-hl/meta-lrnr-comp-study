#' Wrapper around typically batchMap() setup
#'
#' @title wrap_batchtools_R
#'
#' @param reg_name [char] Name of registry to load
#' @param r_function  [r object] Name of R function to run
#' @param vec_args [list] Vector to loop over
#' @param more_args [list] Static arguments, handed to more.args of \code{\link{batchtools:batchMap}}
#' @param overwrite [logical] TRUE deletes the registry to force re-execution of
#'     jobs, default is FALSE
#' @param memory [string] Set memory needed for batch job, example '8G'
#' @param packages [string vector] r string vector of package names that are required
#' @param work_dir [string] Working directory
#' @param reg_dir [string] Registry name
#' @param n_cpus [integer] Number of cpus
#' @param walltime [integer] Walltime
#' @param partition [string] Partition to be used
#' @param account [string] Account to be used
#' @param test_job [boolean] If TRUE, then test the first jobs only
#' @param wait_for_jobs [boolean] If TRUE, then wait for jobs
#' @param config_file [string] Path to the configuration file
#' @param name [string] Chunk name to appeared in swatch (SLURM)
#' @param sleep [integer] Parameter to control the duration to sleep between temporary errors.
#' @param interactive_session 
#'
#' @return Nothing, throws an error if not all jobs are finished 
wrap_batchtools <- function(reg_name,
                            name = "",
                            work_dir = getwd(),
                            reg_dir,
                            r_function,
                            vec_args,
                            more_args,
                            overwrite = FALSE,
                            memory = memory,
                            n_cpus = 1,
                            walltime = walltime,
                            sleep = 3,
                            partition = partition,
                            account = account,
                            test_job = FALSE,
                            wait_for_jobs = TRUE,
                            packages = character(0),
                            config_file,
                            interactive_session = FALSE){
  
  
  library(batchtools, quietly = TRUE)
  ## Delete registry if overwrite
  reg_abs <- file.path(reg_dir, reg_name)
  print(reg_abs)
  reg <- NULL
  if(overwrite) {
    if(file.exists(reg_abs)){
      unlink(reg_abs, recursive = TRUE)
    }
    ## create or load reg
    reg <- batchtools::makeRegistry(
      file.dir = reg_abs,
      work.dir = work_dir,
      conf.file = config_file,
      packages = packages)
  } else {
    reg <- batchtools::loadRegistry(
      file.dir = reg_abs,
      conf.file = config_file,
      writeable = TRUE
    )
  }
  
  
  ## Add jobs to map, if reg is empty
  if (nrow(batchtools::findJobs(reg = reg))) {
    ids <- batchtools::findJobs(reg = reg)
  } else {
    ## build job map
    message('Build job map')
    if(is.list(vec_args)){
      do.call(what = batchtools::batchMap,
              args = c(vec_args, list(reg = reg, fun = r_function,
                                      more.args = more_args
              )))
    } else {
      batchtools::batchMap(reg = reg,
                           fun = r_function,
                           vec_args,
                           more.args = more_args
      )
    }
  }
  if(test_job){
    batchtools::testJob(id = 1, reg = reg)
  } else {   
    ## submit unfinished jobs, i.e. for first run: all
    ids <- batchtools::findNotDone(reg = reg)
    if((nrow(ids) > 0) & (!interactive_session)){
      message(nrow(ids), ' jobs found, (re)submitting')
      ids[ , chunk := 1]
      batchtools::submitJobs(
        ids = ids, 
        resources = list(
          name = name,
          ntasks = 1, 
          ncpus = n_cpus, 
          memory = memory,
          account = account,
          walltime = walltime,
          partition = partition,
          chunks.as.arrayjobs = TRUE),
        reg = reg)
    } else {
      ## Submit jobs in interactive session
      batchtools::submitJobs(
        ids = ids, 
        resources = list(
          name = name,
          ntasks = 1, 
          ncpus = n_cpus, 
          memory = memory,
          walltime = walltime,
          sleep = sleep),
        reg = reg)
    }
    if(wait_for_jobs){
      wait <- batchtools::waitForJobs(reg = reg)
      if(!wait){
        warning('Jobs for registry ', reg_name, ' not completed')
      }
    }
  }
  return(reg)
}

