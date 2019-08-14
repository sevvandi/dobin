#' Computes a set of basis vectors for outlier detection.
#'
#' This function computes a set of basis vectors suitable for outlier detection.
#'
#' @param xx The input data in a dataframe, matrix or tibble format.
#' @param frac The cut-off quantile for \code{Y} space. Default is \code{0.95}.
#' @param norm The normalization technique. Default is Median-IQR, which normalizes each column of meidan \code{0} and IQR {1}.
#' @param vis If visualization is an aim of the exercise, certain adjustments are made.
#'
#' @return A list with the following components:
#' \item{\code{vec}}{The basis vectors suitable for outlier detection.}
#' \item{\code{coords}}{The dobin coordinates of the data \code{xx}. }
#' \item{\code{Y}}{The The associated \code{Y} space. }
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
#' out <- dobin(X)
#' plot(out$coords[ , 1:2], col=as.factor(labs), pch=20)
#'
#'
#' @export dobin
#' @importFrom stats prcomp quantile sd median IQR


dobin <- function(xx, frac=0.95, norm=1, vis=TRUE){

  if(dim(xx)[1] < dim(xx)[2]){
    # More dimensions than observations
    # N points can span an N-dimensional subspace
    # So change of basis to this subspace
    if(norm==1){
      x1 <- apply(xx, 2, unitize_1)
    }else{
      x1 <- apply(xx, 2, unitize_3)
    }
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
    x <- xx
    v1 <- NA
    inds <- NA
  }

  Yout <- close_distance_matrix(x, frac, norm)
  Y <- Yout$y
  Ysigns <- Yout$signs
  Z <- Y
  n <- dim(Y)[2]
  vec <- matrix(0, nrow = n, ncol = n)

  for(i in 1:n){
    if(i==1){
      w <- colSums(Z)
      signed_y <- Z*Ysigns
      signs <- sign(colSums(signed_y))
    }else if(i==n){
      perpvec <- pracma::nullspace(t(vec[ ,1:i]))
      w <- perpvec
    }else{
      perpvec <- pracma::nullspace(t(vec[ ,1:i]))
      Z  <- Z - Z %*% w %*% t(w)
      M <- Z %*% perpvec
      M_min <- apply(M, 2, min)
      M2 <- sweep(M, 2, M_min)
      w0 <- colSums(M2)
      w0 <- w0/sqrt(sum(w0^2))
      w <- perpvec%*%w0
    }

    w <- w/sqrt(sum(w^2))
    vec[ ,i] <- w
  }
  if(norm==1){
    Xu <- apply(x, 2, unitize_1)
  }else{
    Xu <- apply(x, 2, unitize_3)
  }
  if(vis){
    Xvec <- diag(signs) %*% vec
  }else{
    Xvec <- vec
  }


  coords <- Xu %*% Xvec
  out <- list()
  out$vec <- Xvec
  out$coords <- coords
  out$Y <- Y
  out$Ypairs <- Yout$pairs
  out$zerosdcols <- inds
  return(out)
}
