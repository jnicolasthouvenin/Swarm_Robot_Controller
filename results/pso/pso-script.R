
data <- read.csv("psoResults.csv",header=T)

s <- split(data$ARGOS_SOL, ceiling(seq_along(data$ARGOS_SOL)/30))

names(s) <- c(1:10)

boxplot(s)
s = unname(s)

for (i in 1:10) {
    print(mean(unlist(s[i])))
}

chosenSolNum = 8

output = "pso-wt.txt"

test = wilcox.test(c(1,2),c(3,4))

write(paste("\nMethod:    ",test$method,sep=""), file=output, append=FALSE)

for (solNum in 1:10) {
    if (solNum != chosenSolNum) {
        chosenSol = unlist(s[chosenSolNum])
        sol = unlist(s[solNum])
        test = wilcox.test(chosenSol,sol)

        write(paste("\nData:      Sol 8 vs Sol ",solNum,sep=""), file=output, append=T)
        write(paste("p.value:   ",test$p.value,sep=""), file=output,append=T)
    }
}
