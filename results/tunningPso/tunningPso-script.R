
data.5.0.0 <- read.csv("trace/5-0-100-13-1.dat",header=F)[,1][5:105]
data.5.1.0 <- read.csv("trace/5-1-100-13-1.dat",header=F)[,1][5:105]
data.5.2.0 <- read.csv("trace/5-2-100-13-1.dat",header=F)[,1][5:105]

data.5.0.1 <- read.csv("trace/5-0-100-13-2.dat",header=F)[,1][5:105]
data.5.1.1 <- read.csv("trace/5-1-100-13-2.dat",header=F)[,1][5:105]
data.5.2.1 <- read.csv("trace/5-2-100-13-2.dat",header=F)[,1][5:105]

data.5.0 <- c(data.5.0.0,data.5.0.1)
data.5.1 <- c(data.5.1.0,data.5.1.1)
data.5.2 <- c(data.5.2.0,data.5.2.1)

data.10.0.0 <- read.csv("trace/10-0-100-13-1.dat",header=F)[,1][10:110]
data.10.1.0 <- read.csv("trace/10-1-100-13-1.dat",header=F)[,1][10:110]
data.10.2.0 <- read.csv("trace/10-2-100-13-1.dat",header=F)[,1][10:110]

data.10.0.1 <- read.csv("trace/10-0-100-13-2.dat",header=F)[,1][10:110]
data.10.1.1 <- read.csv("trace/10-1-100-13-2.dat",header=F)[,1][10:110]
data.10.2.1 <- read.csv("trace/10-2-100-13-2.dat",header=F)[,1][10:110]

data.10.0 <- c(data.10.0.0,data.10.0.1)
data.10.1 <- c(data.10.1.0,data.10.1.1)
data.10.2 <- c(data.10.2.0,data.10.2.1)

data.15.0.0 <- read.csv("trace/15-0-100-13-1.dat",header=F)[,1][15:115]
data.15.1.0 <- read.csv("trace/15-1-100-13-1.dat",header=F)[,1][15:115]
data.15.2.0 <- read.csv("trace/15-2-100-13-1.dat",header=F)[,1][15:115]

data.15.0.1 <- read.csv("trace/15-0-100-13-2.dat",header=F)[,1][15:115]
data.15.1.1 <- read.csv("trace/15-1-100-13-2.dat",header=F)[,1][15:115]
data.15.2.1 <- read.csv("trace/15-2-100-13-2.dat",header=F)[,1][15:115]

data.15.0 <- c(data.15.0.0,data.15.0.1)
data.15.1 <- c(data.15.1.0,data.15.1.1)
data.15.2 <- c(data.15.2.0,data.15.2.1)

data.20.0.0 <- read.csv("trace/20-0-100-13-1.dat",header=F)[,1][20:120]
data.20.1.0 <- read.csv("trace/20-1-100-13-1.dat",header=F)[,1][20:120]
data.20.2.0 <- read.csv("trace/20-2-100-13-1.dat",header=F)[,1][20:120]

data.20.0.1 <- read.csv("trace/20-0-100-13-2.dat",header=F)[,1][20:120]
data.20.1.1 <- read.csv("trace/20-1-100-13-2.dat",header=F)[,1][20:120]
data.20.2.1 <- read.csv("trace/20-2-100-13-2.dat",header=F)[,1][20:120]

data.20.0 <- c(data.20.0.0,data.20.0.1)
data.20.1 <- c(data.20.1.0,data.20.1.1)
data.20.2 <- c(data.20.2.0,data.20.2.1)

data <- data.frame(data.5.0,data.5.1,data.5.2,
                   data.10.0,data.10.1,data.10.2,
                   data.15.0,data.15.1,data.15.2,
                   data.20.0,data.20.1,data.20.2)

boxplot(data)