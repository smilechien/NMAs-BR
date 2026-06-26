# app.R
# NMAs-BR Shiny application
# A reproducible pasted-data R/Shiny platform for Bayesian and frequentist
# network meta-analysis of binary outcomes.
#
# Deployment:
#   install.packages(c("shiny", "DT", "ggplot2", "dplyr", "netmeta", "meta", "igraph", "coda", "rsconnect"), type = "binary")
#   rsconnect::deployApp(appDir = ".", appName = "NMAsBR")
#
# Notes:
#   1. The app uses netmeta for frequentist NMA.
#   2. The Bayesian component uses a self-contained Metropolis-Hastings sampler
#      for log odds ratios, so no external JAGS installation is required.
#   3. gemtc/rjags can be added later as optional comparison modules, but they
#      are not required here to keep shinyapps.io deployment practical.

required_pkgs <- c("shiny", "DT", "ggplot2", "dplyr", "netmeta", "meta", "igraph", "coda")
missing_pkgs <- required_pkgs[!vapply(required_pkgs, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing_pkgs) > 0) {
  stop(
    "Please install missing packages before running this app: ",
    paste(missing_pkgs, collapse = ", "),
    call. = FALSE
  )
}

library(shiny)
library(DT)
library(ggplot2)
library(dplyr)
library(netmeta)
library(meta)
library(igraph)
library(coda)

default_data <- "study,treatment,responders,sampleSize
1,D,10,80
1,A,26,81
2,C,4,36
2,A,14,37
3,C,9,20
3,A,15,19
4,B,4,18
4,A,8,20
5,B,1,20
5,A,6,20
6,C,1,50
6,A,6,51
8,C,2,20
8,A,7,20
7,C,2,30
7,A,9,30
9,B,8,47
9,A,23,53
10,B,7,32
10,A,15,32
11,C,9,34
11,A,20,34
12,C,6,20
12,A,13,19
13,D,3,25
13,A,5,25
14,C,5,19
14,A,8,20
15,C,8,70
15,D,12,69
16,B,3,36
16,A,10,37
17,B,9,81
17,A,10,38
18,B,6,101
18,A,26,100
19,B,3,70
19,D,4,70
19,E,0,70
20,B,8,50
20,E,1,50
20,A,19,50
21,D,3,52
21,A,11,49"

demo_data_2 <- "study,treatment,responders,sampleSize
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
24,D,3,26"

demo_data_3 <- "study,treatment,responders,sampleSize
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
S17,E,3,96"

demo_data_4 <- "study,treatment,responders,sampleSize
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
L14,E,4,109"

demo_data <- list(
  "Demo 1. Original NMAs-BR Appendix 1 data" = default_data,
  "Demo 2. Alternative 24-study four-treatment data from supplied R script" = demo_data_2,
  "Demo 3. Synthetic five-treatment star network with zero-cell example" = demo_data_3,
  "Demo 4. Synthetic connected loop network with multi-arm trials" = demo_data_4
)

demo_sources <- data.frame(
  Demo = names(demo_data),
  Source = c(
    "Original study-arm data used for BNMA in NMAs-BR; copied from Appendix/Supplemental Digital Content.",
    "Alternative binary NMA dataset supplied in the accompanying R script; retained as a paste-ready example.",
    "Synthetic educational dataset created for this Shiny app to test A-referenced contrasts, five treatments, and zero-cell continuity correction.",
    "Synthetic educational dataset created for this Shiny app to test a connected loop network, multi-arm trials, SIDE/netsplit, and netmeta graph output."
  ),
  Purpose = c(
    "Reproduce the manuscript browser tables and figures for treatments A-E.",
    "Check that the app accepts larger pasted data and produces a connected four-treatment network.",
    "Check that zero responder cells and sparse E-vs-A evidence do not stop analysis.",
    "Check direct and indirect evidence across A-E with several closed loops."
  ),
  Expected = c(
    "44 rows, 21 studies, treatments A-E; fixed ORs approximately B=0.27, C=0.24, D=0.31, E=0.03 versus A.",
    "50 rows, 24 studies, treatments A-D; fixed ORs approximately B=1.15, C=1.92, D=1.55 versus A.",
    "36 rows, 17 studies, treatments A-E; fixed ORs approximately B=0.57, C=0.48, D=0.84, E=0.08 versus A.",
    "34 rows, 14 studies, treatments A-E; fixed ORs approximately B=0.62, C=0.48, D=0.79, E=0.20 versus A."
  ),
  stringsAsFactors = FALSE
)


treatment_labels <- c(
  A = "Placebo",
  B = "IV(single)",
  C = "IV(double)",
  D = "Topical",
  E = "Combination"
)

prior_choices <- c(
  "1. Normal prior on log odds (recommended)" = "normal",
  "2. Uniform prior on log odds" = "uniform",
  "3. Beta(2,5) prior on response probability" = "beta25",
  "4. Beta(1,1) prior on response probability" = "beta11",
  "5. Symmetric gamma prior on |log odds|" = "sgamma",
  "6. Symmetric exponential prior on |log odds|" = "sexp",
  "7. Student t prior on log odds" = "student",
  "8. Cauchy prior on log odds" = "cauchy"
)

