## =============================================================================
## generate a multimodal distribution in 3D and rotate it somewhat
## =============================================================================

library("mvtnorm")

#library("mvMonitoring")
## simplified version adapted from package "mvMonitoring",
## License was GPL-2 (2021-01-26)
rotate3D <- function (yaw, pitch, roll) {
  thetaX <- roll * pi/180
  thetaY <- pitch * pi/180
  thetaZ <- yaw * pi/180
  Rx <- c(1, 0, 0, 0, cos(thetaX), -sin(thetaX), 0, sin(thetaX), cos(thetaX))
  Rx <- matrix(Rx, ncol = 3, nrow = 3)
  Ry <- c(cos(thetaY), 0, sin(thetaY), 0, 1, 0, -sin(thetaY), 0, cos(thetaY))
  Ry <- matrix(Ry, ncol = 3, nrow = 3)
  Rz <- c(cos(thetaZ), -sin(thetaZ), 0, sin(thetaZ), cos(thetaZ), 0, 0, 0, 1)
  Rz <- matrix(Rz, ncol = 3, nrow = 3)
  Rz %*% Ry %*% Rx
}

set.seed(789)
ndim     <- 3
nsamp    <- 50
effect   <- 2 #3
mycolors <- rep(c("#e41a1c", "#377eb8", "#4daf4a"), each = nsamp)

## Create a valid variance matrix (positive semidefinite)
## https://stats.stackexchange.com/questions/215497/how-to-create-an-arbitrary-covariance-matrix
p <- qr.Q(qr(matrix(rnorm(ndim^2), ndim)))
sigma <- crossprod(p, p*(ndim:1))

## Generate 3 clusters of random data
A <- rbind(
  rmvnorm(n = nsamp, mean = rep(-effect, 3), sigma = sigma),
  rmvnorm(n = nsamp, mean = rep(      0, 3), sigma = sigma),
  rmvnorm(n = nsamp, mean = rep(+effect, 3), sigma = sigma)
)

## rotate data matrix by 45 degrees so that clusters are not yet too obvious

## set rotation angle and generate rotation matrix
r <- rotate3D(0, 45, 45)

## apply rotation matrix
A1 <- A %*% r

## scale data and add a constant
#A1 <- scale(A1) + 3

## name columns
A1 <- as.data.frame(A1)
names(A1) <- c("x", "y", "z")

## Visualization and check of the data

#par(mfrow=c(1,3))
#plot(y ~ x, data=A1, col=mycolors)
#plot(y ~ z, data=A1, col=mycolors)
#plot(z ~ x, data=A1, col=mycolors)

#pc <- prcomp(A1)
#plot(pc)

write.csv(A1, file="multivar.csv", row.names = FALSE, quote = FALSE)
