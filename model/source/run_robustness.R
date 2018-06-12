library(here)
for(iteration in 1:1000) {
  
  cat("-------------------------------------------\n")
  cat("           iteration ", iteration ," of 1000\n")
  cat("-------------------------------------------\n")
  
  source(here("source","robustness_E1.R"))
  source(here("source","robustness_E2.R"))
  source(here("source","robustness_E4.R"))
  
}