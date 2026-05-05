# NCAA Women's Soccer — Performance Analytics

A multi-format performance analytics system built for NCAA Women's Soccer, designed to help coaching and high-performance staff monitor training load, manage fatigue, and optimize match preparation.

> ⚠️ All athlete names have been anonymized. Data is presented at positional and group levels only to protect individual privacy.

---

## 📁 Project Structure

| File | Type | Purpose |
|---|---|---|
| `clean_report.Rmd` | PDF Report | Season-long retrospective analysis with executive summary and recommendations |
| `Dash_shiny.Rmd` | Shiny Dashboard | Live, reactive dashboard for in-season monitoring |
| `Dash_crosstalk.Rmd` | Static HTML Dashboard | Self-contained, shareable dashboard with linked interactive filters |

---

## 📊 What It Does

### 📄 PDF Season Report (`clean_report.Rmd`)
A complete end-of-season performance review compiled into a formatted PDF. Sections include:

- **Executive Summary** — Key findings and initial recommendations for staff
- **Graph Key** — Visual legend for interpreting all training and match day charts
- **Weekly Load Recaps** — Rolling positional summaries comparing weekly load to each athlete's 28-day chronic baseline
- **Daily Training & Match Day Breakdowns** — Per-session bar charts showing load, distance, and high-intensity (HI) events for every athlete
- **Core Player Trends** — Load and HI analysis for players averaging 60+ minutes per match, correlated with match outcomes (Win/Tie/Loss)
- **Intensity Build-Up Analysis** — HI density (events per 1,000 yards) trajectories from MD-2 through match day, by result
- **Positional Workload Trends** — Average load and intensity by position group across MD-3, MD-2, and MD-1
- **Optimized Schedule Template** — Evidence-based Thursday/Sunday conference match week periodization framework

---

### 📱 Shiny Dashboard (`Dash_shiny.Rmd`)
A reactive, server-rendered dashboard for in-season use. Filters update all visualizations in real time.

**Filters:**
- Position group (Defenders, Midfielders, Forwards, Goalkeepers)
- Date range
- Session type (Training / Match)

**Dashboard Tabs:**
- **7-Day Load Table** — Acute:Chronic Workload Ratio (ACWR) heatmap table per athlete, color-coded from green (safe) to red (elevated)
- **Daily Load Timeline** — Beeswarm scatter plot with match day markers; color-coded by load status (High / Normal / Below)
- **Intensity Density** — Boxplot of HI events per 1,000 yards across MD-2, MD-1, and Match Day sessions
- **Volume vs. Intensity Map** — Scatter plot by position group identifying "heavy movers" (high load, low HI output) as a fatigue signal
- **Recent Session Summary** — Athlete-level summary table with total load, average HI events, and top speed

---

### 🌐 Crosstalk HTML Dashboard (`Dash_crosstalk.Rmd`)
A fully self-contained, static HTML file — no server required. Designed to be shared directly with coaches or staff as a single file.

**Filters:**
- Date range slider
- Position group checkboxes (linked across all panels)

**Dashboard Tabs:**
- **Daily Load by Athlete** — Interactive scatter plot of session load over time, colored by position
- **Load vs. Volume** — HI events plotted against total session load, by position
- **Intensity Density** — Boxplot with jittered points showing HI density across MD-2, MD-1, and Match sessions
- **Session Summary Table** — Filterable, exportable table (CSV/Excel) with ACWR, HI density, and top speed; load status highlighted in red/grey

---

## 🔑 Key Metrics Defined

| Metric | Definition |
|---|---|
| **Session Load** | Internal training load (arbitrary units) from GPS/AMS system |
| **ACWR** | Acute:Chronic Workload Ratio — 7-day avg load / 28-day avg load |
| **HI Events** | Number of high-intensity actions (>60% of top speed) per session |
| **HI Density** | HI events normalized by distance (per 1,000 yards) |
| **Load Status** | High (ACWR >1.5), Normal, or Below (ACWR <0.8) |
| **MD-X** | Match Day minus X — e.g., MD-2 = two days before a match |

---

## 🛠️ Tech Stack

- **Language:** R
- **Frameworks:** flexdashboard, Shiny
- **Visualization:** ggplot2, plotly, patchwork, ggbeeswarm
- **Tables:** gt, DT
- **Data Processing:** dplyr, tidyr, lubridate, slider, janitor
- **Interactivity:** crosstalk (linked brushing across plots and tables)
- **Output:** PDF (LaTeX), Shiny App, self-contained HTML

---

## 📂 Required Data Files

The following anonymized CSV files are required to render all three outputs:

| File | Contents |
|---|---|
| `training_data_anon.csv` | Session-level GPS and load data (athlete, date, load, distance, HI events, top speed, tags) |
| `roster_map_anon.csv` | Athlete-to-position mapping |
| `minutes_data_anon.csv` | Match minutes played per athlete per game |
| `WSoccResults.csv` | Match results (date, opponent, result) |

> All athlete names have been pseudonymized. No personally identifiable information is included.

---

## 📊 Live Demos
- [Shiny Dashboard](https://j-berke48.shinyapps.io/Dash_shiny/)
- [Static HTML Dashboard](https://berkey48.github.io/NCAA-Collegiate-Soccer-Report/dashboards/Dash_crosstalk.html)
- [PDF Season Report](./report/clean_report.pdf)

---

## 💡 Key Findings (2025 Season)

- **HI Density as a win predictor** — High-speed events per 1,000 yards was the strongest differentiator between winning and non-winning weeks, particularly when preceded by an effective MD-2 intensity stimulus and MD-1 load reduction.
- **Travel fatigue impact** — Back-to-back away matches were associated with a higher rate of ties and losses, suggesting MD-2 session design needs to account for travel load.
- **Tapering consistency** — Weeks with insufficient load reduction from MD-2 to MD-1 correlated with ~31% fewer match-day high-intensity events.

---

*Built as part of the M.S. Kinesiology (Data Science Track) program at Seattle University.*
