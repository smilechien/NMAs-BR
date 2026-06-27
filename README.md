# NMAs-BR
NMAs-BR
 # NMAs-BR Shiny App
# Note:
The proposed MH-MCMC–based NMAs-BR should be regarded as an accessible and reproducible Bayesian NMA implementation rather than a replacement for established frequentist or Bayesian packages. Compared with JAGS/rjags-based workflows, which require installation of external JAGS software, the proposed app.R provides a more transparent and user-friendly platform for conducting Bayesian NMA, examining prior assumptions, generating MCMC diagnostics, and comparing Bayesian estimates with frequentist NMA results. Therefore, the main academic contribution of this study is the provision of a complete, browser-accessible, and reproducible R/Shiny implementation that helps readers understand and apply Bayesian NMA using MH-MCMC.

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
