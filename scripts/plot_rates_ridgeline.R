source("trace_ridgeline_plot_function.R")
source("summary_stats_from_trace.R")
library(RevGadgets)

# file names
fp = "../outputs/" # edit to provide an absolute file path
trace_file = paste(fp, "Pho_SeDHiSSE.model.log",sep="")

plot_fn = paste(fp, "figs/Pho_SeDHiSSE.pdf",sep="")
tree_fn = paste(fp, "Pho_SeDHiSSE.ase.marg.tre", sep="")

output_file_root = paste(fp, "figs/ridgeline/Pho_SeDHiSSE.Plot", sep="")



# Plot Transition Rates
transitions = c("thau_m[1]", "thau_m[2]", "thau_m[3]",
                "thau_f[1]", "thau_f[2]", "thau_f[3]")

trans_color = c("brown", "black", "red",
                "brown", "black", "red")

transitions_plot <- trace_ridgeline(trace = trace_file,
             variables = transitions,
             colors = trans_color,
             match = "total",
             output = paste(output_file_root, "Transition", sep="")
              )

transitions_plot

summary_stats_trans <- summary_stats_from_trace(trace_file = trace_file,
                                          variable_match = c("thau_m","thau_f"),
                                          out_name = paste(output_file_root, "Transition_STATS", sep="")
)
summary_stats_trans


# Plot All Extinction Rates
extinctions <- c( "mu_state_dependent[1]",	
                  "mu_state_dependent[2]",	
                  "mu_state_dependent[3]",	
                  "mu_state_dependent[4]",	
                  "mu_state_dependent[5]",	
                  "mu_state_dependent[6]",	
                  "mu_state_dependent[7]",	
                  "mu_state_dependent[8]",	
                  "mu_state_dependent[9]",
                  "mu_state_dependent[10]",
                  "mu_state_dependent[11]",
                  "mu_state_dependent[12]",
                  "mu_state_dependent[13]",
                  "mu_state_dependent[14]",
                  "mu_state_dependent[15]",
                  "mu_state_dependent[16]",
                  "mu_state_dependent[17]",
                  "mu_state_dependent[18]"
                  )

extinctions_colors = c("#6BAED6",
                       "#6BAED6", 
                       "#6BAED6", 
                       "#6BAED6",
                       "#6BAED6",
                       "#6BAED6",
                       "#6BAED6",
                       "#6BAED6",
                       "#6BAED6",
                       "#313695",
                       "#313695",
                       "#313695",
                       "#313695",
                       "#313695",
                       "#313695",
                       "#313695",
                       "#313695",
                       "#313695")


extinction_plot <- trace_ridgeline(trace = trace_file,
                                 variables = "mu_state_dependent",
                                 colors = extinctions_colors,
                                 match = "partial",
                                 output = paste(output_file_root, "Extinction", sep="")
                                 )
extinction_plot

summary_stats <- summary_stats_from_trace(trace_file = trace_file,
                                   variable_match = "mu_state_dependent",
                                   out_name = paste(output_file_root, "Extinction_STATS", sep="")
)
summary_stats


# Plot Focal Extinction Rates
extinctions_focal <- c( "mu_state_dependent[1]",	
                  "mu_state_dependent[5]",	
                  "mu_state_dependent[6]",	
                  "mu_state_dependent[9]",
                  "mu_state_dependent[10]",
                  "mu_state_dependent[14]",
                  "mu_state_dependent[15]",
                  "mu_state_dependent[18]"
                  )

focal_colors = c("#6BAED6",
                 "#6BAED6", 
                 "#6BAED6", 
                 "#6BAED6", 
                 "#313695",
                 "#313695",
                 "#313695",
                 "#313695")


extinction_focal_plot <- trace_ridgeline(trace = trace_file,
                                      variables = extinctions_focal,
                                      colors = focal_colors,
                                      match = "total",
                                      output = paste(output_file_root, "FocalExt", sep="")
                                      )
extinction_focal_plot


# Plot All birth Rates
births <- c( "lambda_state_dependent[1]",	
             "lambda_state_dependent[2]",	
             "lambda_state_dependent[3]",	
             "lambda_state_dependent[4]",	
             "lambda_state_dependent[5]",	
             "lambda_state_dependent[6]",	
             "lambda_state_dependent[7]",	
             "lambda_state_dependent[8]",	
             "lambda_state_dependent[9]",
             "lambda_state_dependent[10]",
             "lambda_state_dependent[11]",
             "lambda_state_dependent[12]",
             "lambda_state_dependent[13]",
             "lambda_state_dependent[14]",
             "lambda_state_dependent[15]",
             "lambda_state_dependent[16]",
             "lambda_state_dependent[17]",
             "lambda_state_dependent[18]"
)

birth_colors = c("#6BAED6",
                       "#6BAED6", 
                       "#6BAED6", 
                       "#6BAED6",
                       "#6BAED6",
                       "#6BAED6",
                       "#6BAED6",
                       "#6BAED6",
                       "#6BAED6",
                       "#313695",
                       "#313695",
                       "#313695",
                       "#313695",
                       "#313695",
                       "#313695",
                       "#313695",
                       "#313695",
                       "#313695")


birth_plot <- trace_ridgeline(trace = trace_file,
                                variables = "lambda_state_dependent",
                                colors = birth_colors,
                                match = "partial",
                           output = paste(output_file_root, "Birth", sep="")
                           )
birth_plot


# Plot Focal Extinction Rates
birth_focal <- c( "lambda_state_dependent[1]",	
                  "lambda_state_dependent[5]",	
                  "lambda_state_dependent[6]",	
                  "lambda_state_dependent[9]",
                  "lambda_state_dependent[10]",
                  "lambda_state_dependent[14]",
                  "lambda_state_dependent[15]",
                  "lambda_state_dependent[18]"
)

birth_colors = c("#6BAED6",
                 "#6BAED6", 
                 "#6BAED6", 
                 "#6BAED6", 
                 "#313695",
                 "#313695",
                 "#313695",
                 "#313695")


birth_focal_plot <- trace_ridgeline(trace = trace_file,
                                      variables = birth_focal,
                                      colors = birth_colors,
                                      match = "total",
                                      output = paste(output_file_root, "FocalBirth", sep="")
                                 )
birth_focal_plot

