close_distance_matrix <- function(x, frac = 0.95, norm=1){
  N <- dim(x)[1]
  kk <- min(20, max(floor(N/20), 2))
  ll <- max((kk-10), 1)

  x1 <- apply(x, 2, unitize_1)
  kinds1 <- FNN::knn.index(x1, kk)
  kinds11 <- kinds1[ ,ll:kk]

  x3 <- apply(x, 2, unitize_3)
  kinds3 <- FNN::knn.index(x3, kk)
  kinds33 <- kinds3[ ,ll:kk]

  st <- 1
  en <- kk
  v1 <- rep(1:N, each=dim(kinds11)[2])
  v2 <- as.vector(t(kinds11))
  pairs1 <- cbind(v1, v2)

  v1 <- rep(1:N, each=dim(kinds33)[2])
  v2 <- as.vector(t(kinds33))
  pairs3 <- cbind(v1, v2)

  pairs <- rbind(pairs1, pairs3)
  pairs <- unique(pairs)

  dout <- distance_pairs(x, pairs, norm)
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


distance_pairs <- function(x, ll, norm=1){
  ## ll is a list of pairs
  if(norm==1){
    x <- apply(x, 2, unitize_1)
  }else if(norm==2){
    x <- apply(x, 2, unitize_2)
  }else if(norm==3){
    x <- apply(x, 2, unitize_3)
  }

  first_pt <- ll[ ,1]
  second_pt <- ll[ ,2]
  dd <- (x[first_pt, ] - x[second_pt, ])^2
  sgn <- sign( (x[first_pt, ] - x[second_pt, ]) )
  out <- list()
  out$dist <- dd
  out$signs <- sgn
  return(out)
}

