library(ggplot2)
library(RevGadgets)
library(coda)


# file names
fp = "../" 
traceFile = paste(fp, "outputs/Pho_PolymorSSE.model.log", sep="")
output_file = paste(fp, "outputs/Pho_PolymorSSE.Posterior", sep="")

variables=c("extinction_eic",
            "extinction_key",
            "extinction_nig",
            "extinction_per")

traceModel <- readTrace(traceFile, burnin = 0.1)

plotExtinction <- plotTrace(trace = traceModel, vars = variables)
plotExtinction
ggsave(filename = paste0(output_file, ".extinction.pdf"))
ggsave(filename = paste0(output_file, ".extinction.png"))

plotTransition <- plotTrace(trace = traceModel, match = "em")
plotTransition
ggsave(filename = paste0(output_file, ".transition.pdf"))
ggsave(filename = paste0(output_file, ".transition.png"))

