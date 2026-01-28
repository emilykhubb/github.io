#### Load Packages ####
suppressPackageStartupMessages({
  library(haven)
  library(dplyr)
  library(stringr)
  library(tidyr)
  library(purrr)
})

#### Load Overall Data ####
path <- "20240-0001-Data.dta"   #Merged CPES file where NSAL-> CPESPROJ == 3
dat  <- read_dta(path)

# Sanity check that we're in the merged file
stopifnot("CPESPROJ" %in% names(dat))   # 1=NCS-R, 2=NLAAS, 3=NSAL

#Setting CPES special missing codes to NA
special_na <- function(x) replace(x, x %in% c(-9, -8, -7, 97, 98, 99), NA)

# Label from a haven-labelled column
get_label <- function(x) {
  lab <- attr(x, "label"); if (is.null(lab)) "" else as.character(lab)
}

#### Restrict to NSAL & Lifetime Bipolar One Respondents ####
#NSAL
nsal <- dat %>% filter(CPESPROJ == 3) #NSAL respondents only

#Bipolar One 
nsal <- nsal %>%
  mutate(V07842 = special_na(V07842),
         bpi_life = case_when(V07842 == 1 ~ 1L,
                              V07842 == 5 ~ 0L,
                              TRUE ~ NA_integer_)) %>%
  filter(bpi_life == 1L). # V07842: 1=lifetime BP-I, 5=not lifetime BP-I (others NA)

#Prints rows left: 61 
cat("Rows after NSAL + lifetime BP-I restriction:", nrow(nsal), "\n")

#### Search for Lifetime Suicidality Variables ####
#Var/label lookup within subset
lbl_tbl <- tibble::tibble(
  var   = names(nsal),
  label = vapply(nsal, get_label, FUN.VALUE = character(1))
)

#Inspect lifetime/ever suicidality candidates (by label search)
life_candidates <- lbl_tbl %>%
  mutate(label_low = str_to_lower(label)) %>%
  filter(
    str_detect(label_low, "suicid"),
    str_detect(label_low, "ever|lifetime|times attempted|ever attempted|ever thought|ever made|ever plan")
  ) %>%
  mutate(non_missing = map_int(var, ~ sum(!is.na(nsal[[.x]])))) %>%
  arrange(desc(non_missing))

#Prints all lifetime suicidality variables:
cat("\nLifetime suicidality candidates (sorted by coverage):\n")
print(life_candidates, n = 50)

#### Search for 12-month Suicidality Variables ####

#Find the 12-month suicidality items (by label search)
suic_candidates <- lbl_tbl %>%
  mutate(label_low = str_to_lower(label)) %>%
  filter(
    str_detect(label_low, "suicid") &
      (str_detect(label_low, "12") | str_detect(label_low, "past 12") |
         str_detect(label_low, "last 12") | str_detect(label_low, "12 m"))
  ) %>%
  mutate(non_missing = map_int(var, ~ sum(!is.na(nsal[[.x]])))) %>%
  arrange(desc(non_missing))

cat("\n--- Possible 12-month suicidality variables (merged file) ---\n")
print(suic_candidates, n = 50)

#Build the 12-month suicidality outcome inside NSAL + BP-I
suic12_vars <- c("V01995",  # thought in past 12 mths
                 "V01999",  # plan in past 12 mths
                 "V02004")  # attempt in past 12 mths

# clean specials and build component/combined outcomes
nsal <- nsal %>%
  mutate(
    across(all_of(suic12_vars),
           ~ replace(., . %in% c(-9, -8, 97, 98, 99), NA_integer_)),
    suic12_thought = as.integer(.data[[suic12_vars[1]]] == 1L),
    suic12_plan    = as.integer(.data[[suic12_vars[2]]] == 1L),
    suic12_attempt = as.integer(.data[[suic12_vars[3]]] == 1L)
  ) %>%
  mutate(
    any_suic12 = as.integer(
      (suic12_thought == 1L) | (suic12_plan == 1L) | (suic12_attempt == 1L)
    )
  )

cat("\nCoverage per item (non-missing):\n")
print(sapply(suic12_vars, function(v) sum(!is.na(nsal[[v]]))))

cat("\n12-month suicidality (any):\n").   
print(table(nsal$any_suic12, useNA = "ifany"))

