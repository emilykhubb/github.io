### Load and View Data ####
library(tidyverse)
library(lubridate)

# Load data
price.history <- read_csv("price_history.csv")
properties    <- read_csv("properties_main.csv")

# View data
View(price.history)
View(properties)

glimpse(price.history)
glimpse(properties)
names(price.history)
names(properties)

#### Data Prep (clean + join) ####

# 1) Clean transaction history (sale-level table)
sales <- price.history %>%
  transmute(
    property_id = as.character(property_id),
    sale_date   = as.Date(deedDate),
    
    # Parse "£540,000" -> 540000
    price = displayPrice %>%
      str_replace_all("[^0-9]", "") %>%
      as.numeric(),
    
    new_build_sale = as.character(newBuild),
    tenure_sale    = as.character(tenure)
  ) %>%
  filter(!is.na(property_id), !is.na(sale_date), !is.na(price), price > 0)

# 2) Clean property table (property-level attributes)
props <- properties %>%
  transmute(
    property_id   = as.character(property_id),
    address       = as.character(address),
    property_type = as.character(property_type),
    tenure_prop   = as.character(tenure),
    new_build_prop = as.character(new_build)
  ) %>%
  mutate(
    # Extract UK postcode from address (best-effort)
    postcode = str_extract(
      str_to_upper(address),
      "\\b[A-Z]{1,2}[0-9][0-9A-Z]?\\s*[0-9][A-Z]{2}\\b"
    ),
    postcode_area = str_extract(postcode, "^[A-Z]{1,2}")
  )

# 3) Create the joined analysis dataset (DO NOT name it df to avoid collisions)
analysis_df <- sales %>%
  left_join(props, by = "property_id") %>%
  mutate(
    sale_year = year(sale_date),
    
    # Unified fields (keep Unknown rather than NA)
    tenure_final = coalesce(tenure_sale, tenure_prop),
    tenure_final = if_else(is.na(tenure_final), "Unknown", tenure_final),
    
    new_build_final = coalesce(new_build_sale, new_build_prop),
    new_build_final = if_else(is.na(new_build_final), "Unknown", new_build_final),
    
    property_type_final = if_else(is.na(property_type), "Unknown", property_type)
  )

# 4) Sanity check
analysis_df %>%
  summarise(
    n_sales = n(),
    n_properties = n_distinct(property_id),
    missing_postcode_area = sum(is.na(postcode_area)),
    missing_property_type_final = sum(is.na(property_type_final)),
    missing_tenure_final = sum(is.na(tenure_final)),
    missing_new_build_final = sum(is.na(new_build_final))
  )

analysis_df %>%
  select(property_id, sale_date, price, postcode_area,
         property_type_final, tenure_final, new_build_final) %>%
  glimpse()



#### Question 3 ####
# Q3: Quick resales (within 2 years and 5 years)

q3_events <- analysis_df %>%
  arrange(property_id, sale_date) %>%
  group_by(property_id) %>%
  mutate(
    next_sale_date = lead(sale_date),
    next_price     = lead(price),
    
    # Time between consecutive sales (years)
    gap_years = as.numeric(next_sale_date - sale_date) / 365.25,
    
    # Percent change between consecutive sales
    pct_change = (next_price - price) / price
  ) %>%
  ungroup() %>%
  filter(
    !is.na(next_sale_date),
    !is.na(next_price),
    next_price > 0
  ) %>%
  mutate(
    quick_2yr = gap_years <= 2,
    quick_5yr = gap_years <= 5
  )

# Property-level indicators (does a property ever resell quickly?)
q3_property_flags <- q3_events %>%
  group_by(property_id) %>%
  summarise(
    has_2yr_resale = any(quick_2yr),
    has_5yr_resale = any(quick_5yr),
    .groups = "drop"
  )

# Final Q3 summary table
q3_summary <- tibble(
  window = c("≤ 2 years", "≤ 5 years"),
  share_of_properties = c(
    mean(q3_property_flags$has_2yr_resale),
    mean(q3_property_flags$has_5yr_resale)
  ),
  median_pct_gain_events_only = c(
    median(q3_events$pct_change[q3_events$quick_2yr], na.rm = TRUE),
    median(q3_events$pct_change[q3_events$quick_5yr], na.rm = TRUE)
  ),
  n_qualifying_events = c(
    sum(q3_events$quick_2yr),
    sum(q3_events$quick_5yr)
  )
) %>%
  mutate(
    share_of_properties = share_of_properties * 100,
    median_pct_gain_events_only = median_pct_gain_events_only * 100
  )

