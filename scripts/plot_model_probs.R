source("trace_plot_probs_function.R")

# file names
fp = "../outputs/" # edit to provide an absolute file path
trace_file = paste(fp, "Pho_SeDHiSSE.model.log",sep="")



trace_plot_probs(
  trace = trace_file,
  variables = "zeta_model_indicator",
  bayes = TRUE,
  #output = paste(fp, "figs/", "transition_model", sep=""),
  strength_lines = TRUE,
  color = "Grey"
)


trace_plot_probs(
  trace = trace_file,
  variables = "mu_prop_model_indicator",
  bayes = TRUE,
  output = paste(fp, "figs/", "extinction_model", sep=""),
  strength_lines = TRUE,
  color = "Grey"
)


trace_plot_probs(
  trace = trace_file,
  variables = "is_all_transition_different",
  bayes = TRUE,
  output = paste(fp, "figs/", "is_all_transition_different", sep=""),
  strength_lines = TRUE,
  color = "Grey"
)



trace_plot_probs(
  trace = trace_file,
  variables = "is_focal_death_equal",
  bayes = TRUE,
  output = paste(fp, "figs/", "is_focal_death_equal", sep=""),
  strength_lines = TRUE,
  color = "Grey"
)

trace_plot_probs(
  trace = trace_file,
  variables = "is_red_male_different",
  bayes = TRUE,
  #output = paste(fp, "figs/", "is_red_male_different", sep=""),
  strength_lines = TRUE,
  color = "Grey"
)


trace_plot_probs(
  trace = trace_file,
  variables = "is_there_different_birth_regimes",
  bayes = TRUE,
  #output = paste(fp, "figs/", "is_there_different_birth_regimes", sep=""),
  strength_lines = TRUE,
  color = "Grey"
)

trace_plot_probs(
  trace = trace_file,
  variables = "is_there_different_death_regimes",
  bayes = TRUE,
  #output = paste(fp, "figs/", "is_there_different_death_regimes", sep=""),
  strength_lines = TRUE,
  color = "Grey"
)


trace_plot_probs(
  trace = trace_file,
  variables = "is_transition_equal",
  bayes = TRUE,
  #output = paste(fp, "figs/", "is_transition_equal", sep=""),
  strength_lines = TRUE,
  color = "Grey"
)
