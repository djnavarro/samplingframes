library(here)
require(rjags)

make <- function(bugfile, obs = list()) {
  
  # parameters
  settings <- function(obs) {
    
    # by default there are 10 categories
    if(!exists("ncat",obs)) obs$ncat <- 10
    
    # add locations for the categories
    obs$test <- 1:obs$ncat
    
    # by default there are 20 plaxium positive observations
    # that belong to the target category (cat 1)
    if(!exists("nobs",obs)) obs$nobs <- 20
    
    # add the dummy variables for the positive observations
    # (plaxium = 1, category = 1)
    obs$plaxium <- rep.int(1,obs$nobs)
    if(!exists("category",obs)) {
      obs$category <- rep.int(1,obs$nobs)   
    }
    
    # by default the prior over base rates is symmetric 
    # dirichlet with concentration .35
    if(is.null(obs$alpha)) {
      obs$alpha <- rep.int(.35,obs$ncat)
    }
    
    # by default there are no negative observations (free)
    if(!exists("nfree",obs)) obs$nfree <- 0
    
    # default parameters for the gaussian process
    if(!exists("sigma",obs)) obs$sigma <- .5
    if(!exists("tau",obs)) obs$tau <- 1.5
    if(!exists("rho",obs)) obs$rho <- .1
    if(!exists("m",obs)) obs$m <- 0 
     
    return(obs)
  }
  
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
  model$obs = settings(obs)
  
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

sim <- list()

# --- simulations for experiment 1 ---

# in experiment 1 we have a "real" world biological property 
# plaxium blood which might presumably be rare. set m = -2 to
# push base rate expectations of P+ down to about .11; note
# this does nothing other than drag all the generalisation
# curves downward

m1 <- 0

# baseline conditions in the negative evidence condition
sim$category_positive_only <- make(
  bugfile = here("category.bug"),
  obs = list(m = m1)
)

sim$property_positive_only <- make(
  bugfile = here("property.bug"),
  obs = list(m = m1)
)

# adding negative evidence to the sample can have
# an effect on both sampling schemes
#
# .... currently doesn't work???
sim$category_negative_evidence <- make(
  bugfile = here("category.bug"),
  obs = list(nfree = 5, plaxium_free = rep.int(0,5), 
             category_free = c(2,3,4,5,6), m = m1)
)

sim$property_negative_evidence <- make(
  bugfile = here("property.bug"),
  obs = list(nfree = 5, plaxium_free = rep.int(0,5), 
             category_free = c(2,3,4,5,6), m = m1)
)

# --- simulations for experiment 2 ---

# in the robots experiments, we have something closer to a blank
# property (plaxium coating on rocks), so we remove the assumption
# of rarity from the property. now the curves will all regress 
# towards .5 (i.e., set m = 0). as mentioned before, this has no
# differential effect within experiment. it's just there to capture
# a systematic difference in how E1 vs E2-4 were set up

# sample size affects both
sim$category_n2 <- make(
  bugfile = here("category.bug"),
  obs = list(nobs = 2, category = c(1,2))
)

sim$category_n6 <- make(
  bugfile = here("category.bug"),
  obs = list(nobs = 6, category = rep.int(c(1,2),3))
)

sim$category_n12 <- make(
  bugfile = here("category.bug"),
  obs = list(nobs = 12, category = rep.int(c(1,2),6))
)

sim$property_n2 <- make(
  bugfile = here("property.bug"),
  obs = list(nobs = 2, category = c(1,2))
)

sim$property_n6 <- make(
  bugfile = here("property.bug"),
  obs = list(nobs = 6, category = rep.int(c(1,2),3))
)

sim$property_n12 <- make(
  bugfile = here("property.bug"),
  obs = list(nobs = 12, category = rep.int(c(1,2),6))
)

# --- simulations for experiment 4 ---
#
# this experiment had n=9 training items in all conditions,
# concentrated on the smallest categories; so the input to
# the model reflects that change in the design. (currently
# set up to be the two smallest... might need to change)
#
# the only model parameter we change from defaults is the 
# dirichlet parameter associated with the small categories

sim$category_rare_cat <- make(
  bugfile = here("category.bug"),
  obs = list(alpha = c(.01, .01, rep.int(.35, 8)),
             nobs = 9, category = c(1,1,1,1,2,2,2,2,2))
)

sim$category_common_cat <- make(
  bugfile = here("category.bug"),
  obs = list(alpha = c(20, 20, rep.int(.35, 8)),
             nobs = 9, category = c(1,1,1,1,2,2,2,2,2))
)

# the base rate manipulation only affects property
# sampling in the model (unless parameters change)
sim$property_rare_cat <- make(
  bugfile = here("property.bug"),
  obs = list(alpha = c(.01, .01, rep.int(.35, 8)),
             nobs = 9, category = c(1,1,1,1,2,2,2,2,2))
)

sim$property_common_cat <- make(
  bugfile = here("property.bug"),
  obs = list(alpha = c(20, 20, rep.int(.35, 8)),
             nobs = 9, category = c(1,1,1,1,2,2,2,2,2))
)




# save the results
save(make, sim, file = here("output","simulations.Rdata"))