q3_summary

write_csv(q3_summary, "Q3_quick_resales_summary.csv")

getwd()
list.files(pattern = "\\.csv$")

names(q3_summary)

# Q3 metrics by postcode area
q3_area_summary <- q3_events %>%
  group_by(postcode_area) %>%
  summarise(
    n_events = n(),
    
    share_quick_2yr = mean(quick_2yr),
    share_quick_5yr = mean(quick_5yr),
    
    median_gain_2yr = median(pct_change[quick_2yr], na.rm = TRUE),
    median_gain_5yr = median(pct_change[quick_5yr], na.rm = TRUE)
  ) %>%
  mutate(
    share_quick_2yr = share_quick_2yr * 100,
    share_quick_5yr = share_quick_5yr * 100,
    median_gain_2yr = median_gain_2yr * 100,
    median_gain_5yr = median_gain_5yr * 100
  ) %>%
  filter(n_events >= 50) %>%
  arrange(desc(share_quick_2yr))

q3_area_summary

write_csv(q3_area_summary, "Q3_quick_resales_by_postcode_area.csv")

names(q3_area_summary)

#### Question 3 Tableau Geo Join ####
# --- Create postcode_area latitude/longitude lookup for Tableau maps ---
# Source of full UK postcode centroids (lat/lon): dwyl/uk-postcodes-latitude-longitude-complete-csv (zipped CSV)

library(tidyverse)

# 0) Make sure your joined dataset exists and contains a full postcode column named `postcode`
# (This was created in your props step via regex extraction.)
stopifnot(exists("analysis_df"))
stopifnot("postcode" %in% names(analysis_df))
stopifnot("postcode_area" %in% names(analysis_df))

# 1) Collect the unique postcodes actually present in your dataset (so we don't keep unnecessary rows)
postcodes_in_data <- analysis_df %>%
  transmute(
    postcode_clean = postcode %>%
      str_to_upper() %>%
      str_replace_all("\\s+", "")   # remove spaces (e.g., "AB10 1XG" -> "AB101XG")
  ) %>%
  filter(!is.na(postcode_clean)) %>%
  distinct(postcode_clean)

# 2) Download + unzip the UK postcode lat/lon file (one-time per run)
zip_url  <- "https://raw.githubusercontent.com/dwyl/uk-postcodes-latitude-longitude-complete-csv/master/ukpostcodes.csv.zip"
zip_path <- file.path(tempdir(), "ukpostcodes.csv.zip")
csv_path <- file.path(tempdir(), "ukpostcodes.csv")

download.file(zip_url, zip_path, mode = "wb", quiet = TRUE)
unzip(zip_path, exdir = tempdir())

# 3) Read the postcode lat/lon lookup and keep only postcodes we actually need
# The dwyl file columns are: id, postcode, latitude, longitude
pc_lookup <- readr::read_csv(csv_path, show_col_types = FALSE) %>%
  transmute(
    postcode_clean = postcode %>%
      str_to_upper() %>%
      str_replace_all("\\s+", ""),
    latitude  = as.numeric(latitude),
    longitude = as.numeric(longitude)
  ) %>%
  filter(!is.na(postcode_clean), !is.na(latitude), !is.na(longitude))

pc_lookup_needed <- postcodes_in_data %>%
  inner_join(pc_lookup, by = "postcode_clean") %>%
  mutate(
    postcode_area = str_extract(postcode_clean, "^[A-Z]{1,2}")
  )

# 4) Build centroid (representative point) per postcode_area by averaging postcode centroids
postcode_area_centroids <- pc_lookup_needed %>%
  group_by(postcode_area) %>%
  summarise(
    n_postcodes_matched = n(),
    latitude  = mean(latitude, na.rm = TRUE),
    longitude = mean(longitude, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(postcode_area)

# 5) Export for Tableau
write_csv(postcode_area_centroids, "postcode_area_centroids_for_tableau.csv")

# Optional: quick check
postcode_area_centroids
