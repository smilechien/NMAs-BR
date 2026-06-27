# NMAs-BR
NMAs-BR
 # NMAs-BR Shiny App
# Note:
The proposed MH-MCMC–based NMAs-BR should be regarded as an accessible and reproducible Bayesian NMA implementation rather than a replacement for established frequentist or Bayesian packages. Compared with JAGS/rjags-based workflows, which require installation of external JAGS software, the proposed app.R provides a more transparent and user-friendly platform for conducting Bayesian NMA, examining prior assumptions, generating MCMC diagnostics, and comparing Bayesian estimates with frequentist NMA results. Therefore, the main academic contribution of this study is the provision of a complete, browser-accessible, and reproducible R/Shiny implementation that helps readers understand and apply Bayesian NMA using MH-MCMC.
#A good summary sentence for the manuscript would be:

The meta and netmeta packages were used for frequentist pairwise and network meta-analysis, whereas gemtc and rjags were used for Bayesian NMA through MCMC computation. The coda package was used to summarize and diagnose MCMC outputs. Compared with JAGS/rjags-based workflows, the proposed NMAs-BR app.R provides a transparent and user-friendly MH-MCMC implementation that allows readers to reproduce Bayesian NMA procedures, examine prior assumptions, and compare Bayesian estimates with frequentist NMA results.

The clean conceptual difference is:

meta → direct pairwise evidence
netmeta → frequentist NMA
gemtc → Bayesian NMA framework
rjags → engine/interface for Bayesian MCMC via JAGS
coda → MCMC diagnostics
your app.R → transparent MH-MCMC teaching/reproducibility platform
This repository contains a self-contained `app.R` for browser-based network meta-analysis (NMA).


In R-based NMA, these packages have different roles. They are not all “NMA methods”; some are model-fitting packages, some are MCMC engines/interfaces, and some are diagnostic/support packages. In your manuscript, the workflow compares Bayesian and frequentist NMA using packages including gemtc, rjags, coda, netmeta, and meta, with JAGS used through the R interface.


 ## R Packages Used for Network Meta-Analysis

In R-based network meta-analysis (NMA), the packages used in this study have different roles. They are not all “NMA methods”; some are model-fitting packages, some are MCMC engines or interfaces, and some are diagnostic or support packages. In this manuscript, the workflow compares Bayesian and frequentist NMA using `gemtc`, `rjags`, `coda`, `netmeta`, and `meta`, with JAGS used through the R interface.

| Package                    | Main Role                                   | Statistical Framework                  | Main Function in NMA Workflow                                                                                                          | Strength                                                                                                      | Limitation                                                                                                                         |
| -------------------------- | ------------------------------------------- | -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `meta`                     | Pairwise meta-analysis and data preparation | Frequentist                            | Prepares arm-level or contrast-level data; performs direct pairwise meta-analysis using functions such as `metabin()` and `pairwise()` | Useful for direct treatment comparisons and preparing data for `netmeta`                                      | Not designed as a full network meta-analysis package                                                                               |
| `netmeta`                  | Frequentist network meta-analysis           | Frequentist NMA                        | Performs fixed-effect and random-effects NMA, network plots, forest plots, consistency checks, and P-score ranking                     | Strong and convenient package for frequentist NMA                                                             | Does not incorporate Bayesian priors or MCMC simulation                                                                            |
| `gemtc`                    | Bayesian network meta-analysis framework    | Bayesian NMA                           | Builds Bayesian NMA models and supports treatment ranking and consistency/inconsistency modeling                                       | Widely used for Bayesian NMA in R                                                                             | Usually depends on JAGS/rjags, which may require additional setup                                                                  |
| `rjags`                    | R interface to JAGS                         | Bayesian MCMC interface                | Allows R to run Bayesian models through JAGS using MCMC simulation                                                                     | Flexible for Bayesian hierarchical modeling                                                                   | Requires separate installation of JAGS software, which can be difficult for some users                                             |
| `coda`                     | MCMC diagnostics and summary                | MCMC support package                   | Summarizes MCMC chains and provides convergence diagnostics, trace plots, density plots, and Gelman-Rubin statistics                   | Essential for checking Bayesian MCMC output quality                                                           | Does not fit NMA models by itself                                                                                                  |
| Proposed `app.R` / NMAs-BR | Custom R/Shiny Bayesian NMA implementation  | Bayesian MH-MCMC + comparison platform | Implements MH-MCMC NMA, compares Bayesian and frequentist results, evaluates prior assumptions, and generates tables and figures       | Transparent, reproducible, browser-accessible, and easier for users who have difficulty installing JAGS/rjags | Should be interpreted as a reproducible educational and applied implementation, not a replacement for all established NMA packages |

