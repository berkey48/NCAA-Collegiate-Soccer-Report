# Data Directory

This folder is intentionally left empty of raw data files.

All data used in this project originates from a GPS/Athlete Management System (AMS) and contains athlete performance records. Even though athlete names have been pseudonymized, raw session data is not published publicly out of an abundance of caution for athlete privacy.

---

## Required Files

To run any of the dashboards or reports, place the following CSV files in this directory:

---

### `training_data_anon.csv`
Session-level GPS and internal load data. One row per athlete per session.

| Column | Type | Description |
|---|---|---|
| `athlete_name` | character | Pseudonymized athlete identifier |
| `start_date` | character (MM/DD/YYYY) | Date of the session |
| `start_time` | character | Time the session began |
| `session_load` | numeric | Internal training load (arbitrary units) |
| `distance_yds` | numeric | Total distance covered in yards |
| `no_of_high_intensity_events` | numeric | Count of efforts exceeding 60% of top speed |
| `top_speed_mph` | numeric | Athlete's peak speed recorded in the session |
| `session_type` | character | e.g., `"Training Session"`, `"Match Session"` |
| `tags` | character | Session phase tags — e.g., `"MD-1"`, `"MD-2"`, `"MD-0"` |

---

### `roster_map_anon.csv`
Maps pseudonymized athlete names to their positional group.

| Column | Type | Description |
|---|---|---|
| `athlete_name` | character | Must match `training_data_anon.csv` exactly |
| `unit` | character | Position group: `"Defenders"`, `"Midfielders"`, `"Forwards"`, `"Goalkeepers"` |

---

### `minutes_data_anon.csv`
Match minutes played per athlete per game day.

| Column | Type | Description |
|---|---|---|
| `join_name` | character | Pseudonymized athlete identifier (used to join to `athlete_name`) |
| `start_date` | character (YYYY-MM-DD) | Match date |
| `minutes` | numeric | Minutes played; `0` or `NA` = Did Not Play (DNP) |

---

### `WSoccResults.csv`
Season match results used to correlate training load with outcomes.

| Column | Type | Description |
|---|---|---|
| `start_date` | character (MM/DD/YYYY) | Match date |
| `opponent` | character | Opponent team name |
| `result` | character | Match result: `"Win"`, `"Loss"`, or `"Tie"` |

---

## Privacy Note

This project follows a **pseudonymization-first** approach to athlete data:

- No real names, jersey numbers, or identifying information are used
- Individual athlete data is visible only within the dashboards, which are intended for internal coaching staff use

If adapting this project for your own organization, ensure your data sharing practices comply with any applicable athlete privacy agreements or institutional policies.
