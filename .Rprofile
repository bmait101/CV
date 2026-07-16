source("renv/activate.R")

# The shell this project gets rendered from (plain terminal / Rscript /
# targets, as opposed to RStudio, which sets this for you) may be running in
# the "C" locale, which makes R mangle non-ASCII characters (accented
# author names, etc.) when they pass through cat()/system2(). Force a UTF-8
# locale so text stays intact through the whole render pipeline.
if (!l10n_info()[["UTF-8"]]) {
  try(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"), silent = TRUE)
}

# This project has no separate system-wide pandoc install; the only pandoc
# available is the one bundled with Quarto. rmarkdown/vitae's citation
# helpers (vitae::bibliography_entries(), used for the CV's bibliography
# sections) look for pandoc via the RSTUDIO_PANDOC env var, and need to see
# a modern (>= 2.11) pandoc to avoid falling back to the long-deprecated
# standalone `pandoc-citeproc` binary, which no longer ships with pandoc.
# RStudio sets this env var itself when you Knit from the IDE, but it's not
# set when rendering via `quarto render` / `targets::tar_make()` from a
# plain terminal - so point it at Quarto's bundled pandoc here instead.
if (Sys.getenv("RSTUDIO_PANDOC") == "") {
  quarto_bin <- Sys.which("quarto")
  if (nzchar(quarto_bin)) {
    quarto_root <- dirname(dirname(normalizePath(quarto_bin)))
    arch <- if (grepl("arm64|aarch64", Sys.info()[["machine"]])) "aarch64" else "x86_64"
    pandoc_dir <- file.path(quarto_root, "bin", "tools", arch)
    if (file.exists(file.path(pandoc_dir, "pandoc"))) {
      Sys.setenv(RSTUDIO_PANDOC = pandoc_dir)
    }
  }
}
