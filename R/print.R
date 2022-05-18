#' @method print dobin
#' @export

print.dobin <- function(x, ...) {

  cat("Dimension reduction using dobin algorithm")
  cat("\n\nCall: ")
  print(x$call)
  cat("\ndobin basis vectors\n")
  print(x$rotation)
  cat("\ndobin coordinates\n")
  print(x$coords)
}
