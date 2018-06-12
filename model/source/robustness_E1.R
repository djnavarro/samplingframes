library(here)
library(rjags)
library(magrittr)


make <- function(bugfile, obs = list()) {
  
  # initialise
  model <- list()
  
  # simulation parameters
  model$opt <- list(
    burnin = 20000,
    its = 100000,
    nchains = 1,
    thin = 10
  )
  
  # data to be given to JAGS
  model$obs = obs
  
  # store the jags model specification as a string
  model$string <- paste0(
    readLines(bugfile), 
    collapse="\n"
  )
  
  # strip out the "free" sampling part of the model
  # if there are no uncensored observations 
  if(model$obs$nfree == 0) {
    model$string <- gsub("xxxxx.*ooooo","",model$string)
  }
  
  # construct the jags model object
  model$jagsmod <- jags.model(
    file = textConnection(model$string),
    n.adapt = model$opt$burnin,
    n.chains = model$opt$nchains,
    data = model$obs
  )
  
  # draw samples
  model$samples <- jags.samples(
    model = model$jagsmod, 
    variable.names = c("phi"), 
    n.iter = model$opt$its,
    thin = model$opt$thin
  )
  
  # add a convenient summary
  model$out <- data.frame(
    test = model$obs$test,
    phi = apply(model$samples$phi, 1, mean)
  )
  
  return(model)
  
}


for(i in 1:1) {
  
  # sample from distributions centred on the 
  # hand-tuned values
  ALPHA <- rexp(1, rate=1/.35)
  SIGMA <- rexp(1, rate=2)
  TAU <- rexp(1, rate=1/1.5)
  RHO <- rexp(1, rate=10)
  MU <- rnorm(1)
  
  obs <- list(
    
    # parameters fixed by the design
    ncat = 10,
    test = 1:10,
    nobs = 20,
    plaxium = rep.int(1,20),
    category = rep.int(1,20),
    nfree = 0,
    
    # parameters at their defaults
    alpha = rep.int(ALPHA,10),
    sigma = SIGMA,
    tau = TAU,
    rho = RHO,
    m = MU
    
  )
  
  
  # --- simulations for experiment 1 ---
  
  sim <- list()
  
  # baseline conditions in the negative evidence condition
  sim$category_positive_only <- make(
    bugfile = here("source","category.bug"),
    obs = obs
  )
  
  sim$property_positive_only <- make(
    bugfile = here("source","property.bug"),
    obs = obs
  )
  
  # add negative evidence
  obs$nfree <- 5
  obs$plaxium_free <- rep.int(0,5)
  obs$category_free <- c(2,3,4,5,6)
  
  sim$category_negative_evidence <- make(
    bugfile = here("source","category.bug"),
    obs = obs
  )
  
  sim$property_negative_evidence <- make(
    bugfile = here("source","property.bug"),
    obs = obs
  )
  
  # create output frame
  df <- data.frame(
    test = 1:10,
    alpha = ALPHA,
    sigma = SIGMA,
    tau = TAU,
    rho = RHO,
    mu = MU
  )
  
  # add the generalisations
  df$category_positive <- sim$category_positive_only$out$phi
  df$property_positive <- sim$property_positive_only$out$phi
  df$category_posneg <- sim$category_negative_evidence$out$phi
  df$property_posneg <- sim$property_negative_evidence$out$phi
  
  timestamp <- lubridate::now() %>% as.numeric %>% round %>% as.character
  
  readr::write_csv(df, here("output","robust_E1",paste0("sim_",timestamp,".csv")))
  
}
