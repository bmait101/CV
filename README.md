# CV for Bryan M. Maitland

This repo contains my CV and the code used to build it. Full CV available [here](BryanMaitlandCV.pdf), one-page version [here](BryanMaitland_1page.pdf).

Originally built on the [vitae](https://github.com/mitchelloharawild/vitae) infrastructure and the `vitae::hyndman` theme; since converted to [Quarto](https://quarto.org), following the layout of [robjhyndman/CV](https://github.com/robjhyndman/CV).

## Building

Dependencies are managed with [renv](https://rstudio.github.io/renv/). On a fresh clone:

```r
renv::restore()
```

Rendering is orchestrated with [targets](https://books.ropensci.org/targets/), which fetches Google Scholar citation stats and R package download counts (cached, refreshed once per day) and then renders both CV documents:

```sh
make            # or: Rscript -e "targets::tar_make()"
make clean      # or: Rscript -e "targets::tar_destroy()"
```

## Layout

- `BryanMaitlandCV.qmd` / `BryanMaitland_1page.qmd` - the two CV documents
- `_extensions/cv/` - the LaTeX/Quarto format (`cv-pdf`) the CVs render with
- `_targets.R` - the render pipeline
- `R/` - helper functions (tables, bibliography rendering, citation/download stats)
- `bibs/` - bibliography files by category (`.bib`)
- `csl/` - citation style
- `lua/` - pandoc filter that bolds my name and underlines mentee names in citations
- `*.csv` - grants, talks, media, etc.
