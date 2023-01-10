# time (t)
x <- c(0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20)
# Algae cell counts (per ml)
y <- c(0.88, 1.02, 1.43, 2.79, 4.61, 7.12,
       6.47, 8.16, 7.28, 5.67, 6.91) * 1e6

## rescale data to common range between 1e-3 ... 1e3
## to help numerical algorithms
## this is exactly what we usually do with measured quantities
## if we apply unit prefixes like micro, milli, kilo, mega ... and so on
yy <- y * 1e-6

## we now plot the data linearly and logarithmically
## the layout function is another way to subdivide the plotting area
nf <- layout(matrix(c(1,2,3,3), 2, 2, byrow = TRUE), respect = TRUE)
layout.show(nf) # this shows how the plotting area is subdivided

plot(x, yy)
plot(x, log(yy))

## we see that the first points show the steepest increase,
## so we can estimate a start value of the growth rate
r <- (log(yy[5]) - log(yy[1])) / (x[5] - x[1])
abline(a=log(yy[1]), b=r)

## this way, we have a heuristics for all start parameters:
## r:  steepest increase of y in log scale
## K:  maximum value
## N0: first value

## we can check this by plotting the function with the start values
f <- function(x, r, K, N0) {K /(1 + (K/N0 - 1) * exp(-r *x))}
plot(x, yy, pch=16, xlab="time (days)", ylab="algae (Mio cells)")
lines(x, f(x, r=r, K=max(yy), N0=yy[1]), col="blue")

pstart <- c(r=r, K=max(yy), N0=yy[1])
model_fit   <- nls(yy ~ f(x, r, K,N0), start = pstart, trace=TRUE)

x1 <- seq(0, 25, length = 100)
lines(x1, predict(model_fit, data.frame(x = x1)), col = "red")
legend("topleft",
       legend = c("data", "start", "fitted"),
       col = c("black", "blue", "red"),
       lty = c(0, 1, 1),
       pch = c(16, NA, NA))

summary(model_fit)
(Rsquared <- 1 - var(residuals(model_fit))/var(yy))



## =============================================================================
## Approach with Baranyi-Roberts model
## =============================================================================


baranyi <- function(x, r, K, N0, h0) {
  A <- x + 1/r * log(exp(-r * x) + exp(-h0) - exp(-r * x - h0))
  y <- exp(log(N0) + r * A - log(1 + (exp(r * A) - 1)/exp(log(K) - log(N0))))
  y
}

pstart <- c(r=0.5, K=7, N0=1, h0=2)
fit2   <- nls(yy ~ baranyi(x, r, K, N0, h0), start = pstart, trace=TRUE)

lines(x1, predict(fit2, data.frame(x = x1)), col = "forestgreen", lwd=2)

legend("topleft",
       legend = c("data", "logistic", "Baranyi-Roberts"),
       col = c("black", "red", "forestgreen"),
       lty = c(0, 1, 1),
       pch = c(16, NA, NA))


## =============================================================================
## Approach with R package "growthrates"
## see documentation at:
##     https://tpetzoldt.github.io/growthrates/doc/Introduction.html
## =============================================================================

library(growthrates)

## The "easy linear" method finds the steepest linear increase.
## It  is a fully automatic method employing linear regression and a search
## routine. Details and publication is found in ?fit_easylinear
fit1 <- fit_easylinear(x, yy)
plot(fit1, main="linear scale")
plot(fit1, log="y", main="log scale")
coef(fit1)

## "fit_growthmodel" performs nonlinear regression, but has some additional
## features built-in.
pstart <- c(mumax=r, K=max(yy), y0=yy[1])
fit2 <- fit_growthmodel(grow_logistic, p=pstart, time=x, y=yy)
plot(fit2)

## The model fits not very well at the beginning because we see a clear lag
## phase. Therefore, we need to use an extended model e.g. the Baranyi model.

## It has an additional parameter "h0" for which a start value can be derived
## from mumax and lag, more: see help file ?grow_baranyi

coef(fit1)
h0 <- 0.25 * 1.66

pstart <- c(mumax=0.5, K=max(yy), y0=yy[1], h0=h0)
fit3 <- fit_growthmodel(grow_baranyi, p=pstart, time=x, y=yy)
lines(fit3, col="magenta")
summary(fit3)

legend("topleft",
       legend = c("data", "logistic", "Baranyi"),
       col = c("red", "blue", "magenta"),
       lty = c(0, 1, 1),
       pch = c(16, NA, NA))
