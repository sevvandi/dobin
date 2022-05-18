#' Computes a set of basis vectors for outlier detection.
#'
#' This function computes a set of basis vectors suitable for outlier detection.
#'
#' @param xx The input data in a dataframe, matrix or tibble format.
#' @param frac The cut-off quantile for \code{Y} space. Default is \code{0.95}.
#' @param norm The normalization technique. Default is Min-Max, which normalizes each column to values between 0 and 1. \code{norm = 0} skips normalization. Other values of norm defaults to Median-IQR normalization.
#' @param k Parameter \code{k} for k nearest neighbours with a default value of \code{5\%} of the number of observations with a cap of 20.
#'
#' @return A list with the following components:
#' \item{\code{rotation}}{The basis vectors suitable for outlier detection.}
#' \item{\code{coords}}{The dobin coordinates of the data \code{xx}. }
#' \item{\code{Yspace}}{The The associated \code{Y} space. }
#' \item{\code{Ypairs}}{The pairs in \code{xx} used to construct the \code{Y} space. }
#' \item{\code{zerosdcols}}{Columns in \code{xx} with zero standard deviation. This is computed only if the number of columns are greater than the number of rows. }
#'
#' @examples
#' # A bimodal distribution in six dimensions, with 5 outliers in the middle.
#' set.seed(1)
#' x2 <- rnorm(405)
#' x3 <- rnorm(405)
#' x4 <- rnorm(405)
#' x5 <- rnorm(405)
#' x6 <- rnorm(405)
#' x1_1 <- rnorm(mean = 5, 400)
#' mu2 <-  0
#' x1_2 <- rnorm(5, mean=mu2, sd=0.2)
#' x1 <- c(x1_1, x1_2)
#' X1 <- cbind(x1,x2,x3,x4,x5,x6)
#' X2 <- cbind(-1*x1_1,x2[1:400],x3[1:400],x4[1:400],x5[1:400],x6[1:400])
#' X <- rbind(X1, X2)
#' labs <- c(rep(0,400), rep(1,5), rep(0,400))
#' dob <- dobin(X)
#' autoplot(dob)
#'
#'
#' @export dobin
#' @importFrom stats prcomp quantile sd median IQR


dobin <- function(xx, frac=0.95, norm=1, k=NULL){

  # check if xx is numeric
  isnum <- apply(xx, 2, is.numeric)
  if(sum(isnum) != NCOL(xx)){
    stop("DOBIN applies only to numerical variables.")
  }

  # check for rows with NAs and remove
  isna <- apply(xx, 1, function(x) sum(is.na(x)))
  inds <- which(isna > 0)
  if(length(inds) > 0){
    cat("\nRemoving NA rows. Row number:", inds)
    xx <- xx[-inds, ]
  }


  if(norm==1){
    x1 <- apply(xx, 2, unitize_1)
  }else if(norm == 0){
    x1 <- xx # do not normalize
  }else{
    x1 <- apply(xx, 2, unitize_3)
  }

  if(dim(xx)[1] < dim(xx)[2]){
    # More dimensions than observations
    # N points can span an N-dimensional subspace
    # So change of basis to this subspace

    sd_cols <- apply(x1, 2, sd)
    inds <- which(sd_cols==0)
    if(length(inds)>0){
      x1 <- x1[ ,-inds]
    }else{
      inds <- NA
    }

    pcax <- prcomp(x1, scale=FALSE, center=TRUE)
    x <- pcax$x
    v1 <- pcax$rotation
  }else{
    x <- x1
    v1 <- NA
    inds <- NA
  }


  n <- dim(x)[2]
  vec <- matrix(0, nrow = n, ncol = n)

  # store x in xb
  xb <- x

  for(i in 1:(n-1)){
    # Compute Y space
    Yout <- close_distance_matrix(x, frac, k)
    Y <- Yout$y
    Ysigns <- Yout$signs
    # Find eta
    w <- colSums(Y)
    eta <- w/sqrt(sum(w^2))



    # Update basis
    if(i==1){
      vec[ ,1] <- eta
    }else{
      vec[ ,i] <- B %*% eta
    }
    # Find xperp
    xperp <- x - x %*% eta %*% t(eta)
    # Find a basis B for xperp
    B1 <- pracma::nullspace(t(as.vector(eta))) #pracma::nullspace(t(vec[ ,1:i]))
    # Change xperp coordinates to B basis
    # new x is one dimension less than the previous x
    x <- xperp %*% B1

    # Update B with B1 - because each time 1 dimension is reduced
    if(i==1){
      B <- B1
    }else{
      B <- B %*% B1
    }
  }
  # Find the last basis vector
  vec[ ,n] <- pracma::nullspace(t(vec[ ,1:(n-1)]))

  coords <- xb %*% vec


  structure(list(
    rotation = vec,
    coords = coords,
    Yspace = Y,
    Ypairs = Yout$pairs,
    zerosdcols = inds,
    call = match.call()
  ), class='dobin')
}
