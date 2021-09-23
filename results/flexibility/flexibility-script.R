
data <- read.csv("flexibility-results.csv",header=T)

s <- split(data$RESULT, ceiling(seq_along(data$RESULT)/10))

names(s) <- c(1:4)

boxplot(s)