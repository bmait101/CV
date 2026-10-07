# A plain terminal (e.g. running `quarto render` outside RStudio) may be in
# the "C" locale, which makes R mangle non-ASCII characters (accented author
# names, etc.). Force UTF-8 so text survives the render.
if (!l10n_info()[["UTF-8"]]) {
  try(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"), silent = TRUE)
}
