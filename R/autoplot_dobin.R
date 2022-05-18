#' Plots the first two components of the dobin space.
#'
#' Scatterplot of the first two columns in the dobin space.
#'
#' @param object The output of the function `dobin`.
#' @param ... Other arguments currently ignored.
#'
#' @return A ggplot object.
#'
#' @examples
#' X <- rbind(
#'   data.frame(x = rnorm(500),
#'              y = rnorm(500),
#'              z = rnorm(500)),
#'   data.frame(x = rnorm(5, mean = 10, sd = 0.2),
#'              y = rnorm(5, mean = 10, sd = 0.2),
#'              z = rnorm(5, mean = 10, sd = 0.2))
#' )
#' dob <- dobin(X)
#' autoplot(dob)
#' @export
autoplot.dobin <- function(object, ...) {
  X <- as.data.frame(object$coords)
  p <- ggplot2::ggplot(X, ggplot2::aes(x=X[ ,1], y=X[ ,2])) +
    ggplot2::geom_point() +
    ggplot2::xlab("DB1") +
    ggplot2::ylab("DB2")
  p
}
