library(RevGadgets)
library(ggplot2)
library(ggtree)
library(RColorBrewer)
library(viridis)
library(ggforce)  
library(dplyr)

# file names
fp = "../outputs/" # edit to provide an absolute file path
#plot_fn = paste(fp, "figs/Pho_SeDHiSSE.pdf",sep="")
tree_fn = paste(fp, "Pho_SeDHiSSE.ase.marg.tre", sep="")

output_file = paste(fp, "figs/Pho_SeDHiSSE.Plot", sep="")

branchRatesFile <- paste(fp, "Pho_SeDHiSSE.BirthDeathBrRates.log", sep="")

# Burn in
burn = 0.1

# State labels
labels <- c("0" = "F=brown M=brown, slow diversification",
            "1" = "F=brown M=black, slow diversification",
            "2" = "F=brown M=red, slow diversification",
            "3" = "F=black M=brown, slow diversification",
            "4" = "F=black M=black, slow diversification",
            "5" = "F=black M=red, slow diversification",
            "6" = "F=red M=brown, slow diversification",
            "7" = "F=red M=black, slow diversification",
            "8" = "F=red M=red, slow diversification",
            "9" = "F=brown M=brown, fast diversification",
            "10" = "F=brown M=black, fast diversification",
            "11" = "F=brown M=red, fast diversification",
            "12" = "F=black M=brown, fast diversification",
            "13" = "F=black M=black, fast diversification",
            "14" = "F=black M=red, fast diversification",
            "15" = "F=red M=brown, fast diversification",
            "16" = "F=red M=black, fast diversification",
            "17" = "F=red M=red, fast diversification")


########################################
# Plot Ancestral States as Pie Charts  #
########################################

# process and plot marginal probabilities
states <- processAncStates(tree_fn, state_labels=labels)


plotAncStatesPie(t=states,
                 cladogenetic = FALSE,
                 pie_colors = "default",
                 tip_pie_size=1,
                 node_pie_size = 1,
                 shoulder_pie_size = 1,
                 state_transparency = 0.8,
                 tip_labels_size=8,
                 timeline = FALSE,
                 geo=FALSE
) +
  ggplot2::theme(legend.position="left",
                 legend.title=element_blank(),
                  legend.text = element_text(size = 40),   # font size
                  legend.key.size = unit(80, units = "points" ),       # symbol size
                  ) + 
  geom_tree(size = 2) 


#ggsave(paste(output_file, ".marg.PIE.pdf", sep=""), width = 18, height = 24) 

ggsave(paste(output_file, ".marg.PIE.pdf", sep=""), width = 36, height = 24) 

ggsave(paste(output_file, ".marg.PIE.jpg", sep=""), width = 36, height = 24) 



##########################################
# Plot Ancestral States: Separate states # 
# for males and females                  #
##########################################

# Define color mapping for states
state_colors <- list(
  "F=brown M=brown, slow diversification" = c("brown", "brown"),
  "F=brown M=black, slow diversification"= c("brown", "black"),
  "F=brown M=red, slow diversification" = c("brown", "red"),
  "F=black M=brown, slow diversification" = c("black", "brown"),
  "F=black M=black, slow diversification" = c("black", "black"),
  "F=black M=red, slow diversification" = c("black", "red"),
  "F=red M=brown, slow diversification" = c("red", "brown"),
  "F=red M=black, slow diversification" = c("red", "black"),
  "F=red M=red, slow diversification" = c("red", "red"),
  "F=brown M=brown, fast diversification" = c("brown", "brown"),
  "F=brown M=black, fast diversification" = c("brown", "black"),
  "F=brown M=red, fast diversification" = c("brown", "red"),
  "F=black M=brown, fast diversification" = c("black", "brown"),
  "F=black M=black, fast diversification" = c("black", "black"),
  "F=black M=red, fast diversification"= c("black", "red"),
  "F=red M=brown, fast diversification"= c("red", "brown"),
  "F=red M=black, fast diversification"= c("red", "black"),
  "F=red M=red, fast diversification" = c("red", "red"))
  

# Process the ancestral states
states <- processAncStates(tree_fn, state_labels=labels)

# Extract necessary data
tree <- states@phylo  # Extract phylogenetic tree
state_data <- states@data$end_state_1  # Extract node states
state_labels <- states@state_labels  # Labels for legend
nodes <- states@data$node

# Create a data frame linking nodes to states
states_df <- data.frame(
  node = as.integer(nodes), 
  state = as.character(state_data)  # Extract most probable state
)

