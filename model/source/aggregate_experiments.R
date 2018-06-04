library(readr)
library(tidyr)
library(magrittr)
library(stringr)

# read experiment 1 data, summarise, and reshape
e1 <- read_csv(here("data","expt1.csv")) %>%
  group_by(Evidence,sampling) %>%
  summarise(
    "1" = mean(sparrows),
    "2" = mean(pigeons),
    "3" = mean(owls),
    "4" = mean(ostritches),
    "5" = mean(mice),
    "6" = mean(lizards)
  ) %>% 
  gather(key = "test", value = "prediction", 
         -Evidence, -sampling)

# add experiment variable, reorganise and relabel
# columns to match the model version
e1$experiment <- "E1: Negative Evidence"
e1 <- e1[c(3,4,5,2,1)]
names(e1)[5] <- "condition" 

# tidy condition labels & response value
e1$prediction <- e1$prediction / 10 
e1$condition %<>% 
  str_replace("Positive","Positive Only") %>%
  str_replace("Negative","Positive & Negative")


# read experiment 2 data & reshape
e2 <- read_csv(here("data","expt2.csv")) %>%
  gather(key = "variable", value = "prediction",
         -ID, -Gender, -Age, -Sampling)

# split variable in to condition & test
e2$test <- str_remove(e2$variable, "^.*R")
e2$condition <- str_replace(e2$variable, "SS(.*)-.*", "N = \\1")

# summarise
e2 %<>% group_by(Sampling, condition, test) %>%
  summarise(prediction = mean(prediction))

# add variables and tidy
e2$experiment <- "E2: Sample Size"
e2 <- e2[c(3,4,5,1,2)]
names(e2)[4] <- "sampling"
e2$sampling %<>% 
  str_replace("category","Category") %>%
  str_replace("property","Property")
e2$prediction <- e2$prediction / 9  # raw: 0-9 scale


# read experiment 4 data, summarise & gather
e4 <- read_csv(here("data","expt4.csv")) %>% 
  group_by(sampling, baserate) %>%
  summarise(
    "1" = mean(Old2),
    "2" = mean(Old3),
    "3" = mean(Old4),
    "4" = mean(Old5),
    "5" = mean(Old6),
    "6" = mean(Old7),
    "7" = mean(Old8)
  ) %>%
  gather(key = "test", value = "prediction", 
         -sampling, -baserate)

# add variables, shuffle and tidy
e4$experiment <- "E4: Base Rate"
e4 <- e4[c(3,4,5,1,2)]
names(e4)[5] <- "condition"
e4$prediction <- e4$prediction / 9 # raw: 0-9 scale
e4$sampling %<>% 
  str_replace("category","Category") %>%
  str_replace("property","Property")
e4$condition %<>% 
  str_replace("large","C+ Rare") %>%
  str_replace("small","C+ Common")

# concatenate, final, tidy & write
e1 %<>% as.data.frame(stringsAsFactors = FALSE)
e2 %<>% as.data.frame(stringsAsFactors = FALSE)
e4 %<>% as.data.frame(stringsAsFactors = FALSE)
human <- rbind(e1,e2,e4)
human$test %<>% as.numeric

write_csv(human,here("data","human.csv"))


