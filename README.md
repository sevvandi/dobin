
dobin
=====

[![Travis build status](https://travis-ci.org/sevvandi/dobin.svg?branch=master)](https://travis-ci.org/sevvandi/dobin)

Installation
------------

``` r
# install.packages("devtools")
# devtools::install_github("sevvandik/dobin")
```

Example
-------

A bimodal distribution in six dimensions, with 5 outliers in the middle. We consider 805 observations in six dimensions. Of these 805 observations, 800 observations are non-outliers; 400 observations are centred at (5, 0, 0, 0, 0, 0) and the other 400 centred at ( − 5, 0, 0, 0, 0, 0). The outlier distribution consists of 5 points with mean (0, 0, 0, 0, 0, 0) and standard deviations 0.2 in the first dimension and are similar to other observations in other dimensions.

``` r
library("dobin")
set.seed(1)
x2 <- rnorm(405)
x3 <- rnorm(405)
x4 <- rnorm(405)
x5 <- rnorm(405)
x6 <- rnorm(405)
x1_1 <- rnorm(mean = 5, 400)
mu2 <-  0
x1_2 <- rnorm(5, mean=mu2, sd=0.2)
x1 <- c(x1_1, x1_2)
X1 <- cbind(x1,x2,x3,x4,x5,x6)
X2 <- cbind(-1*x1_1,x2[1:400],x3[1:400],x4[1:400],x5[1:400],x6[1:400])
X <- rbind(X1, X2)
labs <- c(rep(0,400), rep(1,5), rep(0,400))
out <- dobin(X)
plot(out$coords[ , 1:2], col=as.factor(labs), pch=20)
```

![](README_files/figure-markdown_github/bimodal-1.png)