# Ensure all states are mapped properly
states_df <- states_df %>%
  rowwise() %>%
  mutate(
    color1 = state_colors[[state]][1],  # First color in the pair
    color2 = state_colors[[state]][2]   # Second color in the pair
  ) %>%
  ungroup()


# Extract ggtree node data
ggtree_data <- ggtree(tree)$data %>%
  mutate(node = as.integer(node))  # Ensure node column is integer

# Merge state info with tree data
tree_plot_data <- left_join(ggtree_data, states_df, by = "node")

# Ensure `color1` and `color2` are correctly mapped
tree_plot_data <- tree_plot_data %>%
  mutate(
    color1 = ifelse(is.na(color1), "gray", color1),  # Default to gray if NA
    color2 = ifelse(is.na(color2), "gray", color2)
  )


colors=c("black", "brown", "red")

# Plot tree with correctly assigned colors
treeplot<- ggtree(tree, size = 5) +
  # Plot ancestral state circles
  geom_nodepoint(aes(x = x - 0.03, y = y, fill = color1), 
                 data = tree_plot_data, shape = 21, size = 8, na.rm = TRUE) + 
  geom_nodepoint(aes(x = x + 0.03, y = y, fill = color2), 
                 data = tree_plot_data, shape = 21, size = 8, na.rm = TRUE) + 
  # Add tip labels (shift to the right)
  geom_tiplab(aes(label = label, x = x + 0.03), size = 8, align = FALSE, hjust = 0) +
  # Add tip states (colored dots at tips)
  geom_tippoint(aes(x = x - 0.01, y = y, fill = color1), 
                data = tree_plot_data, shape = 21, size = 5, na.rm = TRUE) +
  geom_tippoint(aes(x = x + 0.01, y = y, fill = color2), 
                data = tree_plot_data, shape = 21, size = 5, na.rm = TRUE) +
  scale_fill_manual(values = colors) +  
  theme_minimal() +
  theme(panel.grid = element_blank(),
        panel.border = element_blank(),
        axis.text = element_blank())+
  guides(fill = guide_legend(title = "Ancestral State (left: female, right: male")) +
  # Move legend to the top-left
  theme(legend.position.inside = c(0.05, 0.05),  # x = 0.05 (left), y = 0.95 (top)
        legend.justification = c(0, 1),  # Anchor at top-left
        legend.background = element_rect(fill = "white", color = "black"))

treeplot

ggsave(treeplot,file=paste(output_file, ".tree.pdf", sep=""), width = 30, height = 27) 
ggsave(treeplot,file=paste(output_file, ".tree.jpg", sep=""), width = 30, height = 27)


########################################
# Plot tree with diversification rates #
########################################

spBrRateTree <- readTrees(tree_fn)


color_birth = c("#6BAED6", "#313695")
color_death = c("#6BAED6", "#313695")
color_net = c("#6BAED6", "#313695")

# Plot tree with BD Branch rates for birth and death
branch_data <- readTrace(branchRatesFile)
branchTree <- processBranchData(spBrRateTree, branch_data, burnin = burn, parnames = c("avg_lambda", "avg_mu", "num_shifts"), summary = "median", net_div = TRUE)

birth <- plotTree(tree = branchTree,
                  node_age_bars = FALSE,
                  node_pp = FALSE,
                  tip_labels = TRUE,
                  tip_labels_size = 8,
                  color_branch_by = "avg_lambda",
                  branch_color = color_birth,
                  line_width = 5) +
  ggplot2::theme(legend.position.inside = c(.1, .9))

plot(birth)

ggsave(birth, file = paste(output_file, "BirthRateTree.pdf", sep=""), width = 18, height = 24, device = "pdf")

ggsave(birth, file = paste(output_file, "BirthRateTree.png", sep=""), width = 18, height = 24, device = "png")


## Plot tree with death rates
extinction <- plotTree(tree = branchTree, 
                       node_age_bars = FALSE,
                       node_pp = FALSE, 
                       tip_labels = TRUE,
                       tip_labels_size = 8,
                       color_branch_by = "avg_mu",
                       branch_color=color_death,
                       line_width = 5) + 
  ggplot2::theme(legend.position.inside = c(.1, .9))

plot(extinction)

ggsave(extinction, file = paste(output_file, "extinctionTree.pdf", sep=""), width = 18, height = 24, device = "pdf")

ggsave(extinction, file = paste(output_file, "extinctionTree.png", sep=""), width = 18, height = 24, device = "png")


# Plot tree with net diversification rates 
# (if you are using a population tree this is the net population fragmentation)

