# ------------------------------------------------------------------------------
# https://en.wikipedia.org/wiki/Generalised_logistic_function
# A: the lower asymptote;
# K: the upper asymptote when C=1;
# B: the growth rate;
# n >0 : affects near which asymptote maximum growth occurs;
# Q: is related to the value Y(0);
# C: typically takes a value of 1;
sigmoid = function(A = 0,
                   K = 1,
                   C = 1,
                   Q = 1,
                   B = 1,
                   n = 1,
                   x) {
  y <- A + (K - A) / (C + Q * exp(-B * x)) ^ (1 / n)
  return(y)
}

add.growth <- function(data, B, A, K, Q, n = 1) {
  data <- data %>%
    mutate(growth = sigmoid(
      x = x,
      B = B,
      A = A,
      K = K,
      Q = Q
    ))
  return(data)
}

add.dau <- function(data, start) {
  #daily active users
  data <- data %>%
    mutate(dau = start * (1 + lag(growth, default = 0)))
  return(data)
}

add.margin <- function(data, cmu) {
  data <- data %>%
    mutate(margin = -0.5 * (dau <= cmu) + 0.8 * (dau > cmu))
  
  return(data)
}

add.daily.rev <- function(data) {
  data <- data %>%
    mutate(daily.rev = -abs(daily.CoR) / (margin - 1))
  return(data)
}

add.daily.gross.profit <- function(data) {
  data <- data %>%
    mutate(daily.gross.profit = daily.rev + daily.CoR)
  return(data)
}

add.gp.running.sum <- function(data) {
  data <- data %>%
    mutate(gp.running.sum = cumsum(daily.gross.profit))
  return(data)
}