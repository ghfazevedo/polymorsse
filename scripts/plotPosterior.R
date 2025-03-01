library(ggplot2)
library(RevGadgets)
library(coda)


# file names
fp = "../" 
traceFile = paste(fp, "outputs/Pho_PolymorSSE.model.log", sep="")
variables=c("extinction_eic",
            "extinction_key",
            "extinction_nig",
            "extinction_per")

traceModel <- readTrace(traceFile, burnin = 0.1)

plotExtinction <- plotTrace(trace = traceModel, vars = variables)
plotExtinction

plotTransition <- plotTrace(trace = traceModel, match = "em")
plotTransition
