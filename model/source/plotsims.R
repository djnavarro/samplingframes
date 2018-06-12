library(here)
library(ggplot2)
library(magrittr)
library(dplyr)
library(readr)
library(purrr)
library(stringr)

load(here("output","simulations.Rdata"))

get_out <- function(mod, exp, samp, cond) {
  out <- mod$out
  names(out)[2] <- "prediction" 
  out$experiment <- exp
  out$sampling <- samp
  out$condition <- cond
  return(out)
}

output <- rbind(
  get_out(sim$category_positive_only, "E1: Negative Evidence", "Category", "Positive Only"),
  get_out(sim$property_positive_only, "E1: Negative Evidence", "Property", "Positive Only"),
  get_out(sim$category_negative_evidence, "E1: Negative Evidence", "Category", "Positive & Negative"),
  get_out(sim$property_negative_evidence, "E1: Negative Evidence", "Property", "Positive & Negative"),
  get_out(sim$category_n2, "E2: Sample Size", "Category", "N = 2"),
  get_out(sim$property_n2, "E2: Sample Size", "Property", "N = 2"),  
  get_out(sim$category_n6, "E2: Sample Size", "Category", "N = 6"),
  get_out(sim$property_n6, "E2: Sample Size", "Property", "N = 6"),  
  get_out(sim$category_n12, "E2: Sample Size", "Category", "N = 12"),
  get_out(sim$property_n12, "E2: Sample Size", "Property", "N = 12"), 
  get_out(sim$category_common_cat, "E4: Base Rate", "Category", "C+ Common"),
  get_out(sim$category_rare_cat, "E4: Base Rate", "Category", "C+ Rare"),
  get_out(sim$property_common_cat, "E4: Base Rate", "Property", "C+ Common"),
  get_out(sim$property_rare_cat, "E4: Base Rate", "Property", "C+ Rare")
)

output$condition %<>% as.factor %>% 
  lsr::permuteLevels(perm = c(1,2,4,5,3,7,6))

# read the human data and append
human <- read_csv(here("data","human.csv"))
human$source <- "Human"
output$source <- "Model"
output <- rbind(output, human)

output$exp_panel <- map2_chr(
  .x = output$experiment %>%
    str_replace_all("Negative Evidence","Neg Ev") %>%
    str_replace_all("Sample Size", "SS") %>%
    str_replace_all("Sample Size", "SS") %>%
    str_replace_all("Base Rate", "BR"),
  .y = output$sampling %>% str_sub(1,3),
  .f = function(x,y) {paste0(x," (",y,")")}
)

# relabel to be consistent with paper
levels(output$condition) %<>% 
  str_replace(fixed("C+ Common"), "C- Rare") %>%
  str_replace(fixed("C+ Rare"), "C- Common")


dividers <- data.frame(
  exp_panel = c("E1: Neg Ev (Cat)", "E1: Neg Ev (Pro)", "E2: SS (Cat)", 
                "E2: SS (Pro)", "E4: BR (Cat)", "E4: BR (Pro)"),
  x = c(1.5, 1.5, 2.5, 2.5, 2.5, 2.5),
  y = c(.5, .5, .5, .5, .5, .5)
)

out1 <- output %>%
  filter(test <= 7) %>%
  filter(!(test == 7 & experiment == "E1: Negative Evidence"))

pic1 <- out1 %>%
  ggplot(aes(x = test, y = prediction, colour = condition, shape = sampling)) +
  geom_line() + 
  geom_point(size = 2) + 
  facet_grid(source~exp_panel, scales = "free_x") +
  geom_vline(data = dividers, mapping = aes(xintercept=x), lty = 3) + 
  geom_hline(data = dividers, mapping = aes(yintercept=y), lty = 3) + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + 
  scale_x_continuous(name = "Test Stimulus", breaks = 1:7, labels = paste0("S",1:7)) + 
  scale_y_continuous(name = "Property Generalization", limits = c(0,1))
plot(pic1)

out2 <- out1 %>% 
  spread(key = source, value = prediction)

correlations <- out2 %>%
  group_by(experiment) %>%
  summarise(r = cor(Model,Human))
correlations$x <- .7
correlations$y <- .1
correlations$s <- paste("r =", round(correlations$r,3))

pic2 <- out2 %>%  
  ggplot(aes(x = Model, y = Human)) +
  geom_point(size = 2, mapping = aes(colour = condition, shape = sampling)) + 
  facet_grid(~experiment) +
  theme_bw() + 
  geom_abline(slope = 1, intercept = 0, lty = 3) + 
  xlim(0,1) + ylim(0,1) + 
  geom_text(data = correlations, mapping = aes(x = x, y = y, label = s))

plot(pic2)

ggsave(here("output","fits_line.pdf"), plot = pic1, width = 10, height = 6)
ggsave(here("output","fits_scatter.pdf"), plot = pic2, width = 7, height = 4)