cat("\nBreakdown by item (yes counts):\n")
print(colSums(nsal[, c("suic12_thought","suic12_plan","suic12_attempt")] == 1, na.rm = TRUE))

cat("\nExample rows with any 12m suicidality:\n")
nsal %>%
  filter(any_suic12 == 1) %>%
  select(CPESCASE, any_suic12, suic12_thought, suic12_plan, suic12_attempt) %>%
  head(10) %>% print()

#### Realized there were not enough 12-month suicidality outcomes to create a stable model. Fell back to lifetime variables with larger N.

#Lifetime suicidality composites
life_items <- c("V00876", "V00880", "V00882", "V02044")  # ideation, plan, attempt-in-MDE, ever attempt
life_items <- intersect(life_items, names(nsal))

nsal <- nsal %>%
  mutate(across(all_of(life_items),
                ~ replace(., . %in% c(-9, -8, 97, 98, 99), NA_integer_)))

#Recode components as 0/1 with NAs preserved
yes1 <- function(x) as.integer(x == 1L)

comp_mat <- nsal %>%
  transmute(
    suic_life_ideation   = if ("V00876" %in% life_items) yes1(.data[["V00876"]]) else NA_integer_,
    suic_life_plan       = if ("V00880" %in% life_items) yes1(.data[["V00880"]]) else NA_integer_,
    suic_life_attemptMDE = if ("V00882" %in% life_items) yes1(.data[["V00882"]]) else NA_integer_,
    suic_life_attemptEver= if ("V02044" %in% life_items) yes1(.data[["V02044"]]) else NA_integer_
  )

# any lifetime & attempt lifetime with proper NA when all components missing
any_life <- {
  n_obs <- rowSums(!is.na(comp_mat))
  has_any <- as.integer(rowSums(comp_mat, na.rm = TRUE) > 0)
  has_any[ n_obs == 0 ] <- NA_integer_
  has_any
}
attempt_life <- {
  att_mat <- comp_mat[, c("suic_life_attemptMDE","suic_life_attemptEver")]
  n_obs <- rowSums(!is.na(att_mat))
  has_any <- as.integer(rowSums(att_mat, na.rm = TRUE) > 0)
  has_any[ n_obs == 0 ] <- NA_integer_
  has_any
}

nsal <- bind_cols(nsal, comp_mat) %>%
  mutate(
    suic_life_any     = any_life,
    suic_life_attempt = attempt_life
  )

cat("\nCoverage (non-missing) per lifetime item:\n")
print(sapply(life_items, function(v) sum(!is.na(nsal[[v]]))))

cat("\nLifetime suicidality (any):\n")
print(table(nsal$suic_life_any, useNA = "ifany"))

cat("\nLifetime suicide attempt (composite):\n")
print(table(nsal$suic_life_attempt, useNA = "ifany"))

cat("\nBreakdown of 'any' by lifetime components (yes counts):\n")
print(colSums(comp_mat == 1, na.rm = TRUE))

#### Religiosity items & Coverage/Overlap ####
relig4 <- c("V06618","V06614","V06621","V06593")

cov_tbl <- tibble::tibble(
  var         = relig4,
  label       = map_chr(relig4, ~ {lab <- attr(nsal[[.x]], "label"); if (is.null(lab)) .x else as.character(lab)}),
  non_missing = map_int(relig4, ~ sum(!is.na(nsal[[.x]]))),
  pct         = round(non_missing / nrow(nsal) * 100, 1)
)
cat("\nReligiosity coverage in NSAL + BP-I subset:\n")
print(cov_tbl)

nsal <- nsal %>%
  mutate(
    relig_all4     = rowSums(across(all_of(relig4), ~ !is.na(.))) == 4,
    relig_atleast2 = rowSums(across(all_of(relig4), ~ !is.na(.))) >= 2
  )

cat("\nOverlap with outcomes (primary=lifetime any; secondary=lifetime attempt):\n")
print(with(nsal, table(relig_all4,     suic_life_any,     useNA = "ifany")))
print(with(nsal, table(relig_atleast2, suic_life_any,     useNA = "ifany")))
print(with(nsal, table(relig_all4,     suic_life_attempt, useNA = "ifany")))
print(with(nsal, table(relig_atleast2, suic_life_attempt, useNA = "ifany")))