### Conceptual Summary

* `meta` is mainly used for pairwise meta-analysis and data preparation.
* `netmeta` is used for frequentist network meta-analysis.
* `gemtc` is used for Bayesian network meta-analysis.
* `rjags` connects R to JAGS for Bayesian MCMC computation.
* `coda` is used to summarize and diagnose MCMC outputs.
* The proposed `app.R` / NMAs-BR provides a transparent MH-MCMC implementation for Bayesian NMA and allows readers to reproduce, compare, and understand the Bayesian and frequentist NMA workflow.

### Contribution of the Proposed App

The proposed MH-MCMC-based NMAs-BR app is not intended to replace established packages such as `netmeta`, `gemtc`, or `rjags`. Instead, it provides a practical, transparent, and reproducible R/Shiny implementation that lowers the technical barrier for users. In particular, it helps users who may have difficulty installing external JAGS software required by `rjags`, while also allowing prior-sensitivity analysis, MCMC diagnostics, and comparison with frequentist NMA results.

## Compared tp several R/Shiny-based tools for network meta-analysis
  Although several R/Shiny-based tools for network meta-analysis have been reported previously, including MetaInsight, NetMetaEasy, and NMAsurv, these platforms primarily provide user-friendly interfaces built on established NMA packages or focus on specific data structures such as survival outcomes. The proposed NMAs-BR app.R differs by offering a transparent and reproducible MH-MCMC implementation for Bayesian NMA, allowing users to examine prior-distribution assumptions, modify prior parameters, regenerate Bayesian estimates and MCMC diagnostic figures, and compare the results with frequentist NMA outputs. Thus, the contribution of this study is not the first use of R/Shiny for NMA, but the provision of a self-contained, educational, and reproducible Bayesian NMA workflow that may reduce the technical barrier associated with JAGS/rjags-based Bayesian analysis.

## Similar R-Based or R/Shiny Tools for Network Meta-Analysis

Several R-based or R/Shiny-based tools for network meta-analysis (NMA) have been reported in PubMed-indexed or academic literature. However, the proposed `app.R` / NMAs-BR differs by emphasizing a transparent MH-MCMC Bayesian NMA workflow, prior-distribution sensitivity analysis, adjustable prior parameters, MCMC diagnostics, and direct comparison with frequentist NMA outputs.

