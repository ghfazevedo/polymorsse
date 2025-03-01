library(RevGadgets)
library(ggplot2)
library(ggtree)
library(ggforce)  
library(dplyr)

# file names
fp = "../" 
tree_fn = paste(fp, "outputs/Pho_PolymorSSE.ase.marg.tre", sep="")
output_file = paste(fp, "outputs/Pho_PolymorSSE.Plot", sep="")

# State Labels
labels <- c("0" = "brown_brown",
            "1" = "brown_black",
            "2" = "brown_red",
            "3" = "black_brown",
            "4" = "black_black",
            "5" = "black_red",
            "6" = "red_brown",
            "7" = "red_black",
            "8" = "red_red")


# Define color mapping for states
state_colors <- list(
  "brown_brown" = c("brown", "brown"),
  "brown_black" = c("brown", "black"),
  "brown_red"   = c("brown", "red"),
  "black_brown" = c("black", "brown"),
  "black_black" = c("black", "black"),
  "black_red"   = c("black", "red"),
  "red_brown"   = c("red", "brown"),
  "red_black"   = c("red", "black"),
  "red_red"     = c("red", "red")
)


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
treeplot<- ggtree(tree) +
  # Plot ancestral state circles
  geom_nodepoint(aes(x = x - 0.01, y = y, fill = color1), 
                 data = tree_plot_data, shape = 21, size = 5, na.rm = TRUE) + 
  geom_nodepoint(aes(x = x + 0.01, y = y, fill = color2), 
                 data = tree_plot_data, shape = 21, size = 5, na.rm = TRUE) + 
  # Add tip labels (shift to the right)
  geom_tiplab(aes(label = label, x = x + 0.03), size = 5, align = FALSE, hjust = 0) +
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
