library(here)
library(purrr)
library(readr)

counts <- vector()

# list of files for the Exp 1 
x <- list.files(here("output","robust_E1"))

# E1: overall generalisation decreases with negative evidence?
cat(".")
counts["E1-lower-posneg"] <- x %>%
  map_lgl(
    function(x) {
      df <- read_csv(here("output","robust_E1",x))
      sum(df$category_positive + df$property_positive - 
            df$category_posneg - df$property_posneg) > 0
    }
  ) %>% sum


# E1: overall generalisation lower in property
cat(".")
counts["E1-lower-property"] <- x %>%
  map_lgl(
    function(x) {
      df <- read_csv(here("output","robust_E1",x))
      sum( -(df$property_positive + df$property_posneg) + 
            (df$category_posneg + df$category_positive)) > 0
    }
  ) %>% sum


# E1: frame effect weaker in posneg
cat(".")
counts["E1-attenuation"] <- x %>%
  map_lgl(
    function(x) {
      df <- read_csv(here("output","robust_E1",x))
      sum((df$category_positive - df$category_posneg) - 
            (df$property_positive - df$property_posneg)) > 0
    }
  ) %>% sum


# list of files for the Exp 2 
x <- list.files(here("output","robust_E2"))


# E2: sample size increases generalisation in category sampling
cat(".")
counts["E2-cat-SS-rise"] <- x %>%
  map_lgl(
    function(x) {
      df <- read_csv(here("output","robust_E2",x))
      m2 <- mean(df$category_n2) 
      m6 <- mean(df$category_n6) 
      m12 <- mean(df$category_n12) 
      (m2 < m6) & (m6 < m12)
    }
  ) %>% sum

# E2: for category sampling, the effect is weaker for distant items
cat(".")
counts["E2-cat-SS-rise-attenuates"] <- x %>%
  map_lgl(
    function(x) {
      df <- read_csv(here("output","robust_E2",x))
      m2_near<- mean(df$category_n2[2]) 
      m12_near <- mean(df$category_n12[2]) 
      m2_far <- mean(df$category_n2[7]) 
      m12_far <- mean(df$category_n12[7]) 
      (m12_near - m2_near) > (m12_far - m2_far)
    }
  ) %>% sum

# E2: for property sampling, SS causes rise for target items
cat(".")
counts["E2-prop-SS-rise-near"] <- x %>%
  map_lgl(
    function(x) {
      df <- read_csv(here("output","robust_E2",x))
      m2_near <- mean(df$property_n2[1:2]) 
      m6_near <- mean(df$property_n6[1:2]) 
      m12_near <- mean(df$property_n12[1:2]) 
      (m2_near < m6_near) & (m6_near < m12_near)
    }
  ) %>% sum



# E2: for property sampling, SS causes fall for distant items
cat(".")
counts["E2-prop-SS-fall-far"] <- x %>%
  map_lgl(
    function(x) {
      df <- read_csv(here("output","robust_E2",x))
      m2_far <- mean(df$property_n2[5:7]) 
      m6_far <- mean(df$property_n6[5:7]) 
      m12_far <- mean(df$property_n12[5:7]) 
      (m2_far > m6_far) & (m6_far > m12_far)
    }
  ) %>% sum


# E2: lower generalisation in property sampling
cat(".")
counts["E2-lower-property"] <- x %>%
  map_lgl(
    function(x) {
      df <- read_csv(here("output","robust_E2",x))
      prop <- mean(df$property_n2) + mean(df$property_n6) + mean(df$property_n12)
      cat <- mean(df$category_n2) + mean(df$category_n6) + mean(df$category_n12)
      prop < cat
    }
  ) %>% sum



# list of files for the Exp 4 
x <- list.files(here("output","robust_E4"))


# E4: lower generalisation in property sampling
cat(".")
counts["E4-lower-property"] <- x %>%
  map_lgl(
    function(x) {
      df <- read_csv(here("output","robust_E4",x))
      prop <- mean(df$property_commoncat) + mean(df$property_rarecat) 
      cat <- mean(df$category_commoncat) + mean(df$category_rarecat) 
      prop < cat
    }
  ) %>% sum


# E4: generalisation to target in property, (C+ rare) > (C+ common)
cat(".")
counts["E4-property-target-effect"] <- x %>%
  map_lgl(
    function(x) {
      df <- read_csv(here("output","robust_E4",x))
      mean(df$property_commoncat[1:2]) < mean(df$property_rarecat[1:2]) 
    }
  ) %>% sum

# E4: generalisation to extrapolation categories in property, (C+ rare) < (C+ common)
cat(".")
counts["E4-property-nontarget-effect"] <- x %>%
  map_lgl(
    function(x) {
      df <- read_csv(here("output","robust_E4",x))
      mean(df$property_commoncat[3:7]) > mean(df$property_rarecat[3:7]) 
    }
  ) %>% sum


# E4: lower generalisation in property sampling
cat(".")
counts["E4-lower-property"] <- x %>%
  map_lgl(
    function(x) {
      df <- read_csv(here("output","robust_E4",x))
      prop <- mean(df$property_commoncat) + mean(df$property_rarecat) 
      cat <- mean(df$category_commoncat) + mean(df$category_rarecat) 
      prop < cat
    }
  ) %>% sum


# E4: generalisation to target in category, (C+ rare) > (C+ common)
cat(".")
counts["E4-category-target-effect"] <- x %>%
  map_lgl(
    function(x) {
      df <- read_csv(here("output","robust_E4",x))
      mean(df$category_commoncat[1:2]) < mean(df$category_rarecat[1:2]) 
    }
  ) %>% sum

# E4: generalisation to extrapolation categories in category, (C+ rare) < (C+ common)
cat(".")
counts["E4-category-nontarget-effect"] <- x %>%
  map_lgl(
    function(x) {
      df <- read_csv(here("output","robust_E4",x))
      mean(df$category_commoncat[3:7]) > mean(df$category_rarecat[3:7]) 
    }
  ) %>% sum

# E4: weaker base rate effects in category than property
counts["E4-attenuation"] <- x %>%
  map_lgl(
    function(x) {
      df <- read_csv(here("output","robust_E4",x))
      catdiff <- mean(abs(df$category_commoncat - df$category_rarecat)) 
      propdiff <- mean(abs(df$property_commoncat - df$property_rarecat)) 
      catdiff < propdiff
    }
  ) %>% sum



