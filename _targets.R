library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("RefManageR", "dplyr", "gcite", "quarto", "readr", "cranlogs")
)

# Run the R scripts in the R/ folder containing functions:
tar_source()

# Bib files and CSVs that should trigger a re-render when edited, even
# though the .qmd files read them directly rather than via tar_load().
data_files <- c(
  "bibs/journal_articles.bib",
  "bibs/conf_presentations.bib",
  "bibs/pkgs.bib",
  "bibs/tech_reports.bib",
  "bibs/theses.bib",
  "bibs/preprints.bib",
  "bibs/working.bib",
  "csl/apa_cv.csl",
  "lua/names.lua",
  "grant_income.csv",
  "invited_talks.csv",
  "guest_lecs.csv",
  "media.csv",
  "workshops.csv"
)

list(
  # Current date - re-checked every run, but its value (and so anything
  # downstream) only actually changes once per day, so Google Scholar
  # isn't re-scraped on every render within the same day.
  tar_target(date, Sys.Date(), cue = tar_cue(mode = "always")),
  # Google Scholar citation stats
  tar_target(bmm_cite, get_gcites(date)),
  tar_target(bmm_cite_papers, get_scholar_cites(date)),
  # R package download stats
  tar_target(bmm_pkgs, get_bmm_pkgs(date)),
  # Generate CV documents
  tar_quarto(cv_full, "BryanMaitlandCV.qmd", extra_files = data_files),
  tar_quarto(cv_1page, "BryanMaitland_1page.qmd", extra_files = data_files)
)