| Article/tool found in PubMed or academic search                              | AMA citation | Similarity to proposed `app.R` / NMAs-BR                                                                                    | Difference from proposed contribution                                                                                                                                                                                                                                             |
| ---------------------------------------------------------------------------- | -----------: | --------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MetaInsight                                                                  |            1 | R/Shiny web tool for analyzing, interrogating, and visualizing NMA using `netmeta`.                                         | Mainly a web interface built around established R packages; not presented as a transparent author-written MH-MCMC implementation with adjustable prior-distribution sensitivity analysis.                                                                                         |
| NetMetaEasy                                                                  |            2 | R/Shiny platform for rapid and user-friendly NMA; supports frequentist and Bayesian NMA options.                            | Similar in user-friendly goal, but emphasizes rapid standard NMA workflows rather than demonstrating a custom MH-MCMC algorithm and Table 1 prior-sensitivity rerun logic.                                                                                                        |
| NMAsurv                                                                      |            3 | R/Shiny application for NMA based on survival or time-to-event data.                                                        | Focuses on survival-data NMA, including non-proportional hazards models, rather than binary arm-level Bayesian MH-MCMC NMA with log-odds priors.                                                                                                                                  |
| Network meta-analysis: application and practice using R software             |            4 | Academic paper explaining R-based NMA using Bayesian and frequentist approaches, including `gemtc`, `rjags`, and `netmeta`. | Uses and teaches existing R packages; it is not a Shiny app contribution and does not provide a self-contained MH-MCMC rerun platform for prior sensitivity and manuscript figure generation.                                                                                     |
| Performing arm-based network meta-analysis in R with the `pcnetmeta` package |            5 | R-based methodological NMA article relevant to Bayesian computation and arm-based modeling.                                 | Methodological and package-based; not an interactive app.R-style platform for users to rerun prior assumptions and regenerate manuscript tables and figures.                                                                                                                      |
| BayesMetaNMA                                                                 |            6 | Very similar in spirit: an R/Shiny application for Bayesian pairwise and network meta-analysis.                             | It uses `rjags`/JAGS for MCMC estimation and also integrates `netmeta` and `meta`; therefore, it still depends on JAGS/rjags, whereas the proposed `app.R` can be framed as a simpler transparent MH-MCMC implementation with adjustable prior-distribution sensitivity analysis. |

## Interpretation

The proposed `app.R` / NMAs-BR should not be claimed as the first R/Shiny tool for NMA. A safer and stronger claim is that it provides a transparent, reproducible, and educational MH-MCMC implementation for Bayesian NMA, allowing users to modify prior assumptions, rerun Bayesian estimates, regenerate prior-dependent figures, and compare results with frequentist NMA outputs.

## References

1. Owen RK, Bradbury N, Xin Y, Cooper N, Sutton A. MetaInsight: an interactive web-based tool for analyzing, interrogating, and visualizing network meta-analyses using R-shiny and netmeta. *Res Synth Methods*. 2019;10(4):569-581. doi:10.1002/jrsm.1373

2. Fekete JT, Komócsi A, Győrffy B. NetMetaEasy: enabling rapid and user-friendly network meta-analysis (NMA) for comparative effectiveness research. *Br J Pharmacol*. 2026;183(9):1814-1823. doi:10.1111/bph.70391

3. Shao T, Zhao M, Shi F, Rui M, Tang W. NMAsurv: an R Shiny application for network meta-analysis based on survival data. *Res Synth Methods*. 2025;16(6):1042-1056. doi:10.1017/rsm.2025.10020

4. Shim SR, Kim SJ, Lee J, Rücker G. Network meta-analysis: application and practice using R software. *Epidemiol Health*. 2019;41:e2019013. doi:10.4178/epih.e2019013

5. Lin L, Zhang J, Hodges JS, Chu H. Performing arm-based network meta-analysis in R with the `pcnetmeta` package. *J Stat Softw*. 2017;80(5):1-25. doi:10.18637/jss.v080.i05

6. Khan L, Khan M, Ahmad M, Lac J. Title:BayesMetaNMA: an interactive R/Shiny application for Bayesian pairwise and network meta-analysis [version 1; peer review: 1 approved with reservations, 1 not approved]. *F1000Research*. 2025;14:924. doi:10.12688/f1000research.169341.1



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

# Example 1 for interpretation in details: #這是一個用於 NMA（network meta-analysis，網絡統合分析） 的 arm-level binary outcome dataset（研究組別層級的二元結果資料）。每一列代表某一篇研究中的一個治療組，而不是一篇研究的總結果。

1. 欄位意義
欄位	說明
study	研究編號。相同 study 代表同一篇研究中的不同治療組。
treatment	治療代碼，共有 A、B、C、D、E 五種治療。
responders	該治療組中產生反應或達到療效標準的人數。
sampleSize	該治療組的總樣本數。