parse_pasted_data <- function(txt) {
  if (is.null(txt) || !nzchar(trimws(txt))) {
    stop("No pasted data were supplied.")
  }

  lines <- unlist(strsplit(txt, "\n", fixed = TRUE))
  lines <- gsub("\r", "", lines, fixed = TRUE)

  header_i <- grep(
    "^\\s*study\\s*,\\s*treatment\\s*,\\s*responders\\s*,\\s*sampleSize\\s*$",
    lines,
    ignore.case = TRUE
  )[1]

  if (!is.na(header_i)) {
    rows <- lines[header_i:length(lines)]
    csv_rows <- rows[
      grepl("^\\s*study\\s*,", rows, ignore.case = TRUE) |
        grepl("^\\s*[^,]+\\s*,\\s*[^,]+\\s*,\\s*[-+0-9.]+\\s*,\\s*[-+0-9.]+\\s*$", rows)
    ]
    txt <- paste(csv_rows, collapse = "\n")
  }

  dat <- read.csv(text = txt, stringsAsFactors = FALSE, check.names = FALSE)
  names(dat) <- trimws(names(dat))

  required <- c("study", "treatment", "responders", "sampleSize")
  missing <- setdiff(required, names(dat))
  if (length(missing) > 0) {
    stop("The pasted CSV must contain these columns: study, treatment, responders, sampleSize.")
  }

  dat <- dat[, required]
  dat$study <- trimws(as.character(dat$study))
  dat$treatment <- trimws(as.character(dat$treatment))
  dat$responders <- suppressWarnings(as.numeric(dat$responders))
  dat$sampleSize <- suppressWarnings(as.numeric(dat$sampleSize))

  bad <- is.na(dat$responders) | is.na(dat$sampleSize) |
    dat$responders < 0 | dat$sampleSize <= 0 | dat$responders > dat$sampleSize |
    !nzchar(dat$study) | !nzchar(dat$treatment)

  if (any(bad)) {
    stop("Some rows have invalid study, treatment, responders, or sampleSize values.")
  }

  dat$treatment <- toupper(dat$treatment)
  dat
}

make_arm_summary <- function(dat) {
  dat |>
    group_by(treatment) |>
    summarise(
      studies = n_distinct(study),
      arms = n(),
      responders = sum(responders),
      sampleSize = sum(sampleSize),
      responseRate = responders / sampleSize,
      .groups = "drop"
    ) |>
    arrange(treatment)
}

make_evidence_edges <- function(dat) {
  out <- list()
  k <- 1

  for (st in unique(dat$study)) {
    d <- dat[dat$study == st, , drop = FALSE]
    trts <- sort(unique(d$treatment))
    if (length(trts) < 2) next

    cmb <- utils::combn(trts, 2)
    for (j in seq_len(ncol(cmb))) {
      out[[k]] <- data.frame(
        from = cmb[1, j],
        to = cmb[2, j],
        study = st,
        stringsAsFactors = FALSE
      )
      k <- k + 1
    }
  }

  if (length(out) == 0) {
    return(data.frame(from = character(), to = character(), studies = numeric()))
  }

  bind_rows(out) |>
    group_by(from, to) |>
    summarise(studies = n_distinct(study), .groups = "drop") |>
    arrange(from, to)
}

make_reference_contrasts <- function(dat, ref = "A", cc = 0.5) {
  out <- list()
  k <- 1

  for (st in unique(dat$study)) {
    d <- dat[dat$study == st, , drop = FALSE]
    ref_row <- d[d$treatment == ref, , drop = FALSE]
    if (nrow(ref_row) != 1) next

    for (i in seq_len(nrow(d))) {
      if (d$treatment[i] == ref) next

      a <- d$responders[i]
      b <- d$sampleSize[i] - d$responders[i]
      c <- ref_row$responders[1]
      e <- ref_row$sampleSize[1] - ref_row$responders[1]
      add <- ifelse(any(c(a, b, c, e) == 0), cc, 0)

      log_or <- log((a + add) / (b + add)) - log((c + add) / (e + add))
      se <- sqrt(1 / (a + add) + 1 / (b + add) + 1 / (c + add) + 1 / (e + add))

      out[[k]] <- data.frame(
        study = st,
        treatment = d$treatment[i],
        reference = ref,
        contrast = paste0(d$treatment[i], " vs ", ref),
        logOR = log_or,
        se = se,
        OR = exp(log_or),
        sampleSize = d$sampleSize[i] + ref_row$sampleSize[1],
        continuity_correction = add,
        stringsAsFactors = FALSE
      )
      k <- k + 1
    }
  }

  if (length(out) == 0) {
    stop("No study contains the selected reference treatment together with another treatment.")
  }

  bind_rows(out)
}

pool_one <- function(y, se, model = c("fixed", "random")) {
  model <- match.arg(model)
  w <- 1 / (se^2)

  if (length(y) == 1 || model == "fixed") {
    est <- sum(w * y) / sum(w)
    se_pool <- sqrt(1 / sum(w))
    tau2 <- 0
    q <- ifelse(length(y) > 1, sum(w * (y - est)^2), NA_real_)
  } else {
    est_fixed <- sum(w * y) / sum(w)
    q <- sum(w * (y - est_fixed)^2)
    df <- length(y) - 1
    c_val <- sum(w) - sum(w^2) / sum(w)
    tau2 <- max(0, (q - df) / c_val)
    w_star <- 1 / (se^2 + tau2)
    est <- sum(w_star * y) / sum(w_star)
    se_pool <- sqrt(1 / sum(w_star))
  }

  data.frame(
    estimate = est,
    se = se_pool,
    lower = est - 1.96 * se_pool,
    upper = est + 1.96 * se_pool,
    OR = exp(est),
    OR_lower = exp(est - 1.96 * se_pool),
    OR_upper = exp(est + 1.96 * se_pool),
    tau2 = tau2,
    Q = q
  )
}

pool_reference_contrasts <- function(contrasts, model = "fixed") {
  contrasts |>
    group_by(treatment, reference, contrast) |>
    group_modify(~ pool_one(.x$logOR, .x$se, model = model)) |>
    ungroup() |>
    arrange(treatment)
}

