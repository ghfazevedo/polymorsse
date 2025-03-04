library(ggplot2)
library(RevGadgets)
library(coda)
library(tidyr)
library(dplyr)

# file names
fp = "../" 
traceFile = paste(fp, "outputs/Pho_PolymorSSE.model.log", sep="")
output_file = paste(fp, "outputs/Pho_PolymorSSE.Posterior", sep="")

variables=c("extinction_eic",
            "extinction_key",
            "extinction_nig",
            "extinction_per")

traceModel <- readTrace(traceFile, burnin = 0.1)

# PDF extinction rates
plotExtinction <- plotTrace(trace = traceModel, vars = variables)
plotExtinction
ggsave(filename = paste0(output_file, ".extinction.pdf"))
ggsave(filename = paste0(output_file, ".extinction.png"))


# Violin
# Convert the data into long format
long_data <- traceModel[[1]] %>%
  select(extinction_eic, extinction_per, extinction_key, extinction_nig) %>%
  pivot_longer(cols = everything(), names_to = "Variable", values_to = "Value")

# Define the order of the x-axis
order <- c( "extinction_nig", "extinction_eic", "extinction_per", "extinction_key") 

# Convert Variable to a factor with specified order
long_data$Variable <- factor(long_data$Variable, levels = order)

# Create the violin plot
ggplot(long_data, aes(x = Variable, y = Value, fill = Variable)) +
  geom_violin(trim = FALSE, alpha = 0.7) +
  geom_boxplot(width = 0.1, outlier.shape = NA, alpha = 0.5) + # Optional: Adds a boxplot inside
  theme_minimal() +
  labs( y = "Extinction Rates") +
  theme(legend.position = "none")

ggsave(filename = paste0(output_file, ".extinction.Violin.pdf"))
ggsave(filename = paste0(output_file, ".extinction.Violin.png"))


# PDF Transition rates
plotTransition <- plotTrace(trace = traceModel, match = "em")
plotTransition
ggsave(filename = paste0(output_file, ".transition.pdf"))
ggsave(filename = paste0(output_file, ".transition.png"))


# Violin
# Convert the data into long format
long_data2 <- traceModel[[1]] %>%
  select("em[1]", "em[2]" , "em[3]" ) %>%
  pivot_longer(cols = everything(), names_to = "Variable", values_to = "Value")

# Create the violin plot
ggplot(long_data2, aes(x = Variable, y = Value, fill = Variable)) +
  geom_violin(trim = FALSE, alpha = 0.7) +
  geom_boxplot(width = 0.1, outlier.shape = NA, alpha = 0.5) + # Optional: Adds a boxplot inside
  theme_minimal() +
  labs( y = "Transition Rates") +
  theme(legend.position = "none")

ggsave(filename = paste0(output_file, ".transition.Violin.pdf"))
ggsave(filename = paste0(output_file, ".transition.Violin.png"))
