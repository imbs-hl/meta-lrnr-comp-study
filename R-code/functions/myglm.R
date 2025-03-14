# =============================
# Wrap a new log. reg. learner
# =============================
#
myglm <- function (x, y) {
  y = as.integer(y == 1)
  data <- as.data.frame(x = x)
  data$y <- y
  glm_model <- glm(y ~ ., data = data, family = binomial())
  glm_model <- list(model = glm_model)
  class(glm_model) <- "myglm"
  return(glm_model)
}

predict.myglm <- function(object, data) {
  tmp <- predict(object = object$model,
                 newdata = as.data.frame(data), type = "response")
  return(as.vector(tmp))
}