例如：

study,treatment,responders,sampleSize
1,D,10,80
1,A,26,81

表示第 1 篇研究比較 D 治療 與 A 治療。
D 組共有 80 人，其中 10 人有反應；A 組共有 81 人，其中 26 人有反應。

2. 研究設計特徵

這份資料包含 20 個研究編號，共 43 個治療組。大多數研究是兩組比較，但第 19 與第 20 個研究是多組研究。

例如：

19,B,3,70
19,D,4,70
19,E,0,70

第 19 篇研究同時比較 B、D、E 三種治療，因此是三臂研究。

20,B,8,50
20,E,1,50
20,A,19,50

第 20 篇研究同時比較 B、E、A 三種治療，也是三臂研究。

在 NMA 中，多臂研究很重要，因為它們能同時提供多個直接比較，但分析時也需要考慮同一研究內不同組別之間的相關性。

3. 治療組別

本資料共有五種治療：

代碼	治療
A	參考組或對照組
B	治療 B
C	治療 C
D	治療 D
E	治療 E

其中 A 出現最頻繁，通常可作為網絡統合分析中的參考治療。
B、C、D、E 則透過直接或間接證據與 A 及彼此比較。

4. 結果變項

這份資料的結果是 二元結果 binary outcome，也就是每位受試者只有兩種可能結果：

有反應：responders
無反應：sampleSize - responders

例如：

2,C,4,36
2,A,14,37

第 2 篇研究中：

C 組反應率 = 4 / 36 = 11.1%
A 組反應率 = 14 / 37 = 37.8%

因此，這筆資料適合使用 odds ratio（OR）、risk ratio（RR） 或 risk difference（RD） 作為效果量。若用於 Bayesian NMA 或 frequentist NMA，最常見的是以 OR 作為治療效果指標。

5. 網絡結構

這份資料形成一個治療網絡，其中節點是治療 A、B、C、D、E，邊線代表兩種治療在同一研究中被直接比較過。

主要直接比較包括：

直接比較	說明
A vs B	多篇研究直接比較
A vs C	多篇研究直接比較
A vs D	部分研究直接比較
A vs E	出現在多臂研究中
B vs D	第 19 篇研究提供
B vs E	第 19 與第 20 篇研究提供
D vs E	第 19 篇研究提供
C vs D	第 15 篇研究提供

因此，這不是單純的 pairwise meta-analysis，而是可以同時整合多種治療直接與間接證據的 network meta-analysis dataset。

6. 為什麼適合做 NMA？

這份資料適合 NMA，因為它具有三個特點：

第一，包含多種治療選項 A、B、C、D、E。
第二，不同研究之間透過共同比較組 A 連接起來。
第三，包含多臂研究，例如第 19 與第 20 篇研究，使網絡中出現 B、D、E 及 A 之間的額外連結。

換句話說，即使某些治療沒有大量直接比較，仍可透過網絡中的共同比較組進行 間接比較。例如，若 C 與 E 沒有直接比較，也可以透過 C–A 與 A–E 的路徑估計 C 與 E 的相對效果。

7. 可寫入論文 Methods 的版本

本研究使用一組 arm-level binary outcome 資料進行網絡統合分析。資料包含 20 項研究、43 個研究治療組，以及 5 種治療選項，分別標記為 A、B、C、D 和 E。每一列代表特定研究中的一個治療組，並記錄研究編號、治療代碼、反應人數及總樣本數。結果變項為二元療效反應，因此每組的非反應人數可由總樣本數減去反應人數取得。多數研究為兩臂比較，另有第 19 與第 20 項研究為三臂研究。治療 A 為主要共同比較組，連接 B、C、D 和 E 等治療節點，使直接與間接證據可在同一治療網絡中整合。由於資料包含多種治療選項、共同比較組及多臂研究，因此適合用於 frequentist 或 Bayesian network meta-analysis，以 odds ratio 作為主要治療效果指標。
