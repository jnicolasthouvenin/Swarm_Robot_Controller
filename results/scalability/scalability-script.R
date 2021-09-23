
data <- read.csv("scalability-results.csv",header=T)

s <- split(data$RESULT, ceiling(seq_along(data$RESULT)/10))

names(s) <- c(2:20,60,100,125,150)

boxplot(s)