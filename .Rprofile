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
    # Search rather than guess the exact subfolder: Quarto's internal layout
    # differs by OS/arch (e.g. macOS nests it under bin/tools/<arch>/pandoc,
    # Windows under bin/tools/pandoc.exe), and has changed across versions.
    pandoc_name <- if (.Platform$OS.type == "windows") "pandoc.exe" else "pandoc"
    hits <- list.files(
      file.path(quarto_root, "bin"),
      pattern = paste0("^", pandoc_name, "$"),
      recursive = TRUE,
      full.names = TRUE
    )
    if (length(hits) > 1) {
      # macOS ships a universal bundle with both x86_64 and aarch64 copies -
      # narrow to the one matching this machine so we don't grab a binary
      # that can't actually run here.
      machine <- Sys.info()[["machine"]]
      arch_token <- if (machine %in% c("arm64", "aarch64")) "aarch64" else machine
      arch_hits <- hits[grepl(arch_token, hits, fixed = TRUE)]
      if (length(arch_hits) > 0) {
        hits <- arch_hits
      }
    }
    if (length(hits) > 0) {
      Sys.setenv(RSTUDIO_PANDOC = dirname(hits[1]))
    }
  }
}
