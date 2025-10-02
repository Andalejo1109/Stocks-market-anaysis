# Portfolio Analysis and Optimization with R

This repository contains an educational project demonstrating the application of **Modern Portfolio Theory (MPT)**, specifically the **Markowitz Model**, using the **R programming language**. The goal is to analyze the historical performance of a personal investment portfolio and determine the optimal asset allocation for maximum risk-adjusted returns (Maximum Sharpe Ratio).

---

## 🚀 Project Overview

The project follows a standard quantitative finance methodology:

1.  **Data Acquisition:** Downloading historical adjusted closing prices for the selected ETFs and stock.
2.  **Performance Analysis:** Calculating the returns, risk (volatility), and Sharpe Ratio of the current portfolio.
3.  **Optimization:** Identifying the **Efficient Frontier** and determining the **Tangency Portfolio** (Maximum Sharpe Ratio Portfolio).
4.  **Decision Making:** Comparing the current allocation against the optimal one to suggest rebalancing.

## 📊 Portfolio Composition

The initial portfolio consists of five assets with the following weights, invested from **January 1, 2022**:

| Asset | Ticker | Initial Weight ($w_i$) | Category |
| :--- | :---: | :---: | :--- |
| Vanguard Total Stock Market Index Fund ETF Shares | **VTI** | 10% | Broad Market |
| Vanguard S&P 500 ETF | **VOO** | 8% | Large Cap |
| SPDR Portfolio S&P 500 Growth ETF | **SPYG** | 42% | Growth |
| VanEck Vectors Semiconductor ETF | **SMH** | 16% | Sector (Tech) |
| Berkshire Hathaway Inc. Class B | **BRK.B** | 23% | Conglomerate |
| **Total** | | **100%** | |

---

## 🛠️ R Environment and Libraries

The following R packages are essential for running the analysis:

| Package | Purpose |
| :--- | :--- |
| `quantmod` | Download financial data from sources like Yahoo Finance. |
| `PerformanceAnalytics` | Calculate standardized portfolio performance metrics (Returns, Sharpe, etc.). |
| `PortfolioAnalytics` | Core library for defining constraints and objectives for optimization. |
| `tseries` | Auxiliary functions for time series and financial analysis. |

## 📈 Key Results and Optimization

The analysis yields two key portfolio structures: the current allocation and the mathematically optimal allocation based on the historical data (Max Sharpe).

---

### 1. Current Portfolio Metrics (Since 2022)

This table summarizes the performance of the initial allocation.

| Metric | Value |
| :--- | :--- |
| **Annualized Return** | 10.62% |
| **Annualized Volatility (Risk)** | 20.15% |
| **Sharpe Ratio** | 0.53 |
| **$10,000 Initial Investment Final Value** | \$14,566.42 |

---

### 2. Optimal Portfolio Allocation (Maximum Sharpe Ratio)

This allocation maximizes the return for every unit of risk taken, achieving the highest efficiency on the Efficient Frontier (Tangency Portfolio).

| Asset | Optimal Weight |
| :--- | :---: |
| VTI | 2.00% |
| VOO | 2.00% |
| SPYG | 0.00% |
| SMH | 95.58% |
| BRK.B | 0.42% |

| Optimal Metrics | Value |
| :--- | :--- |
| **Annualized Return (Optimal)** | 13.18% |
| **Annualized Volatility (Optimal)** | 18.07% |
| **Sharpe Ratio (Optimal)** | 0.73 |

## 📝 Code Snippets for Analysis
The core of the analysis involves downloading the data and running the optimization functions.

### Installation

```R
# Install all required packages
install.packages(c("quantmod", "PerformanceAnalytics", "PortfolioAnalytics", "tseries"))

# Define Tickers and Period
tickers <- c("VTI", "VOO", "SPYG", "SMH", "BRK.B")
fecha_inicio <- "2022-01-01"

# Download Data
datos_crudos <- getSymbols(tickers, from = fecha_inicio, auto.assign = FALSE)
precios_ajustados <- do.call(merge, lapply(tickers, function(x) Ad(datos_crudos[, paste0(x, ".Adjusted")])))
retornos_diarios <- na.omit(Return.calculate(precios_ajustados, method = "log"))

# --- OPTIMIZATION (Maximum Sharpe Ratio) ---
library(PortfolioAnalytics)

# 1. Define portfolio specification and constraints
port_spec_sharpe <- portfolio.spec(assets = tickers)
port_spec_sharpe <- add.constraint(port_spec_sharpe, type = "full_investment")
port_spec_sharpe <- add.constraint(port_spec_sharpe, type = "box", min = 0, max = 1)
port_spec_sharpe <- add.objective(port_spec_sharpe, type = "risk", name = "StdDev")
port_spec_sharpe <- add.objective(port_spec_sharpe, type = "return", name = "mean")

# 2. Run optimization
opt_sharpe <- optimize.portfolio(R = retornos_diarios, 
                                 portfolio = port_spec_sharpe,
                                 optimize_method = "random", # or "DEoptim" for more complex
                                 trace = TRUE, 
                                 maxSR = TRUE)

# Get optimal weights
pesos_optimos <- extractWeights(opt_sharpe)