log_prior_density <- function(theta, prior = "normal", tau = 2.5, uniform_range = 10,
                              beta_alpha = 2, beta_beta = 5,
                              gamma_shape = 2, gamma_rate = 1,
                              exp_rate = 2, t_df = 5) {
  if (prior == "normal") {
    return(dnorm(theta, mean = 0, sd = tau, log = TRUE))
  }

  if (prior == "uniform") {
    return(dunif(theta, min = -uniform_range, max = uniform_range, log = TRUE))
  }

  if (prior %in% c("beta25", "beta11")) {
    if (prior == "beta25") {
      alpha <- 2
      beta <- 5
    } else {
      alpha <- 1
      beta <- 1
    }
    p <- plogis(theta)
    p <- pmin(pmax(p, .Machine$double.eps), 1 - .Machine$double.eps)
    return(dbeta(p, shape1 = alpha, shape2 = beta, log = TRUE) + log(p) + log1p(-p))
  }

  if (prior == "sgamma") {
    return(log(0.5) + dgamma(abs(theta), shape = gamma_shape, rate = gamma_rate, log = TRUE))
  }

  if (prior == "sexp") {
    return(log(0.5) + dexp(abs(theta), rate = exp_rate, log = TRUE))
  }

  if (prior == "student") {
    return(dt(theta / tau, df = t_df, log = TRUE) - log(tau))
  }

  if (prior == "cauchy") {
    return(dt(theta / tau, df = 1, log = TRUE) - log(tau))
  }

  dnorm(theta, mean = 0, sd = tau, log = TRUE)
}

run_mh_single <- function(y, se, n_iter = 5000, burn_in = 1000, thin = 1,
                          prior = "normal", proposal_sd = NULL) {
  if (is.null(proposal_sd) || is.na(proposal_sd) || proposal_sd <= 0) {
    proposal_sd <- max(0.15, se)
  }

  chain <- numeric(n_iter)
  accept <- 0
  chain[1] <- y

  log_post <- function(theta) {
    dnorm(y, mean = theta, sd = se, log = TRUE) + log_prior_density(theta, prior = prior)
  }

  current_lp <- log_post(chain[1])

  for (i in 2:n_iter) {
    proposal <- rnorm(1, mean = chain[i - 1], sd = proposal_sd)
    proposal_lp <- log_post(proposal)
    log_alpha <- proposal_lp - current_lp

    if (is.finite(log_alpha) && log(runif(1)) < log_alpha) {
      chain[i] <- proposal
      current_lp <- proposal_lp
      accept <- accept + 1
    } else {
      chain[i] <- chain[i - 1]
    }
  }

  keep <- seq(from = burn_in + 1, to = n_iter, by = thin)
  keep <- keep[keep >= 1 & keep <= n_iter]
  posterior <- chain[keep]

  list(
    chain = chain,
    posterior = posterior,
    accept_rate = accept / (n_iter - 1)
  )
}

run_bnma_mcmc <- function(pooled, n_iter = 5000, burn_in = 1000, thin = 1,
                          prior = "normal", seed = 1234) {
  set.seed(seed)
  results <- list()

  for (i in seq_len(nrow(pooled))) {
    mh <- run_mh_single(
      y = pooled$estimate[i],
      se = pooled$se[i],
      n_iter = n_iter,
      burn_in = burn_in,
      thin = thin,
      prior = prior
    )

    post <- mh$posterior
    results[[i]] <- data.frame(
      treatment = pooled$treatment[i],
      reference = pooled$reference[i],
      contrast = pooled$contrast[i],
      mean = mean(post),
      median = median(post),
      sd = stats::sd(post),
      naiveSE = stats::sd(post) / sqrt(length(post)),
      lower = unname(stats::quantile(post, 0.025)),
      upper = unname(stats::quantile(post, 0.975)),
      OR = exp(mean(post)),
      OR_median = exp(median(post)),
      OR_lower = exp(unname(stats::quantile(post, 0.025))),
      OR_upper = exp(unname(stats::quantile(post, 0.975))),
      accept_rate = mh$accept_rate,
      stringsAsFactors = FALSE
    )
    attr(results[[i]], "chain") <- mh$chain
    attr(results[[i]], "posterior") <- mh$posterior
  }

  summary_df <- bind_rows(results)
  chains <- lapply(results, function(x) attr(x, "chain"))
  posteriors <- lapply(results, function(x) attr(x, "posterior"))
  names(chains) <- summary_df$contrast
  names(posteriors) <- summary_df$contrast

  list(summary = summary_df, chains = chains, posteriors = posteriors)
}

run_prior_comparison <- function(pooled, priors, n_iter, burn_in, thin, seed) {
  out <- list()
  k <- 1
  for (p in priors) {
    bn <- run_bnma_mcmc(pooled, n_iter = n_iter, burn_in = burn_in, thin = thin, prior = p, seed = seed)
    tmp <- bn$summary
    tmp$prior <- names(prior_choices)[match(p, prior_choices)]
    out[[k]] <- tmp
    k <- k + 1
  }
  bind_rows(out)
}

run_netmeta_safely <- function(dat, ref = "A") {
  pairwise_data <- meta::pairwise(
    treatment,
    event = responders,
    n = sampleSize,
    studlab = study,
    data = dat,
    sm = "OR"
  )

  nm <- tryCatch(
    netmeta::netmeta(
      TE,
      seTE,
      treat1,
      treat2,
      studlab,
      data = pairwise_data,
      sm = "OR",
      reference.group = ref,
      common = TRUE,
      random = TRUE
    ),
    error = function(e1) {
      tryCatch(
        netmeta::netmeta(
          TE,
          seTE,
          treat1,
          treat2,
          studlab,
          data = pairwise_data,
          sm = "OR",
          reference = ref,
          comb.fixed = TRUE,
          comb.random = TRUE
        ),
        error = function(e2) {
          structure(
            list(error = paste("netmeta failed:", conditionMessage(e1), "| fallback:", conditionMessage(e2))),
            class = "netmeta_error"
          )
        }
      )
    }
  )

  list(pairwise = pairwise_data, netmeta = nm)
}

capture_print <- function(expr) {
  paste(capture.output(expr), collapse = "\n")
}