cat("\nRows that have lifetime-any=1 AND all 4 relig items present (peek):\n")
nsal %>%
  filter(suic_life_any == 1, relig_all4) %>%
  transmute(
    CPESCASE,
    V06618 = haven::as_factor(V06618),
    V06614 = haven::as_factor(V06614),
    V06621 = haven::as_factor(V06621),
    V06593 = haven::as_factor(V06593)
  ) %>% print(n = Inf)


##### Flow Chart Visual ####
#Counts from your current objects
library(dplyr)

N_cpes   <- nrow(dat)
N_nsal   <- sum(dat$CPESPROJ == 3, na.rm = TRUE)
N_bpi    <- nrow(nsal)

nsal$suic_life_any <- ifelse(is.infinite(nsal$suic_life_any), NA, nsal$suic_life_any)

N_suic_nonmiss   <- sum(!is.na(nsal$suic_life_any))
N_suic_events    <- sum(nsal$suic_life_any == 1, na.rm = TRUE)
N_relig_all4     <- sum(nsal$relig_all4, na.rm = TRUE)
N_overlap_any    <- sum(nsal$relig_all4 & !is.na(nsal$suic_life_any), na.rm = TRUE)
N_overlap_events <- sum(nsal$relig_all4 & nsal$suic_life_any == 1, na.rm = TRUE)

#Flowchart
library(DiagrammeR); library(glue)

grViz(glue('
digraph flow {{
  graph [rankdir=LR, fontsize=10]
  node  [shape=box, style="rounded,filled", fillcolor="#EEF5FF"]
  edge  [color="#6b6b6b"]

  CPES [label="CPES (N={N_cpes})"]
  NSAL [label="NSAL (N={N_nsal})"]
  BPI  [label="Lifetime BP-I (N={N_bpi})"]
  SUIC [label="Lifetime suicidality measured\\n(N={N_suic_nonmiss}; events={N_suic_events})"]
  REL  [label="All 4 relig items present (N={N_relig_all4})"]
  OVER [label="Overlap (both measured)\\nN={N_overlap_any}\\nEvents in overlap={N_overlap_events}"]

  CPES -> NSAL -> BPI
  BPI  -> SUIC
  BPI  -> REL
  SUIC -> OVER
  REL  -> OVER
}}'))


#### Religiosity Index & Visuals ####
suppressPackageStartupMessages({
  library(ggplot2)
})

# Build a single religiosity index
# Mapping:
# V06618: 1=very, 2=fairly, 3=not too, 4=not at all  (High ->1, Low->0)
# V06614: 1=nearly every day, 2=≥1/wk, 3=few/m, 4=≥1/m, 5=few/yr, 6=never (more ->1)
# V06621: 1=very religious, 2=fairly, 3=not too, 4=not at all (more ->1)
# V06593: 1=yes attended since 18, 5=no (yes ->1)
nsal <- nsal %>%
  mutate(
    relig_imp_num = case_when(V06618 %in% c(1,2) ~ 1,
                              V06618 %in% c(3,4) ~ 0,
                              TRUE ~ NA_real_),
    pray_num      = case_when(V06614 %in% c(1,2) ~ 1,
                              V06614 %in% c(3,4,5) ~ 0.5,
                              V06614 == 6          ~ 0,
                              TRUE ~ NA_real_),
    self_rel_num  = case_when(V06621 == 1 ~ 1,
                              V06621 == 2 ~ 2/3,
                              V06621 == 3 ~ 1/3,
                              V06621 == 4 ~ 0,
                              TRUE ~ NA_real_),
    attend_num    = case_when(V06593 == 1 ~ 1,
                              V06593 == 5 ~ 0,
                              TRUE ~ NA_real_),
    relig_items_answered = rowSums(across(c(relig_imp_num, pray_num, self_rel_num, attend_num),
                                          ~ !is.na(.))),
    relig_index = ifelse(relig_items_answered >= 3,
                         rowMeans(across(c(relig_imp_num, pray_num, self_rel_num, attend_num)),
                                  na.rm = TRUE),
                         NA_real_),
    relig_z = as.numeric(scale(relig_index))
  )

#Analytic cohort:
anal <- nsal %>%
  filter(!is.na(suic_life_any), relig_all4, !is.na(relig_index)) %>%
  mutate(
    r_tertile = factor(
      dplyr::ntile(relig_index + runif(dplyr::n(), -1e-9, 1e-9), 3),
      labels = c("Low","Mid","High")
    )
  )


cat("\nAnalysis N (overlap):", nrow(anal),
    " | events:", sum(anal$suic_life_any == 1, na.rm = TRUE), "\n")

#Visuals:

#Component bar of lifetime suicidality (in the whole BP-I subset where measured)
comp_long <- nsal %>%
  filter(!is.na(suic_life_any)) %>%
  transmute(
    ideation = suic_life_ideation,
    plan     = suic_life_plan,
    attempt  = suic_life_attempt
  ) |>
  tidyr::pivot_longer(everything(), names_to = "component", values_to = "yes") |>
  dplyr::summarise(n_yes = sum(yes == 1, na.rm = TRUE), .by = component)

p1 <- ggplot(comp_long, aes(x = component, y = n_yes)) +
  geom_col() +
  labs(title = "Lifetime suicidality components (BP-I in NSAL)",
       x = NULL, y = "Yes count") +
  theme_minimal(base_size = 12)

print(p1)

library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)

comp_long <- nsal %>%
  filter(!is.na(suic_life_any)) %>%               
  transmute(
    ideation = suic_life_ideation,
    plan     = suic_life_plan,
    attempt  = suic_life_attempt
  ) %>%
  pivot_longer(everything(), names_to = "component", values_to = "yes") %>%
  # summarize counts + denominators for each component
  summarise(
    n      = sum(!is.na(yes)),
    n_yes  = sum(yes == 1, na.rm = TRUE),
    prop   = n_yes / n,
    .by    = component
  ) %>%
  # nice labels and ordering
  mutate(
    component = factor(component,
                       levels = c("ideation","plan","attempt"),
                       labels = c("Ideation","Plan","Attempt")),
    label_counts   = as.character(n_yes),                                 # just counts
    label_full     = paste0(n_yes, "/", n, " (", percent(prop, 1), ")")  # counts + %
  )

#Visual:
p1_counts <- ggplot(comp_long, aes(x = component, y = n_yes)) +
  geom_col(width = 0.7) +
  geom_text(aes(label = label_counts), vjust = -0.3, size = 4) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(title = "Lifetime suicidality components (BP-I in NSAL)",
       x = NULL, y = "Yes count") +
  theme_minimal(base_size = 12)
print(p1_counts)

p1_full <- ggplot(comp_long, aes(x = component, y = n_yes)) +
  geom_col(width = 0.7) +
  geom_text(aes(label = label_full), vjust = -0.3, size = 3.6) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.20))) +
  labs(title = "Lifetime suicidality components (BP-I in NSAL)",
       x = NULL, y = "Yes count") +
  theme_minimal(base_size = 12)
