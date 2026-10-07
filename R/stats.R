# Load Google Scholar and CRAN download stats for the CV documents.
#
# The stats are cached in data/cv_stats.rds (committed to git) and refreshed
# at most once per day, so rendering all three CVs back-to-back only scrapes
# Google Scholar once. If a refresh fails (no network, Scholar blocking the
# request, a work firewall), the last cached values are used instead, so a
# render never fails just because the stats couldn't be fetched.
load_cv_stats <- function(cache = here::here("data/cv_stats.rds")) {
  cached <- if (file.exists(cache)) readRDS(cache) else NULL
  if (!is.null(cached) && identical(cached$date, Sys.Date())) {
    return(cached)
  }

  fresh <- tryCatch(
    list(
      date = Sys.Date(),
      bmm_cite = get_gcites(),
      bmm_cite_papers = get_scholar_cites(),
      bmm_pkgs = get_bmm_pkgs(Sys.Date())
    ),
    error = function(e) {
      warning("Couldn't refresh CV stats, using cached values: ", conditionMessage(e))
      NULL
    }
  )
  if (is.null(fresh)) {
    if (is.null(cached)) stop("No cached CV stats and refresh failed.")
    return(cached)
  }

  dir.create(dirname(cache), showWarnings = FALSE)
  saveRDS(fresh, cache)
  fresh
}
