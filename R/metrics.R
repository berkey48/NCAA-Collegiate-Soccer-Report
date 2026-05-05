# =============================================================================
# metrics.R
# Shared data loading, processing, and branding for the Soccer Performance
# Analytics . Source this file at the top of each Rmd:
#   source("../R/metrics.R")
# =============================================================================

library(dplyr)
library(tidyverse)
library(janitor)
library(lubridate)
library(slider)

# -----------------------------------------------------------------------------
# 1. VISUAL BRANDING
# -----------------------------------------------------------------------------

color_high   <- "#990000"   # High load / match day
color_normal <- "#000000"   # Normal load
color_below  <- "#808080"   # Below baseline

load_status_colors <- c(
  "High"   = color_high,
  "Normal" = color_normal,
  "Below"  = color_below
)

position_colors <- c(
  "Defenders"   = "grey15",
  "Midfielders" = "#95A5A6",
  "Forwards"    = "#990000",
  "Goalkeepers" = "#DAA520"
)

density_colors <- c(
  "MD-2"  = "#000000",
  "MD-1"  = "#808080",
  "MATCH" = "#990000"
)

# -----------------------------------------------------------------------------
# 2. DATA LOADING
# -----------------------------------------------------------------------------

load_raw_data <- function(data_dir = "../data") {
  
  df_training <- read_csv(file.path(data_dir, "training_data_anon.csv")) %>%
    clean_names() %>%
    mutate(
      start_date   = mdy(start_date),
      session_load = as.numeric(session_load),
      distance_yds = as.numeric(distance_yds),
      hi_events    = as.numeric(no_of_high_intensity_events)
    )
  
  roster_map <- read_csv(file.path(data_dir, "roster_map_anon.csv")) %>%
    clean_names() %>%
    mutate(athlete_name = str_to_lower(str_trim(athlete_name)))
  
  df_minutes <- read_csv(file.path(data_dir, "minutes_data_anon.csv")) %>%
    clean_names() %>%
    filter(!is.na(join_name), join_name != "") %>%
    mutate(
      start_date   = as.Date(start_date),
      minutes      = as.numeric(minutes),
      athlete_name = str_to_lower(str_trim(join_name))
    ) %>%
    filter(!is.na(minutes)) %>%
    select(athlete_name, start_date, minutes)
  
  df_results <- read_csv(file.path(data_dir, "WSoccResults.csv")) %>%
    clean_names() %>%
    mutate(
      start_date   = mdy(start_date),
      result       = str_to_title(str_trim(result)),
      result_clean = case_when(
        str_detect(result, "Win")  ~ "W",
        str_detect(result, "Tie")  ~ "T",
        str_detect(result, "Loss") ~ "L",
        TRUE ~ NA_character_
      )
    )
  
  list(
    training = df_training,
    roster   = roster_map,
    minutes  = df_minutes,
    results  = df_results
  )
}

# -----------------------------------------------------------------------------
# 3. SESSION TAGGING
# -----------------------------------------------------------------------------

tag_sessions <- function(df) {
  df %>%
    mutate(
      session_tag = case_when(
        str_detect(str_to_lower(tags), "md-0|match") ~ "MATCH",
        str_detect(str_to_lower(tags), "md-1")       ~ "MD-1",
        str_detect(str_to_lower(tags), "md-2")       ~ "MD-2",
        str_detect(str_to_lower(tags), "md-3")       ~ "MD-3",
        str_detect(str_to_lower(tags), "md-4")       ~ "MD-4",
        TRUE ~ "Untagged"
      ),
      session_tag  = factor(session_tag, levels = c("MD-4", "MD-3", "MD-2", "MD-1", "MATCH", "Untagged")),
      session_type = ifelse(session_tag == "MATCH", "Match Session", "Training Session")
    )
}

# -----------------------------------------------------------------------------
# 4. ROLLING LOAD METRICS (ACWR)
# -----------------------------------------------------------------------------
# Computes 7-day acute load, 28-day chronic load, ACWR, and load status.
# Joins roster and minutes data before calculating.

build_rolling_metrics <- function(df_training, roster_map, df_minutes,
                                  min_load = 10) {
  df_training %>%
    filter(session_load > min_load) %>%
    mutate(athlete_name = str_to_lower(str_trim(athlete_name))) %>%
    tag_sessions() %>%
    left_join(roster_map, by = "athlete_name") %>%
    left_join(df_minutes, by = c("athlete_name", "start_date")) %>%
    mutate(minutes = replace_na(minutes, 0)) %>%
    arrange(athlete_name, start_date) %>%
    group_by(athlete_name) %>%
    mutate(
      chronic_load = slide_index_dbl(
        session_load, .i = start_date,
        .f = ~mean(.x, na.rm = TRUE),
        .before = days(28), .complete = FALSE
      ),
      acute_load = slide_index_dbl(
        session_load, .i = start_date,
        .f = ~mean(.x, na.rm = TRUE),
        .before = days(7), .complete = FALSE
      ),
      acwr = ifelse(
        is.finite(acute_load / chronic_load),
        acute_load / chronic_load,
        NA_real_
      )
    ) %>%
    ungroup() %>%
    mutate(
      load_status = case_when(
        acwr > 1.5 ~ "High",
        acwr < 0.8 ~ "Below",
        TRUE       ~ "Normal"
      ),
      hi_density = hi_events / (distance_yds / 1000),
      session_id = paste(start_date, start_time)
    )
}

# -----------------------------------------------------------------------------
# 5. HELPER: IDENTIFY CORE PLAYERS
# -----------------------------------------------------------------------------
# Core players = averaged >= 60 minutes per match day appearance.

get_core_players <- function(df_rolling, min_avg_minutes = 60) {
  df_rolling %>%
    filter(str_detect(as.character(session_tag), "MATCH")) %>%
    group_by(athlete_name) %>%
    summarise(avg_mins = mean(as.numeric(minutes), na.rm = TRUE), .groups = "drop") %>%
    filter(avg_mins >= min_avg_minutes) %>%
    pull(athlete_name)
}

# -----------------------------------------------------------------------------
# 6. HELPER: VALID SESSION IDS
# -----------------------------------------------------------------------------
# Returns session IDs with at least `min_athletes` athletes present.
# Used to filter out incomplete or test sessions in the PDF report.

get_valid_sessions <- function(df_rolling, min_athletes = 5) {
  df_rolling %>%
    group_by(session_id) %>%
    filter(n() >= min_athletes) %>%
    summarise(start_date = first(start_date), .groups = "drop") %>%
    arrange(start_date) %>%
    pull(session_id)
}