print(p1_full)

#Event rate by religiosity tertile (in analysis overlap N≈40)
rate_tbl <- anal |>
  dplyr::summarise(
    n      = dplyr::n(),
    events = sum(suic_life_any == 1, na.rm = TRUE),
    prop   = events / n,
    label  = paste0(events, "/", n),  
    .by    = r_tertile
  )

p2 <- ggplot(rate_tbl, aes(x = r_tertile, y = prop)) +
  geom_col() +
  # put the counts just above each bar:
  geom_text(aes(y = prop + 0.03, label = label), vjust = 0, size = 4) +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 1),
    limits = c(0, 1),                       
    expand = expansion(mult = c(0, 0.05))   
  ) +
  labs(
    title = "Lifetime suicidality (any) by religiosity tertile",
    x = "Religiosity", y = "Event rate"
  ) +
  theme_minimal(base_size = 12)

print(p2)



#### First Model: Firth Logistic & MLE for Comparison ####
#Helper to print ORs nicely
or_table <- function(fit, use_profile = FALSE) {
  cf <- coef(fit);  # vector
  SE <- sqrt(diag(vcov(fit)))
  if (!use_profile) {
    ci <- cbind(cf - 1.96*SE, cf + 1.96*SE)
  } else {
    ci <- confint(fit)  # slow, profile CI
  }
  tibble::tibble(
    term = names(cf),
    OR   = exp(cf),
    low  = exp(ci[,1]),
    high = exp(ci[,2])
  )
}