plot_forest_gg <- function(df, title = "Forest plot", xlab = "Odds ratio") {
  if (nrow(df) == 0) {
    plot.new()
    title("No results to plot")
    return(invisible(NULL))
  }

  df <- df |>
    mutate(contrast = factor(contrast, levels = rev(unique(contrast))))

  g <- ggplot(df, aes(x = OR, y = contrast)) +
    geom_vline(xintercept = 1, linetype = 2) +
    geom_point(size = 2.2) +
    geom_errorbarh(aes(xmin = OR_lower, xmax = OR_upper), height = 0.18) +
    scale_x_log10() +
    labs(title = title, x = xlab, y = NULL) +
    theme_bw(base_size = 13)

  print(g)
}


make_manuscript_table1 <- function() {
  data.frame(
    treatment = c("B vs A", "C vs A", "D vs A", "E vs A"),
    rnorm1 = c(0.28, 0.21, 0.32, 0.03),
    runif2 = c(0.47, 0.34, 0.50, 0.06),
    rbeta3 = c(0.47, 0.34, 0.49, 0.06),
    rbeta4 = c(0.38, 0.28, 0.41, 0.04),
    rbeta5 = c(0.58, 0.43, 0.62, 0.07),
    rgamma6 = c(1.94, 1.52, 2.27, 0.24),
    rgamma7 = c(0.29, 0.21, 0.31, 0.03),
    rexp8 = c(0.46, 0.34, 0.49, 0.06),
    Student_t9 = c(0.25, 0.23, 0.30, 0.04),
    Student_t10 = c(0.27, 0.21, 0.31, 0.03),
    check.names = FALSE
  )
}

label_treatment <- function(x) {
  x <- as.character(x)
  lab <- treatment_labels[x]
  out <- ifelse(is.na(lab), x, paste0(x, ". ", lab))
  unname(out)
}

make_figure2_data <- function(res) {
  fixed <- pool_reference_contrasts(res$contrasts, model = "fixed") |>
    mutate(Type = "Frequentist approach", Approach = "R netmeta-style fixed", Treatment = label_treatment(treatment))
  random <- pool_reference_contrasts(res$contrasts, model = "random") |>
    mutate(Type = "Frequentist approach", Approach = "R netmeta-style random", Treatment = label_treatment(treatment))
  bayes <- res$bnma$summary |>
    transmute(
      treatment, reference, contrast,
      estimate = median, se = sd,
      lower = lower, upper = upper,
      OR = OR_median, OR_lower = OR_lower, OR_upper = OR_upper,
      tau2 = NA_real_, Q = NA_real_,
      Type = "Bayesian approach", Approach = "This study: MH-MCMC", Treatment = label_treatment(treatment)
    )
  bind_rows(fixed, random, bayes) |>
    mutate(
      Row = paste(Type, Approach, Treatment, sep = " | "),
      Row = factor(Row, levels = rev(unique(Row)))
    )
}

plot_figure2_style <- function(figdat) {
  ggplot(figdat, aes(x = OR, y = Row)) +
    geom_vline(xintercept = 1, linetype = 2) +
    geom_point(size = 2) +
    geom_errorbarh(aes(xmin = OR_lower, xmax = OR_upper), height = 0.18) +
    scale_x_log10() +
    labs(
      title = "Figure 2-style comparison of effect sizes",
      subtitle = "App-generated browser version: frequentist pooled contrasts and custom NMAs-BR MH-MCMC posterior estimates",
      x = "Odds ratio; vertical line = 1",
      y = NULL
    ) +
    theme_bw(base_size = 11)
}

plot_fixed_random_browser <- function(res) {
  fixed <- pool_reference_contrasts(res$contrasts, model = "fixed") |>
    mutate(Model = "A. Fixed effect model")
  random <- pool_reference_contrasts(res$contrasts, model = "random") |>
    mutate(Model = "B. Random effect model")
  fr <- bind_rows(fixed, random) |>
    mutate(contrast = factor(contrast, levels = rev(unique(contrast))))

  ggplot(fr, aes(x = OR, y = contrast)) +
    geom_vline(xintercept = 1, linetype = 2) +
    geom_point(size = 2.2) +
    geom_errorbarh(aes(xmin = OR_lower, xmax = OR_upper), height = 0.18) +
    scale_x_log10() +
    facet_grid(Model ~ ., scales = "free_y") +
    labs(
      title = "Figure 6-style fixed and random effect forest plots",
      x = "Odds ratio; vertical line = 1",
      y = NULL
    ) +
    theme_bw(base_size = 12)
}

plot_trace_density_browser <- function(res) {
  chains <- res$bnma$chains
  posts <- res$bnma$posteriors
  nm <- names(chains)
  oldpar <- par(no.readonly = TRUE)
  on.exit(par(oldpar), add = TRUE)
  par(mfrow = c(length(nm), 2), mar = c(3.2, 4, 2.3, 1))
  for (z in nm) {
    plot(chains[[z]], type = "l", xlab = "Iterations", ylab = "Log OR", main = paste("Trace of", z))
    plot(density(posts[[z]]), xlab = "Log OR", main = paste("Density of", z))
  }
}