net <- plotTree(tree = branchTree, 
                node_age_bars = FALSE,
                node_pp = FALSE, 
                tip_labels = TRUE,
                tip_labels_size = 8,
                color_branch_by = "net_div",
                branch_color= color_net,
                line_width = 5) + 
  ggplot2::theme(legend.position.inside = c(.1, .9))

plot(net)

ggsave(net, file = paste(output_file, "netDivTree.pdf", sep=""), width = 18, height = 24, device = "pdf")

ggsave(net, file = paste(output_file, "netDivTree.png", sep=""), width = 18, height = 24, device = "png")



##################################
# Both rates and ancestral states #
###################################

# Process the ancestral states
states <- processAncStates(tree_fn, state_labels=labels)

# Define color mapping for states
state_colors <- list(
  "F=brown M=brown, slow diversification" = c("brown", "brown"),
  "F=brown M=black, slow diversification"= c("brown", "black"),
  "F=brown M=red, slow diversification" = c("brown", "red"),
  "F=black M=brown, slow diversification" = c("black", "brown"),
  "F=black M=black, slow diversification" = c("black", "black"),
  "F=black M=red, slow diversification" = c("black", "red"),
  "F=red M=brown, slow diversification" = c("red", "brown"),
  "F=red M=black, slow diversification" = c("red", "black"),
  "F=red M=red, slow diversification" = c("red", "red"),
  "F=brown M=brown, fast diversification" = c("brown", "brown"),
  "F=brown M=black, fast diversification" = c("brown", "black"),
  "F=brown M=red, fast diversification" = c("brown", "red"),
  "F=black M=brown, fast diversification" = c("black", "brown"),
  "F=black M=black, fast diversification" = c("black", "black"),
  "F=black M=red, fast diversification"= c("black", "red"),
  "F=red M=brown, fast diversification"= c("red", "brown"),
  "F=red M=black, fast diversification"= c("red", "black"),
  "F=red M=red, fast diversification" = c("red", "red"))




# Extract necessary data
tree <- states@phylo  # Extract phylogenetic tree
state_data <- states@data$end_state_1  # Extract node states
state_labels <- states@state_labels  # Labels for legend
nodes <- states@data$node


states_df <- data.frame(
  node = as.integer(nodes),
  state = as.character(state_data)
) %>%
  rowwise() %>%
  mutate(
    color1 = state_colors[[state]][1],
    color2 = state_colors[[state]][2]
  ) %>%
  ungroup()


spBrRateTree <- readTrees(tree_fn)

color_birth = c("#6BAED6", "#313695")
color_death = c("#6BAED6", "#313695")
color_net = c("#6BAED6", "#313695")

# Tree and branch data
branch_data <- readTrace(branchRatesFile)
branchTree <- processBranchData(spBrRateTree, branch_data, burnin = burn, parnames = c("avg_lambda", "avg_mu", "num_shifts"), summary = "median", net_div = TRUE)


################
# Birth Tree
###############

birth_tree <- plotTree(
  tree = branchTree,
  node_age_bars = FALSE,
  node_pp = FALSE,
  tip_labels = TRUE,
  tip_labels_size = 8,
  color_branch_by = "avg_lambda",
  branch_color = color_birth,
  line_width = 5
)

birth_tree$data <- birth_tree$data %>%
  left_join(states_df, by = "node") %>%
  mutate(
    color1 = ifelse(is.na(color1), "gray", color1),
    color2 = ifelse(is.na(color2), "gray", color2)
  )


colors=c("black", "brown", "red")

birth_with_states <- birth_tree +
  
  ## Internal nodes
  geom_nodepoint(
    aes(x = x - 0.03, y = y, fill = color1),
    shape = 21, size = 8, na.rm = TRUE
  ) +
  geom_nodepoint(
    aes(x = x + 0.03, y = y, fill = color2),
    shape = 21, size = 8, na.rm = TRUE
  ) +
  
  ## Tips
  geom_tippoint(
    aes(x = x - 0.03, y = y, fill = color1),
    shape = 21, size = 5, na.rm = TRUE
  ) +
  geom_tippoint(
    aes(x = x + 0.00, y = y, fill = color2),
    shape = 21, size = 5, na.rm = TRUE
  ) +
  
  scale_fill_manual(values = colors) +
  
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.text = element_blank(),
    legend.position.inside = c(0.05, 0.05),
    legend.justification = c(0, 1),
    legend.background = element_rect(fill = "white", color = "black")
  ) +
  guides(fill = guide_legend(
    title = "Ancestral state\n(left = female, right = male)"
  )) 

birth_with_states <- birth_with_states +
  xlim(
    min(birth_with_states$data$x) - 0.5,
    max(birth_with_states$data$x) + 0.5
  )

