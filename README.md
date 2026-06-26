# NMAs-BR
NMAs-BR
 # NMAs-BR Shiny App

This repository contains a self-contained `app.R` for browser-based network meta-analysis (NMA).

## Main features

- Paste binary arm-level NMA data: `study,treatment,responders,sampleSize`
- Paste contrast-level NMA data: `study,treat1,treat2,TE,seTE`
- Paste continuous outcome summary data: `study,treat1,treat2,mean1,sd1,n1,mean2,sd2,n2`
- Built-in special demo buttons:
  - Original Appendix 1 binary data
  - Large binary data
  - Zero-cell + multi-arm binary NMA
  - Contrast-level TE/seTE NMA
  - Continuous outcome NMA
- Frequentist NMA using `netmeta`
- Fixed/random model outputs
- Evidence network plot
- Global and local consistency checks: `decomp.design()` and `netsplit()`
- Ranking / P-score using `netrank()`
- Custom Bayesian Metropolis-Hastings MCMC for reference contrasts
- Eight prior-scenario comparison
- Supplementary direct pairwise `metabin()` tab
- Optional `gemtc::mtc.network()` tab when `gemtc` is installed

## Why no external `source()` URL?

The app does not run:

```r
url <- "http://www.raschonline.com/raschonline/fixrandomeffectmodel.txt"
sourceCode <- readLines(url)
eval(parse(text = sourceCode))
```

Instead, the app creates `data_f_bin` locally before calling `netmeta()`. This prevents the common error:

```r
object 'data_f_bin' not found
```

## Install packages on Windows

```r
install.packages(
  c("shiny", "DT", "ggplot2", "dplyr", "netmeta", "meta", "igraph", "coda", "rsconnect"),
  type = "binary",
  dependencies = TRUE,
  repos = "https://cloud.r-project.org"
)
```

Optional:

```r
install.packages("gemtc", type = "binary", dependencies = TRUE)
```

## Run locally

```r
shiny::runApp("app.R")
```

or place `app.R` in a folder and run:

```r
setwd("F:/your_folder/NMAsBR")
shiny::runApp()
```

## Deploy to shinyapps.io

```r
library(rsconnect)
rsconnect::deployApp(appDir = ".", appName = "NMAsBR")
```


## Latest update: Figure 4 convergence diagnostic

The `Tables/Figures` tab now includes **Figure 4. Convergence diagnostic / shrink-factor plot**. It draws Gelman-Rubin shrink-factor curves for the main non-E reference contrasts, usually B vs A, C vs A, and D vs A. Treatment E is skipped in this manuscript-style diagnostic because sparse or zero-event data may lead to poor convergence; users can inspect and remove E when appropriate, then rerun the analysis.

The app is self-contained and does not use `readLines(url)` or `eval(parse())`. The object `data_f_bin` is created locally through `meta::pairwise()`, avoiding the previous `object 'data_f_bin' not found` error.