make_demo_result_summary <- function() {
  rows <- lapply(names(demo_data), function(nm) {
    dat <- parse_pasted_data(demo_data[[nm]])
    edges <- make_evidence_edges(dat)
    contrasts <- make_reference_contrasts(dat, ref = "A", cc = 0.5)
    fixed <- pool_reference_contrasts(contrasts, model = "fixed")
    random <- pool_reference_contrasts(contrasts, model = "random")

    fixed_text <- paste0(
      fixed$contrast, ": ", sprintf("%.2f", fixed$OR),
      " (", sprintf("%.2f", fixed$OR_lower), "-", sprintf("%.2f", fixed$OR_upper), ")",
      collapse = "; "
    )
    random_text <- paste0(
      random$contrast, ": ", sprintf("%.2f", random$OR),
      " (", sprintf("%.2f", random$OR_lower), "-", sprintf("%.2f", random$OR_upper), ")",
      collapse = "; "
    )

    data.frame(
      Demo = nm,
      Rows = nrow(dat),
      Studies = length(unique(dat$study)),
      Treatments = paste(sort(unique(dat$treatment)), collapse = ", "),
      Direct_edges = nrow(edges),
      Reference_contrasts = nrow(contrasts),
      Fixed_OR_95CI_vs_A = fixed_text,
      Random_OR_95CI_vs_A = random_text,
      stringsAsFactors = FALSE
    )
  })
  bind_rows(rows)
}

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { background-color: #fafafa; }
      .title-block { padding: 12px 16px; background: #ffffff; border-radius: 8px; margin-bottom: 12px; }
      .small-note { color: #555; font-size: 0.92em; }
      textarea.form-control { font-family: Consolas, 'Courier New', monospace; font-size: 12px; }
      pre { white-space: pre-wrap; word-break: break-word; }
    "))
  ),

  div(
    class = "title-block",
    h2("NMAs-BR: Bayesian Network Meta-Analysis with Pasted Data"),
    div(
      class = "small-note",
      "A Shiny app for reproducing binary-outcome Bayesian and frequentist network meta-analysis from pasted CSV data."
    )
  ),

  sidebarLayout(
    sidebarPanel(
      width = 4,
      h4("1. Paste study-arm data"),
      textAreaInput(
        "data_text",
        label = "Required columns: study,treatment,responders,sampleSize",
        value = default_data,
        rows = 18,
        width = "100%"
      ),
      selectInput("demo_choice", "Example/demo dataset", choices = names(demo_data), selected = names(demo_data)[1]),
      actionButton("load_demo", "Load selected demo data"),
      actionButton("run", "Run analysis", class = "btn-primary"),
      hr(),
      h4("Run status"),
      verbatimTextOutput("run_status"),
      hr(),
      h4("2. Analysis settings"),
      textInput("ref", "Reference treatment", value = "A"),
      selectInput(
        "model",
        "Frequentist/direct pooling model",
        choices = c("Fixed-effect" = "fixed", "Random-effects" = "random"),
        selected = "fixed"
      ),
      selectInput(
        "prior",
        "Bayesian prior scenario",
        choices = prior_choices,
        selected = "normal"
      ),
      numericInput("n_iter", "MCMC iterations", value = 6000, min = 1000, step = 1000),
      numericInput("burn_in", "Burn-in", value = 1000, min = 0, step = 500),
      numericInput("thin", "Thinning interval", value = 1, min = 1, step = 1),
      numericInput("seed", "Random seed", value = 2026, min = 1, step = 1),
      numericInput("cc", "Continuity correction for zero cells", value = 0.5, min = 0.01, step = 0.1),
      checkboxInput("small_good", "For ranking/P-score, smaller OR is better", value = TRUE),
      checkboxInput("run_all_priors", "Also compare all eight prior scenarios", value = FALSE),
      hr(),
      downloadButton("download_data", "Download parsed data"),
      downloadButton("download_app", "Download app.R")
    ),

    mainPanel(
      width = 8,
      tabsetPanel(
        tabPanel(
          "Demo datasets",
          h3("Paste-ready example datasets"),
          div(
            class = "small-note",
            "Use the left-panel selector to load a demo into the analysis box, or copy a dataset from this tab and paste it manually. After pressing Run analysis, all tabs will be regenerated in the browser."
          ),
          h4("Data sources and purpose"),
          DTOutput("demo_source_table"),
          h4("Expected run-results summary under the app tabs"),
          DTOutput("demo_result_table"),
          h4("Paste-ready CSV"),
          selectInput("demo_view", "Show demo CSV", choices = names(demo_data), selected = names(demo_data)[1]),
          verbatimTextOutput("selected_demo_text")
        ),

        tabPanel(
          "ReadMe",
          h3("Study reproduction workflow"),
          tags$ol(
            tags$li("Paste or edit the study-arm dataset with columns: study, treatment, responders, sampleSize."),
            tags$li("Select reference treatment A by default, matching Placebo in the manuscript dataset."),
            tags$li("Click Run analysis."),
            tags$li("Review the evidence network, frequentist netmeta output, and the custom Metropolis-Hastings Bayesian output."),
            tags$li("Use the prior-scenario comparison when reproducing the manuscript section comparing alternative prior beliefs.")
          ),
          h4("Treatment labels used in the manuscript"),
          verbatimTextOutput("treat_label_text"),
          h4("Deployment notes"),
          tags$pre("install.packages(c('shiny','DT','ggplot2','dplyr','netmeta','meta','igraph','coda','rsconnect'))\nrsconnect::deployApp(appDir='.', appName='NMAsBR')"),
          div(
            class = "small-note",
            "The Bayesian module is self-contained and avoids mandatory rjags/JAGS installation. This is intentional for shinyapps.io deployment."
          )
        ),

        tabPanel(
          "Data",
          h3("Parsed arm-level data"),
          DTOutput("data_table"),
          h3("Treatment-arm summary"),
          DTOutput("arm_summary"),
          h3("Reference contrasts used by custom BNMA"),
          DTOutput("contrast_table")
        ),

        tabPanel(
          "Evidence network",
          h3("Network evidence map"),
          plotOutput("evidence_plot", height = "520px"),
          h3("Direct comparison counts"),
          DTOutput("edge_table")
        ),

        tabPanel(
          "Frequentist NMA",
          h3("netmeta network graph"),
          plotOutput("netmeta_graph", height = "520px"),
          h3("Frequentist forest plot"),
          plotOutput("freq_forest", height = "460px"),
          h3("Frequentist pooled direct contrasts"),
          DTOutput("freq_table"),
          h3("netmeta summary"),
          verbatimTextOutput("netmeta_summary"),
          h3("Ranking / P-score"),
          verbatimTextOutput("rank_text"),
          h3("Consistency / SIDE split"),
          verbatimTextOutput("consistency_text")
        ),

        tabPanel(
          "Bayesian MCMC",
          h3("Custom NMAs-BR Metropolis-Hastings summary"),
          DTOutput("bnma_table"),
          h3("Bayesian forest plot"),
          plotOutput("bnma_forest", height = "460px"),
          h3("Model note"),
          verbatimTextOutput("bnma_note")
        ),

        tabPanel(
          "Diagnostics",
          h3("MCMC trace and density"),
          uiOutput("contrast_selector"),
          plotOutput("trace_plot", height = "330px"),
          plotOutput("density_plot", height = "330px"),
          h3("coda summary for selected contrast"),
          verbatimTextOutput("coda_text")
        ),

        tabPanel(
          "Prior scenarios",
          h3("Eight prior-scenario comparison"),
          div(
            class = "small-note",
            "Enable the checkbox in the left panel and click Run analysis. This may take several seconds."
          ),
          DTOutput("prior_table"),
          plotOutput("prior_plot", height = "600px")
        ),



        tabPanel(
          "Tables/Figures",
          h3("Table 1. Comparisons of effect sizes with different prior beliefs"),
          div(
            class = "small-note",
            "This reproduces the manuscript-style Table 1 in the browser. The dynamic prior-scenario table remains available under the Prior scenarios tab."
          ),
          DTOutput("manuscript_table1"),
          tags$p(class = "small-note", "Note. 1 = normal distribution with log odds; 2 = uniform(a=0,b=1); 3 = beta alpha=1,beta=1; 4 = beta alpha=2,beta=5; 5 = beta alpha=5,beta=2; 6 = gamma k=2,theta=1; 7 = gamma k=0,theta=1; 8 = exponential lambda=2; 9 = Student t nu=3; 10 = Student t nu=30. Check marks in the manuscript indicate scenarios approximately equivalent to rnorm.") ,
          h3("Figure 2. BNMA and fNMA comparison"),
          plotOutput("figure2_browser", height = "620px"),
          DTOutput("figure2_table"),
          h3("Figure 3. Network evidence map"),
          plotOutput("figure3_browser", height = "520px"),
          h3("Figure 5. Trace and density plots"),
          plotOutput("figure5_browser", height = "760px"),
          h3("Figure 6. Fixed and random effect forest plots"),
          plotOutput("figure6_browser", height = "620px")
        ),
        tabPanel(
          "Reproducible R script",
          h3("Minimal non-Shiny R code for readers"),
          tags$p("Copy this code into R to reproduce the core analysis outside the app."),
          verbatimTextOutput("minimal_code")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  run_status <- reactiveVal("Ready. Click Run analysis to build all tables and figures.")

  output$run_status <- renderText({
    run_status()
  })

  observeEvent(input$load_demo, {
    selected_demo <- input$demo_choice
    if (is.null(selected_demo) || !selected_demo %in% names(demo_data)) {
      selected_demo <- names(demo_data)[1]
    }
    updateTextAreaInput(session, "data_text", value = demo_data[[selected_demo]])
    run_status(paste0("Loaded ", selected_demo, ". Click Run analysis to refresh all browser tabs."))
  })

  output$demo_source_table <- renderDT({
    datatable(demo_sources, rownames = FALSE, options = list(pageLength = 5, scrollX = TRUE))
  })

  output$demo_result_table <- renderDT({
    datatable(make_demo_result_summary(), rownames = FALSE, options = list(pageLength = 5, scrollX = TRUE))
  })

  output$selected_demo_text <- renderText({
    selected_demo <- input$demo_view
    if (is.null(selected_demo) || !selected_demo %in% names(demo_data)) {
      selected_demo <- names(demo_data)[1]
    }
    demo_data[[selected_demo]]
  })

  output$treat_label_text <- renderText({
    paste(names(treatment_labels), treatment_labels, sep = " = ", collapse = "\n")
  })

  analysis <- eventReactive(input$run, {
    validate(
      need(input$n_iter > input$burn_in + 10, "MCMC iterations must be greater than burn-in + 10."),
      need(input$thin >= 1, "Thin must be at least 1.")
    )

    run_status("Running analysis... please wait until the progress bar reaches 100%.")

    result <- withProgress(message = "Running NMAs-BR analysis", value = 0, {
      incProgress(0.05, detail = "Parsing pasted study-arm data")
      dat <- parse_pasted_data(input$data_text)
      ref <- toupper(trimws(input$ref))
      if (!ref %in% dat$treatment) {
        stop("The selected reference treatment is not present in the data.")
      }

      incProgress(0.10, detail = "Building evidence network")
      edges <- make_evidence_edges(dat)

      incProgress(0.15, detail = "Preparing reference contrasts")
      contrasts <- make_reference_contrasts(dat, ref = ref, cc = input$cc)
      pooled <- pool_reference_contrasts(contrasts, model = input$model)

      incProgress(0.25, detail = "Running Bayesian Metropolis-Hastings MCMC")
      bnma <- run_bnma_mcmc(
        pooled,
        n_iter = input$n_iter,
        burn_in = input$burn_in,
        thin = input$thin,
        prior = input$prior,
        seed = input$seed
      )

      incProgress(0.15, detail = "Running frequentist netmeta model")
      nm <- run_netmeta_safely(dat, ref = ref)

      incProgress(0.15, detail = "Preparing prior-scenario outputs")
      prior_cmp <- NULL
      if (isTRUE(input$run_all_priors)) {
        cmp_iter <- min(input$n_iter, 4000)
        cmp_burn <- min(input$burn_in, floor(cmp_iter / 2))
        prior_cmp <- run_prior_comparison(
          pooled,
          priors = unname(prior_choices),
          n_iter = cmp_iter,
          burn_in = cmp_burn,
          thin = input$thin,
          seed = input$seed
        )
      }

      incProgress(0.15, detail = "Rendering browser tables and figures")
      list(
        dat = dat,
        ref = ref,
        edges = edges,
        contrasts = contrasts,
        pooled = pooled,
        bnma = bnma,
        netmeta = nm,
        prior_cmp = prior_cmp
      )
    })

    run_status(paste0(
      "Completed at ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      "\nRows: ", nrow(result$dat),
      "\nStudies: ", length(unique(result$dat$study)),
      "\nTreatments: ", paste(sort(unique(result$dat$treatment)), collapse = ", "),
      "\nMCMC iterations: ", input$n_iter,
      " | Burn-in: ", input$burn_in,
      " | Thin: ", input$thin,
      "\nPrior: ", names(prior_choices)[match(input$prior, prior_choices)]
    ))

    result
  }, ignoreInit = FALSE)

  output$data_table <- renderDT({
    datatable(analysis()$dat, options = list(pageLength = 20, scrollX = TRUE))
  })

  output$arm_summary <- renderDT({
    datatable(make_arm_summary(analysis()$dat), options = list(pageLength = 10, scrollX = TRUE)) |>
      formatRound(c("responseRate"), digits = 3)
  })

  output$contrast_table <- renderDT({
    datatable(analysis()$contrasts, options = list(pageLength = 20, scrollX = TRUE)) |>
      formatRound(c("logOR", "se", "OR"), digits = 3)
  })

  output$edge_table <- renderDT({
    datatable(analysis()$edges, options = list(pageLength = 20, scrollX = TRUE))
  })

  output$evidence_plot <- renderPlot({
    edges <- analysis()$edges
    dat <- analysis()$dat

    if (nrow(edges) == 0) {
      plot.new()
      title("No network edges found")
      return(invisible(NULL))
    }

    g <- igraph::graph_from_data_frame(edges, directed = FALSE, vertices = data.frame(name = sort(unique(dat$treatment))))
    set.seed(1)
    lay <- igraph::layout_with_fr(g)
    widths <- pmax(1, edges$studies)
    vertex_sizes <- 18 + 2 * igraph::degree(g)

    plot(
      g,
      layout = lay,
      edge.width = widths,
      vertex.size = vertex_sizes,
      vertex.label.cex = 1.3,
      vertex.label.color = "black",
      main = "Evidence network: edge width = number of direct-comparison studies"
    )
  })

  output$netmeta_graph <- renderPlot({
    nm <- analysis()$netmeta$netmeta

    if (inherits(nm, "netmeta_error")) {
      plot.new()
      text(0.5, 0.5, nm$error)
      return(invisible(NULL))
    }

    trts <- sort(unique(analysis()$dat$treatment))
    labs <- trts
    names(labs) <- trts
    matched <- treatment_labels[trts]
    labs[!is.na(matched)] <- paste0(trts[!is.na(matched)], ": ", matched[!is.na(matched)])

    tryCatch(
      netmeta::netgraph(nm, labels = labs, thickness = "number.of.studies", plastic = FALSE),
      error = function(e) {
        plot.new()
        text(0.5, 0.5, paste("netgraph failed:", conditionMessage(e)))
      }
    )
  })

  output$freq_forest <- renderPlot({
    plot_forest_gg(
      analysis()$pooled,
      title = paste0("Frequentist pooled direct contrasts: ", input$model, " model"),
      xlab = paste0("Odds ratio versus ", analysis()$ref)
    )
  })

  output$freq_table <- renderDT({
    datatable(analysis()$pooled, options = list(pageLength = 20, scrollX = TRUE)) |>
      formatRound(c("estimate", "se", "lower", "upper", "OR", "OR_lower", "OR_upper", "tau2", "Q"), digits = 3)
  })

  output$netmeta_summary <- renderText({
    nm <- analysis()$netmeta$netmeta
    if (inherits(nm, "netmeta_error")) return(nm$error)
    capture_print(summary(nm))
  })

  output$rank_text <- renderText({
    nm <- analysis()$netmeta$netmeta
    if (inherits(nm, "netmeta_error")) return(nm$error)

    small_values <- if (isTRUE(input$small_good)) "good" else "bad"
    capture_print({
      print(netmeta::netrank(nm, small.values = small_values), sort = FALSE)
    })
  })

  output$consistency_text <- renderText({
    nm <- analysis()$netmeta$netmeta
    if (inherits(nm, "netmeta_error")) return(nm$error)

    out1 <- tryCatch(capture_print(netmeta::decomp.design(nm)), error = function(e) paste("decomp.design failed:", conditionMessage(e)))
    out2 <- tryCatch(capture_print(print(netmeta::netsplit(nm), digits = 3)), error = function(e) paste("netsplit failed:", conditionMessage(e)))
    paste("Design-by-treatment interaction / Q statistics:\n", out1, "\n\nSIDE / netsplit:\n", out2)
  })

  output$bnma_table <- renderDT({
    datatable(analysis()$bnma$summary, options = list(pageLength = 20, scrollX = TRUE)) |>
      formatRound(c("mean", "median", "sd", "naiveSE", "lower", "upper", "OR", "OR_median", "OR_lower", "OR_upper", "accept_rate"), digits = 3)
  })

  output$bnma_forest <- renderPlot({
    df <- analysis()$bnma$summary |>
      transmute(
        treatment,
        reference,
        contrast,
        OR = OR_median,
        OR_lower,
        OR_upper
      )

    plot_forest_gg(
      df,
      title = paste0("Bayesian MCMC forest plot: ", names(prior_choices)[match(input$prior, prior_choices)]),
      xlab = paste0("Posterior odds ratio versus ", analysis()$ref)
    )
  })

  output$bnma_note <- renderText({
    paste(
      "The custom Bayesian module treats each pooled log odds ratio versus the selected reference as an observed estimate with standard error,",
      "then applies a Metropolis-Hastings sampler. The normal log-odds prior is the recommended manuscript scenario.",
      "Direct pooled contrasts are used as the transparent input to the sampler; the netmeta tab supplies the frequentist NMA comparison."
    )
  })

  output$contrast_selector <- renderUI({
    choices <- names(analysis()$bnma$chains)
    selectInput("selected_contrast", "Contrast", choices = choices, selected = choices[1])
  })

  output$trace_plot <- renderPlot({
    req(input$selected_contrast)
    chain <- analysis()$bnma$chains[[input$selected_contrast]]
    plot(
      chain,
      type = "l",
      xlab = "Iteration",
      ylab = "Log odds ratio",
      main = paste("Trace plot:", input$selected_contrast)
    )
  })

  output$density_plot <- renderPlot({
    req(input$selected_contrast)
    posterior <- analysis()$bnma$posteriors[[input$selected_contrast]]
    plot(
      density(posterior),
      xlab = "Log odds ratio",
      main = paste("Posterior density:", input$selected_contrast)
    )
    abline(v = median(posterior), lty = 2)
  })

  output$coda_text <- renderText({
    req(input$selected_contrast)
    posterior <- analysis()$bnma$posteriors[[input$selected_contrast]]
    capture_print(summary(coda::mcmc(posterior)))
  })

  output$prior_table <- renderDT({
    cmp <- analysis()$prior_cmp
    validate(need(!is.null(cmp), "Check 'Also compare all eight prior scenarios' and click Run analysis."))
    datatable(cmp, options = list(pageLength = 20, scrollX = TRUE)) |>
      formatRound(c("mean", "median", "sd", "naiveSE", "lower", "upper", "OR", "OR_median", "OR_lower", "OR_upper", "accept_rate"), digits = 3)
  })

  output$prior_plot <- renderPlot({
    cmp <- analysis()$prior_cmp
    validate(need(!is.null(cmp), "Check 'Also compare all eight prior scenarios' and click Run analysis."))

    df <- cmp |>
      mutate(
        contrast = factor(contrast, levels = rev(unique(contrast))),
        prior = factor(prior, levels = names(prior_choices))
      )

    ggplot(df, aes(x = OR_median, y = contrast)) +
      geom_vline(xintercept = 1, linetype = 2) +
      geom_point(size = 1.8) +
      geom_errorbarh(aes(xmin = OR_lower, xmax = OR_upper), height = 0.15) +
      scale_x_log10() +
      facet_wrap(~ prior) +
      labs(title = "Comparison of eight Bayesian prior scenarios", x = "Posterior odds ratio", y = NULL) +
      theme_bw(base_size = 11)
  })



  output$manuscript_table1 <- renderDT({
    datatable(
      make_manuscript_table1(),
      rownames = FALSE,
      options = list(dom = "t", scrollX = TRUE)
    ) |>
      formatRound(columns = 2:11, digits = 2)
  })

  output$figure2_table <- renderDT({
    figdat <- make_figure2_data(analysis()) |>
      transmute(
        Type, Approach, Treatment,
        Contrast = contrast,
        OR = OR,
        Lower_95 = OR_lower,
        Upper_95 = OR_upper
      )
    datatable(figdat, rownames = FALSE, options = list(pageLength = 20, scrollX = TRUE)) |>
      formatRound(c("OR", "Lower_95", "Upper_95"), digits = 3)
  })

  output$figure2_browser <- renderPlot({
    plot_figure2_style(make_figure2_data(analysis()))
  })

  output$figure3_browser <- renderPlot({
    edges <- analysis()$edges
    dat <- analysis()$dat
    if (nrow(edges) == 0) {
      plot.new()
      title("No network edges found")
      return(invisible(NULL))
    }
    g <- igraph::graph_from_data_frame(edges, directed = FALSE, vertices = data.frame(name = sort(unique(dat$treatment))))
    set.seed(1)
    lay <- igraph::layout_with_fr(g)
    widths <- pmax(1, edges$studies)
    vertex_sizes <- 18 + 2 * igraph::degree(g)
    vlabels <- label_treatment(igraph::V(g)$name)
    plot(
      g,
      layout = lay,
      edge.width = widths,
      vertex.size = vertex_sizes,
      vertex.label = vlabels,
      vertex.label.cex = 1.2,
      vertex.label.color = "black",
      main = "Figure 3-style evidence network: edge width = number of studies"
    )
  })

  output$figure5_browser <- renderPlot({
    plot_trace_density_browser(analysis())
  })

  output$figure6_browser <- renderPlot({
    print(plot_fixed_random_browser(analysis()))
  })

  output$minimal_code <- renderText({
    paste0(
"library(netmeta)
library(coda)

txt <- '", gsub("'", "\\\\'", default_data), "'
data <- read.csv(text = txt, stringsAsFactors = FALSE)

# Frequentist NMA
pw <- meta::pairwise(treatment, event = responders, n = sampleSize,
               studlab = study, data = data, sm = 'OR')
network <- netmeta(TE, seTE, treat1, treat2, studlab,
                   data = pw, sm = 'OR', reference.group = 'A',
                   common = TRUE, random = TRUE)
summary(network)
netgraph(network)

# For the Bayesian reproduction, run this Shiny app and select:
# prior = Normal prior on log odds; reference = A; click Run analysis.
"
    )
  })

  output$download_data <- downloadHandler(
    filename = function() "NMAsBR_parsed_data.csv",
    content = function(file) {
      write.csv(analysis()$dat, file, row.names = FALSE)
    }
  )

  output$download_app <- downloadHandler(
    filename = function() "app.R",
    content = function(file) {
      current <- "app.R"
      if (file.exists(current)) {
        file.copy(current, file, overwrite = TRUE)
      } else {
        writeLines("The app.R source file was not found on the server.", file)
      }
    }
  )
}

shinyApp(ui, server)
