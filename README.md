# CV for Bryan M. Maitland

This repo contains my CV and the code used to build it. Full CV available [here](BryanMaitlandCV.pdf), two-page version [here](BryanMaitland_2page.pdf), one-page version [here](BryanMaitland_1page.pdf).

The two- and one-page versions are the ones to send with grant proposals, and both are built to be retargeted per call. Everything worth changing lives in two places: the `tuning` chunk near the top of the `.qmd` (which papers to feature, how many grants to list, and on the 2-pager whether to show the large invited proposals) and the prose under `# Research summary`, fenced by `TUNE PER PROPOSAL` comments. Papers print top-to-bottom in the order you list them, so lead with whatever is most relevant. Everything else is built from the same `bibs/` and `*.csv` sources as the full CV, so it stays in sync on its own.

Both are sized to their page count with little slack, so check the render after editing: the 2-pager ends about a quarter down page 2, and the 1-pager is full.

Originally built on the [vitae](https://github.com/mitchelloharawild/vitae) infrastructure and the `vitae::hyndman` theme; since converted to [Quarto](https://quarto.org), following the layout of [robjhyndman/CV](https://github.com/robjhyndman/CV).

## Building

Dependencies are managed with [renv](https://rstudio.github.io/renv/). On a fresh clone:

```r
renv::restore()
```

Rendering is orchestrated with [targets](https://books.ropensci.org/targets/), which fetches Google Scholar citation stats and R package download counts (cached, refreshed once per day) and then renders all three CV documents:

```sh
make            # or: Rscript -e "targets::tar_make()"
make clean      # or: Rscript -e "targets::tar_destroy()"
```

## Layout

- `BryanMaitlandCV.qmd` / `BryanMaitland_2page.qmd` / `BryanMaitland_1page.qmd` - the three CV documents
- `_extensions/cv/` - the LaTeX/Quarto format (`cv-pdf`) the CVs render with
- `_targets.R` - the render pipeline
- `R/` - helper functions (tables, bibliography rendering, citation/download stats)
- `bibs/` - bibliography files by category (`.bib`)
- `csl/` - citation style
- `lua/` - pandoc filter that bolds my name and underlines mentee names in citations
- `*.csv` - grants, talks, media, etc.
