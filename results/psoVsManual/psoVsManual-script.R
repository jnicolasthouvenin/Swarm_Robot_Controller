
data <- read.csv("psoVsManual.csv",header=T)

pso.data <- data[data$SOLUTION == "PSO",]$EVALUATION
manual.data <- data[data$SOLUTION == "MANUAL",]$EVALUATION

data <- data.frame(pso = pso.data, manual = manual.data)

boxplot(data)

print(mean(pso.data))
print(mean(manual.data))

test <- wilcox.test(pso.data,manual.data,Paired = T)

print(test)

output = "psoVsManual-wt.txt"

write(paste("\nMethod:    ",test$method,sep=""), file=output, append=FALSE)
write(paste("Data:      ",test$data.name,sep=""), file=output, append=T)
write(paste("p.value:   ",test$p.value,sep=""), file=output,append=T)

if (test$p.value < 0.05) {
    write("\n   Null hypothesis rejected", file=output,append=T)
} else {
    write("\n   The null hypothesis can't be rejected", file=output,append=T)
}