birth_with_states 


ggsave(birth_with_states, file = paste(output_file, "BithTree_ASR.pdf", sep=""), width = 18, height = 24, device = "pdf")

ggsave(birth_with_states, file = paste(output_file, "BithTree_ASR.png", sep=""), width = 18, height = 24, device = "png")



################
# Death Tree
###############

death_tree <- plotTree(
  tree = branchTree,
  node_age_bars = FALSE,
  node_pp = FALSE,
  tip_labels = TRUE,
  tip_labels_size = 8,
  color_branch_by = "avg_mu",
  branch_color = color_death,
  line_width = 5
)

death_tree$data <- death_tree$data %>%
  left_join(states_df, by = "node") %>%
  mutate(
    color1 = ifelse(is.na(color1), "gray", color1),
    color2 = ifelse(is.na(color2), "gray", color2)
  )


colors=c("black", "brown", "red")

death_with_states <- death_tree +
  
  ## Internal nodes
  geom_nodepoint(
    aes(x = x - 0.03, y = y, fill = color1),
    shape = 21, size = 8, na.rm = TRUE
  ) +
  geom_nodepoint(
    aes(x = x + 0.03, y = y, fill = color2),
    shape = 21, size = 8, na.rm = TRUE
  ) +
  
  ## Tips
  geom_tippoint(
    aes(x = x - 0.03, y = y, fill = color1),
    shape = 21, size = 5, na.rm = TRUE
  ) +
  geom_tippoint(
    aes(x = x + 0.00, y = y, fill = color2),
    shape = 21, size = 5, na.rm = TRUE
  ) +
  
  scale_fill_manual(values = colors) +
  
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.text = element_blank(),
    legend.position.inside = c(0.05, 0.05),
    legend.justification = c(0, 1),
    legend.background = element_rect(fill = "white", color = "black")
  ) +
  guides(fill = guide_legend(
    title = "Ancestral state\n(left = female, right = male)"
  )) 

death_with_states <- death_with_states +
  xlim(
    min(death_with_states$data$x) - 0.1,
    max(death_with_states$data$x) + 0.5
  )

death_with_states  

ggsave(death_with_states, file = paste(output_file, "DeathTree_ASR.pdf", sep=""), width = 18, height = 24, device = "pdf")

ggsave(death_with_states, file = paste(output_file, "DeathTree_ASR.png", sep=""), width = 18, height = 24, device = "png")


###########################
# Net Diversification  Tree ASR
##########################

net_tree <- plotTree(
  tree = branchTree,
  node_age_bars = FALSE,
  node_pp = FALSE,
  tip_labels = TRUE,
  tip_labels_size = 8,
  color_branch_by = "net_div",
  branch_color = color_net,
  line_width = 5
)

net_tree$data <- net_tree$data %>%
  left_join(states_df, by = "node") %>%
  mutate(
    color1 = ifelse(is.na(color1), "gray", color1),
    color2 = ifelse(is.na(color2), "gray", color2)
  )


colors=c("black", "brown", "red")

net_with_states <- net_tree +
  
  ## Internal nodes
  geom_nodepoint(
    aes(x = x - 0.03, y = y, fill = color1),
    shape = 21, size = 8, na.rm = TRUE
  ) +
  geom_nodepoint(
    aes(x = x + 0.03, y = y, fill = color2),
    shape = 21, size = 8, na.rm = TRUE
  ) +
  
  ## Tips
  geom_tippoint(
    aes(x = x - 0.03, y = y, fill = color1),
    shape = 21, size = 5, na.rm = TRUE
  ) +
  geom_tippoint(
    aes(x = x + 0.00, y = y, fill = color2),
    shape = 21, size = 5, na.rm = TRUE
  ) +
  
  scale_fill_manual(values = colors) +
  
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.text = element_blank(),
    legend.position.inside = c(0.05, 0.05),
    legend.justification = c(0, 1),
    legend.background = element_rect(fill = "white", color = "black")
  ) +
  guides(fill = guide_legend(
    title = "Ancestral state\n(left = female, right = male)"
  )) 

net_with_states <- net_with_states +
  xlim(
    min(net_with_states$data$x) - 0.1,
    max(net_with_states$data$x) + 0.5
  )

net_with_states 

ggsave(net_with_states, file = paste(output_file, "NetDivTree_ASR.pdf", sep=""), width = 18, height = 24, device = "pdf")

ggsave(net_with_states, file = paste(output_file, "NetDivTree_ASR.png", sep=""), width = 18, height = 24, device = "png")



