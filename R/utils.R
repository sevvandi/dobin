unitize_1 <- function(z) {
  # min-max normalization - 0 -1
  min.z <- min(z)
  max.z <- max(z)
  if ((max.z-min.z)==0)
    return(z)
  (z - min.z )/(max.z-min.z)
}


unitize_2 <- function(z) {
  # Mean and SD normalization
  mean.z <- mean(z)
  sd.z <- sd(z)
  #print(sd.z)
  if (sd.z==0)
    return(z)
  (z - mean.z )/sd.z
}


unitize_3 <- function(z) {
  # Median and IQR normalization
  median.z <- median(z)
  iqr.z <- IQR(z)
  if (iqr.z==0)
    return(z)
  (z - median.z )/iqr.z
}
