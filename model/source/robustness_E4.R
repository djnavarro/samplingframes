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
  ALPHA_RARE_SCALE <- 1/(runif(1)*99 + 1) 
  ALPHA_COMMON_SCALE <- runif(1)*99 + 1 
  SIGMA <- rexp(1, rate=2)
  TAU <- rexp(1, rate=1/1.5)
  RHO <- rexp(1, rate=10)
  MU <- rnorm(1)
  
  obs <- list(
    
    # parameters fixed by the design
    ncat = 10,
    test = 1:10,
    nobs = 9,
    plaxium = rep.int(1,9),
    category = c(1,1,1,1,2,2,2,2,2),
    nfree = 0,
    
    # parameters at their defaults
    sigma = SIGMA,
    tau = TAU,
    rho = RHO,
    m = MU
    
  )
  
  obs$alpha <- rep.int(ALPHA,10)
  obs$alpha[1:2] <- obs$alpha[1:2] * ALPHA_RARE_SCALE
  
  sim$category_rare_cat <- make(
    bugfile = here("source","category.bug"),
    obs = obs
  )
  
  obs$alpha <- rep.int(ALPHA,10)
  obs$alpha[1:2] <- obs$alpha[1:2] * ALPHA_COMMON_SCALE
  
  sim$category_common_cat <- make(
    bugfile = here("source","category.bug"),
    obs = obs
  )
  
  obs$alpha <- rep.int(ALPHA,10)
  obs$alpha[1:2] <- obs$alpha[1:2] * ALPHA_RARE_SCALE
  
  sim$property_rare_cat <- make(
    bugfile = here("source","property.bug"),
    obs = obs
  )
  
  obs$alpha <- rep.int(ALPHA,10)
  obs$alpha[1:2] <- obs$alpha[1:2] * ALPHA_COMMON_SCALE
  
  sim$property_common_cat <- make(
    bugfile = here("source","property.bug"),
    obs = obs
  )
  
  # create output frame
  df <- data.frame(
    test = 1:10,
    alpha = ALPHA,
    alpha_common_scale = ALPHA_COMMON_SCALE,
    alpha_rare_scale = ALPHA_RARE_SCALE,
    sigma = SIGMA,
    tau = TAU,
    rho = RHO,
    mu = MU
  )
  
  # add the generalisations
  df$category_commoncat <- sim$category_common_cat$out$phi
  df$category_rarecat <- sim$category_rare_cat$out$phi
  
  df$property_commoncat <- sim$property_common_cat$out$phi
  df$property_rarecat <- sim$property_rare_cat$out$phi
  

  
  # there are two qualitative effects to care about:
  # (1) shift down: lower ratings in posneg
  # (2) frame weaken: attenuated frame effect in posneg
  print(c(
    # "shiftdown" = sum(df$category_positive + df$property_positive - 
    #                     df$category_posneg - df$property_posneg) ,
    # "attenuate" = sum((df$category_positive - df$category_posneg) - 
    #                     (df$property_positive - df$property_posneg)) 
  ))
  
  
  timestamp <- lubridate::now() %>% as.numeric %>% round %>% as.character
  
  readr::write_csv(df, here("output","robust_E4",paste0("sim_",timestamp,".csv")))
  
}