library(logistf)
#Primary predictor = relig_z (per +1 SD religiosity)
#Firth
if (requireNamespace("logistf", quietly = TRUE)) {
  fit_firth <- logistf::logistf(suic_life_any ~ relig_z, data = anal)
  cat("\nFirth logistic (penalized) on overlap:\n"); print(summary(fit_firth))
  firth_or <- tibble::tibble(
    term = names(fit_firth$coefficients),
    OR   = exp(fit_firth$coefficients),
    low  = exp(fit_firth$ci.lower),
    high = exp(fit_firth$ci.upper)
  )
  cat("\nFirth ORs (95% CI):\n"); print(firth_or)
} else {
  cat("\nPackage 'logistf' not installed → running plain MLE glm() only.\n")
}

#Plain MLE (for reference)
fit_mle <- glm(suic_life_any ~ relig_z, data = anal, family = binomial())
cat("\nMLE logistic on overlap:\n"); print(summary(fit_mle))
cat("\nMLE ORs (Wald 95% CI):\n"); print(or_table(fit_mle))


#### Running Model to include Age and Sex ####
#Clean covariates (Age = V07306, Sex = V09036) and add to analytic cohort
anal <- anal %>%
  mutate(
    age_raw  = special_na(V07306),
    age_num  = suppressWarnings(as.numeric(age_raw)),
    age_z    = as.numeric(scale(age_num)),           # z-score (mean 0, sd 1)
    sex_raw  = special_na(V09036),
    # CPES/NSAL convention is typically 1=Male, 2=Female
    sex_male = dplyr::case_when(sex_raw == 1L ~ 1L,
                                sex_raw == 2L ~ 0L,
                                TRUE          ~ NA_integer_)
  )

# Quick coverage check inside the overlap set you’ll model
cat("\nCoverage in overlap set:\n")
print(tibble::tibble(
  N_overlap = nrow(anal),
  N_events  = sum(anal$suic_life_any == 1, na.rm = TRUE),
  N_age     = sum(!is.na(anal$age_z)),
  N_sex     = sum(!is.na(anal$sex_male)),
  N_both    = sum(!is.na(anal$age_z) & !is.na(anal$sex_male))
))

#Helper to fit Firth and return a tidy OR table
or_table_firth <- function(fit) {
  ci <- suppressMessages(confint(fit))
  tibble::tibble(
    term = names(coef(fit)),
    OR   = exp(coef(fit)),
    low  = exp(ci[, 1]),
    high = exp(ci[, 2])
  )
}

#Fit Adjusted Firth models:

# (A) relig_z + age
dat_A <- anal %>% dplyr::filter(!is.na(suic_life_any), !is.na(relig_z), !is.na(age_z))
fit_A <- logistf::logistf(suic_life_any ~ relig_z + age_z, data = dat_A)
cat("\nFirth: suic_life_any ~ relig_z + age_z  (n=", nrow(dat_A),
    ", events=", sum(dat_A$suic_life_any==1), ")\n", sep = "")
print(or_table_firth(fit_A))

# (B) relig_z + sex
dat_B <- anal %>% dplyr::filter(!is.na(suic_life_any), !is.na(relig_z), !is.na(sex_male))
fit_B <- logistf::logistf(suic_life_any ~ relig_z + sex_male, data = dat_B)
cat("\nFirth: suic_life_any ~ relig_z + sex_male  (n=", nrow(dat_B),
    ", events=", sum(dat_B$suic_life_any==1), ")\n", sep = "")
print(or_table_firth(fit_B))

# (C) relig_z + age + sex
dat_C <- anal %>% dplyr::filter(!is.na(suic_life_any), !is.na(relig_z),
                                !is.na(age_z), !is.na(sex_male))
fit_C <- logistf::logistf(suic_life_any ~ relig_z + age_z + sex_male, data = dat_C)
cat("\nFirth: suic_life_any ~ relig_z + age_z + sex_male  (n=", nrow(dat_C),
    ", events=", sum(dat_C$suic_life_any==1), ")\n", sep = "")
print(or_table_firth(fit_C))

# (A) relig_z + age
summary(fit_A)
# (B) relig_z + sex
summary(fit_B)
# (C) relig_z + age + sex
summary(fit_C)