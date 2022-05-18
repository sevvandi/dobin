close_distance_matrix <- function(x, frac = 0.95, k){
  N <- dim(x)[1]
  if(is.null(k)){
    kk <- min(20, max(floor(N/20), 2))
  }else{
    kk <- k
  }

  ll <- 1

  nn_obj <- dbscan::kNN(x, k=kk)
  kinds1 <- nn_obj$id
  kinds11 <- kinds1[ ,ll:kk]

  st <- 1
  en <- kk
  v1 <- rep(1:N, each=dim(kinds11)[2])
  v2 <- as.vector(t(kinds11))
  pairs <- cbind(v1, v2)

  dout <- distance_pairs(x, pairs)
  y <- dout$dist
  y_rowsum <- apply(y, 1, sum)
  qfrac <- quantile(y_rowsum, prob=frac)
  inds <- which(y_rowsum <= qfrac)


  out <- list()
  out$y <- y[-inds, ]
  out$pairs <- pairs[-inds, ]
  out$signs <- dout$signs[-inds, ]
  return(out)
}


distance_pairs <- function(x, ll){
  ## ll is a list of pairs

  first_pt <- ll[ ,1]
  second_pt <- ll[ ,2]
  dd <- (x[first_pt, ] - x[second_pt, ])^2
  sgn <- sign( (x[first_pt, ] - x[second_pt, ]) )
  out <- list()
  out$dist <- dd
  out$signs <- sgn
  return(out)
}


