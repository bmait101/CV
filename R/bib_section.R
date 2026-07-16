# Render a bibliography section (a subset of entries from a .bib file) as
# LaTeX, using our CSL style and the names.lua bold/underline filter.
#
# vitae::bibliography_entries() can't be used directly here: under classic
# rmarkdown::render(), it works by emitting an empty placeholder div and
# relying on an rmarkdown `pre_processor` hook (defined in
# vitae:::cv_document()) to collect all such placeholders across the whole
# document afterwards and rewrite the doc's YAML with the right
# `bibliography`/`nocite` fields before pandoc ever runs. Quarto's
# `format: cv-pdf` extension doesn't go through that rmarkdown machinery, so
# that hook never fires and the placeholders render as empty divs.
#
# Instead, we do our own single-file citeproc pass per section: build a
# throwaway markdown doc that cites exactly the entries we want (in the
# order given), run Quarto's own pandoc against it directly with our CSL and
# lua filter, and paste the resulting LaTeX fragment straight into the
# document.
#
# `cites`, if given, is a named character vector (bib key -> annotation
# text, e.g. "[Citations: 42]", NA where there's nothing to show) as
# produced by get_citation_counts() below. It gets spliced onto the end of
# each matching entry's rendered text after citeproc runs, rather than
# going through a bibtex field - `note`/`annote` are already used in these
# bib files for other things (contribution statements, "Refereed", package
# versions, etc.), so hijacking one of those fields for this would leak
# into every other section using the same style.
render_bib_section <- function(
    entries,
    file,
    csl = here::here("csl/apa_cv.csl"),
    lua_filter = here::here("lua/names.lua"),
    cites = NULL
) {
  ids <- entries$id
  if (length(ids) == 0) {
    return(invisible(NULL))
  }

  pandoc_bin <- file.path(Sys.getenv("RSTUDIO_PANDOC"), "pandoc")
  if (!file.exists(pandoc_bin)) {
    stop("Could not find pandoc (checked RSTUDIO_PANDOC env var).")
  }

  tmp_md <- tempfile(fileext = ".md")
  tmp_tex <- tempfile(fileext = ".tex")
  on.exit(unlink(c(tmp_md, tmp_tex)))
  xfun::write_utf8(
    c(
      "---",
      paste0("bibliography: '", file, "'"),
      paste0("csl: '", csl, "'"),
      paste0("nocite: '", paste0("@", ids, collapse = ", "), "'"),
      "suppress-bibliography: false",
      "---",
      "",
      "::: {#refs}",
      ":::"
    ),
    tmp_md
  )

  args <- c(tmp_md, "--citeproc", "-t", "latex", "-o", tmp_tex)
  if (!is.null(lua_filter)) {
    args <- c(args, paste0("--lua-filter=", lua_filter))
  }
  result <- system2(pandoc_bin, args, stdout = TRUE, stderr = TRUE)
  status <- attr(result, "status")
  if (!is.null(status) && status != 0) {
    stop("pandoc failed rendering ", file, ":\n", paste(result, collapse = "\n"))
  }

  tex_lines <- xfun::read_utf8(tmp_tex)
  if (!is.null(cites)) {
    tex_lines <- insert_citation_counts(tex_lines, cites)
  }
  cat(tex_lines, sep = "\n")
}

# Splice "\emph{[Citations: N]}." onto the end of each \bibitem's rendered
# paragraph, right before the blank line (or \end{CSLReferences}) that
# closes it. Adding it as a new source line here is safe - LaTeX only
# starts a new paragraph on a *blank* line, so this reads as a continuation
# of the same entry, wrapped normally.
insert_citation_counts <- function(lines, cites) {
  bibitem_re <- "^\\\\bibitem\\[\\\\citeproctext\\]\\{ref-(.+)\\}$"
  out <- character(0)
  current_key <- NULL
  for (line in lines) {
    if (grepl(bibitem_re, line)) {
      current_key <- sub(bibitem_re, "\\1", line)
      out <- c(out, line)
      next
    }
    at_boundary <- trimws(line) == "" || line == "\\end{CSLReferences}"
    if (at_boundary && !is.null(current_key)) {
      note <- cites[current_key]
      if (!is.na(note)) {
        out <- c(out, paste0(" \\emph{", note, "}."))
      }
      current_key <- NULL
    }
    out <- c(out, line)
  }
  out
}

# Fuzzy-match a BibEntry list's titles against Google Scholar per-paper
# citation data (as returned by get_scholar_cites() in R/gcite.R) and
# return a named character vector of bib key -> "[Citations: N]" text
# (NA where no match was found), for use as render_bib_section()'s `cites`
# argument.
get_citation_counts <- function(bib, cites) {
  keys <- names(bib)
  matched <- bib |>
    as.data.frame() |>
    dplyr::mutate(
      key = keys,
      title = stringr::str_replace_all(title, "[{}]", "")
    ) |>
    fuzzyjoin::stringdist_left_join(
      cites |> dplyr::select(title, n_citations),
      by = "title",
      ignore_case = TRUE,
      max_dist = 15,
      distance_col = "dist"
    ) |>
    dplyr::rename(title = title.x) |>
    dplyr::group_by(title) |>
    dplyr::slice_min(dist, n = 1, with_ties = FALSE) |>
    dplyr::ungroup() |>
    dplyr::arrange(match(key, keys))

  out <- ifelse(
    is.na(matched$n_citations),
    NA_character_,
    paste0("[Citations: ", matched$n_citations, "]")
  )
  stats::setNames(out, keys)
}
