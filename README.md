# NMAs-BR
NMAs-BR
# NMAs-BR Shiny App

A pasted-data R/Shiny application for reproducing Bayesian and frequentist network meta-analysis (NMA) for binary outcomes.

The app was designed for readers who want to reproduce the NMAs-BR workflow from a simple CSV pasted into the browser:

```csv
study,treatment,responders,sampleSize
1,D,10,80
1,A,26,81
```

The browser app generates parsed arm-level data, evidence network maps, frequentist `netmeta` graphs and forest plots, custom Bayesian Metropolis-Hastings MCMC summaries, trace/density diagnostics, prior-scenario comparison, manuscript-style Table 1 and Figures 2/3/5/6, P-score/ranking, Q statistics, and SIDE/netsplit output when supported by `netmeta`.

## Installation

On Windows, install binary packages to avoid compilation problems:

```r
install.packages(
  c("shiny", "DT", "ggplot2", "dplyr", "netmeta", "meta", "igraph", "coda", "rsconnect"),
  type = "binary",
  dependencies = TRUE,
  repos = "https://cloud.r-project.org"
)
```

Run locally:

```r
setwd("F:/your_folder/NMAsBR_ShinyApp_demos")
shiny::runApp()
```

Deploy to shinyapps.io:

```r
library(rsconnect)
rsconnect::deployApp(appDir = ".", appName = "NMAsBR")
```

## Required pasted-data format

```csv
study,treatment,responders,sampleSize
```

- `study`: study identifier; numeric or character values are allowed.
- `treatment`: treatment label; A is the default reference.
- `responders`: number of events/responders.
- `sampleSize`: total number in the arm.
- `responders` must be between 0 and `sampleSize`.

## Built-in demo datasets

Use the left-panel selector **Example/demo dataset**, click **Load selected demo data**, and then click **Run analysis**.

| Demo | Source | Purpose | Expected run summary |
|---|---|---|---|
| Demo 1. Original NMAs-BR Appendix 1 data | Original study-arm data used for BNMA in NMAs-BR; copied from Appendix/Supplemental Digital Content. | Reproduce manuscript browser tables and figures for A-E. | 44 rows, 21 studies, A-E; fixed ORs approximately B=0.27, C=0.24, D=0.31, E=0.03 versus A. |
| Demo 2. Alternative 24-study four-treatment data | Alternative binary NMA dataset supplied in the accompanying R script. | Check larger pasted data and connected four-treatment network. | 50 rows, 24 studies, A-D; fixed ORs approximately B=1.15, C=1.92, D=1.55 versus A. |
| Demo 3. Synthetic five-treatment star network with zero-cell example | Synthetic educational dataset created for this app. | Check zero-responder cells and five-treatment analysis. | 36 rows, 17 studies, A-E; fixed ORs approximately B=0.57, C=0.48, D=0.84, E=0.08 versus A. |
| Demo 4. Synthetic connected loop network with multi-arm trials | Synthetic educational dataset created for this app. | Check direct and indirect evidence across closed loops. | 34 rows, 14 studies, A-E; fixed ORs approximately B=0.62, C=0.48, D=0.79, E=0.20 versus A. |

## Demo 2 paste-ready data

```csv
study,treatment,responders,sampleSize
1,A,9,140
1,C,23,140
1,D,10,138
2,B,11,78
2,C,12,85
2,D,29,170
3,A,79,702
3,B,77,694
4,A,18,671
4,B,21,535
5,A,8,116
5,B,19,146
6,A,75,731
6,C,363,714
7,A,2,106
7,C,9,205
8,A,58,549
8,C,237,1561
9,A,0,33
9,C,9,48
10,A,3,100
10,C,31,98
11,A,1,31
11,C,26,95
12,A,6,39
12,C,17,77
13,A,95,1107
13,C,134,1031
14,A,15,187
14,C,35,504
15,A,78,584
15,C,73,675
16,A,69,1177
16,C,54,888
17,A,64,642
17,C,107,761
18,A,5,62
18,C,8,90
19,A,20,234
19,C,34,237
20,A,0,20
20,D,9,20
21,B,20,49
21,C,16,43
22,B,7,66
22,D,32,127
23,C,12,76
23,D,20,74
24,C,9,55
24,D,3,26
```

## Demo 3 paste-ready data

```csv
study,treatment,responders,sampleSize
S01,A,22,100
S01,B,14,98
S02,A,28,120
S02,B,18,119
S03,A,31,110
S03,B,20,108
S04,A,24,95
S04,C,12,96
S05,A,30,130
S05,C,19,128
S06,A,26,115
S06,C,13,112
S07,A,20,90
S07,D,18,88
S08,A,23,92
S08,D,21,90
S09,A,25,105
S09,D,20,103
S10,A,18,80
S10,E,2,82
S11,A,21,85
S11,E,0,84
S12,A,27,110
S12,E,4,112
S13,A,29,120
S13,B,17,118
S13,C,15,119
S14,A,24,100
S14,D,20,99
S14,E,1,101
S15,B,16,100
S15,C,13,102
S16,C,12,90
S16,D,17,92
S17,D,19,95
S17,E,3,96
```

## Demo 4 paste-ready data

```csv
study,treatment,responders,sampleSize
L01,A,35,160
L01,B,24,158
L01,C,18,162
L02,A,28,130
L02,C,16,129
L03,B,22,140
L03,C,20,138
L04,A,31,150
L04,D,27,148
L05,C,15,120
L05,D,23,122
L06,B,20,125
L06,D,24,126
L07,A,30,145
L07,E,8,143
L08,D,26,150
L08,E,10,151
L09,B,21,135
L09,E,9,133
L10,A,27,128
L10,B,18,126
L10,E,7,130
L11,C,14,118
L11,E,6,116
L12,A,33,155
L12,C,17,154
L12,D,25,156
L13,A,24,120
L13,B,15,118
L13,D,20,119
L13,E,5,121
L14,A,22,110
L14,C,13,111
L14,E,4,109
```

## Notes on interpretation

The custom Bayesian module uses a self-contained Metropolis-Hastings sampler for log odds ratios. This avoids mandatory `rjags`/JAGS installation and makes shinyapps.io deployment easier. Browser results may vary slightly when MCMC iterations, burn-in, thinning, or the random seed are changed.

## Repository structure

```text
NMAsBR_ShinyApp_demos/
├── app.R
├── README.md
├── README_NMAsBR.md
├── demo1_original_appendix1.csv
├── demo2_24study_four_treatment.csv
├── demo3_synthetic_star_zero_cell.csv
└── demo4_synthetic_loop_multiarm.csv
```

## License

For academic demonstration and manuscript reproduction. Add the final license required by your journal or institution before public release.

