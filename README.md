
dobin
=====

[![Travis build status](https://travis-ci.org/sevvandi/dobin.svg?branch=master)](https://travis-ci.org/sevvandi/dobin)

The R package **dobin** constructs a set of basis vectors tailored for outlier detection as described in (Kandanaarachchi and Hyndman 2019).

Installation
------------

``` r
 install.packages("devtools")
 devtools::install_github("sevvandi/dobin")
```

Example
-------

A bimodal distribution in six dimensions, with 5 outliers in the middle. We consider 805 observations in six dimensions. Of these 805 observations, 800 observations are non-outliers; 400 observations are centred at (5, 0, 0, 0, 0, 0) and the other 400 centred at ( − 5, 0, 0, 0, 0, 0). The outlier distribution consists of 5 points with mean (0, 0, 0, 0, 0, 0) and standard deviations 0.2 in the first dimension and are similar to other observations in other dimensions.

``` r
library("dobin")
library("ggplot2")
set.seed(1)
# A bimodal distribution in six dimensions, with 5 outliers in the middle.
X <- data.frame(
   x1 = c(rnorm(400,mean=5), rnorm(5, mean=0, sd=0.2), rnorm(400, mean=-5)),
   x2 = rnorm(805),
   x3 = rnorm(805),
   x4 = rnorm(805),
   x5 = rnorm(805),
   x6 = rnorm(805)
)
labs <- c(rep("Norm",400), rep("Out",5), rep("Norm",400))
out <- dobin(X)
XX <- cbind.data.frame(out$coords[ ,1:2], as.factor(labs))
colnames(XX) <- c("DC1", "DC2", "labs" )
ggplot(XX, aes(DC1, DC2, color=labs)) + geom_point() + theme_bw()
```

![](man/figures/bimodal-1.png)

To compare, we perform PCA on the same dataset. The first two principal components are shown in the figure below:

``` r
library("dobin")
library("ggplot2")
set.seed(1)
# A bimodal distribution in six dimensions, with 5 outliers in the middle.
X <- data.frame(
   x1 = c(rnorm(400,mean=5), rnorm(5, mean=0, sd=0.2), rnorm(400, mean=-5)),
   x2 = rnorm(805),
   x3 = rnorm(805),
   x4 = rnorm(805),
   x5 = rnorm(805),
   x6 = rnorm(805)
)
labs <- c(rep("Norm",400), rep("Out",5), rep("Norm",400))
out <- prcomp(X, scale=TRUE)
XX <- cbind.data.frame(out$x[ ,1:2], as.factor(labs))
colnames(XX) <- c("PC1", "PC2", "labs" )
ggplot(XX, aes(PC1, PC2, color=labs)) + geom_point() + theme_bw()
```

![](man/figures/bimodal_pca-1.png)

References
==========

Kandanaarachchi, Sevvandi, and Rob J Hyndman. 2019. “Dimension Reduction for Outlier Detection Using Dobin.” Working Paper. <https://www.researchgate.net/publication/335568867_Dimension_reduction_for_outlier_detection_using_DOBIN>.
