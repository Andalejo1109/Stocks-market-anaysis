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

### Installation

```R
# Install all required packages
install.packages(c("quantmod", "PerformanceAnalytics", "PortfolioAnalytics", "tseries"))
