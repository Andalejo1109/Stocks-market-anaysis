# 1. Instalar y cargar paquetes necesarios
install.packages(c("quantmod", "PerformanceAnalytics", "PortfolioAnalytics", "tseries", "ROI"))
library(quantmod)
library(PerformanceAnalytics)
library(PortfolioAnalytics)


# 2. Definir tickers y período
tickers <- c("VTI", "VOO", "SPYG", "SMH", "BRK-B")
fecha_inicio <- "2022-01-01" # Desde 2022


# 3. Descargar precios ajustados de cierre (Adjusted Close)
datos_crudos <- getSymbols(tickers, 
                           from = fecha_inicio, 
                           auto.assign = TRUE, 
                           warnings = FALSE)

# 4. Limpiar los datos (seleccionar solo precios ajustados y unirlos)
datos_crudos <- lapply(tickers, function(x) getSymbols(x, from = fecha_inicio, auto.assign = FALSE))
precios_ajustados <- do.call(merge, lapply(datos_crudos, Ad))
colnames(precios_ajustados) <- tickers

# 5. Calcular retornos diarios logarítmicos
retornos_diarios <- na.omit(Return.calculate(precios_ajustados, method = "log"))

# 6. Definir las ponderaciones actuales del portafolio
pesos_actuales <- c(VTI = 0.10, VOO = 0.08, SPYG = 0.42, SMH = 0.16, BRK.B = 0.23)
# Ajustar si la suma no es 1 (ej. 0.10 + 0.08 + 0.42 + 0.16 + 0.23 = 0.99)
# Si la suma no es 1, reescalar (siempre debe sumar 1 para el cálculo)
pesos_actuales <- pesos_actuales / sum(pesos_actuales)

# 7. Calcular métricas del portafolio actual
retorno_portafolio <- Return.portfolio(retornos_diarios, weights = pesos_actuales)
retorno_anualizado <- Return.annualized(retorno_portafolio, scale = 252) # 252 días de negociación
riesgo_anualizado <- StdDev.annualized(retorno_portafolio, scale = 252)
sharpe_ratio <- SharpeRatio.annualized(retorno_portafolio, scale = 252)

# Imprimir resultados del portafolio actual
cat("--- Análisis del Portafolio Actual ---\n")
cat(sprintf("Retorno Anualizado Esperado: %.2f%%\n", retorno_anualizado * 100))
cat(sprintf("Volatilidad (Riesgo) Anualizada: %.2f%%\n", riesgo_anualizado * 100))
cat(sprintf("Ratio de Sharpe (sin riesgo = 0): %.2f\n", sharpe_ratio))

# 8. Proyección de $10,000 (Growth of $10,000)
inversion_inicial <- 10000
valor_final <- last(inversion_inicial * cumprod(1 + retorno_portafolio))

cat(sprintf("\n--- Proyección de $10,000 ---\n"))
cat(sprintf("El valor final proyectado de $10,000 invertidos desde %s es: $%.2f\n", 
            fecha_inicio, valor_final))



##################################################
##################################################

#B. Optimización del Portafolio (Máximo Ratio de Sharpe)
install.packages("PortfolioAnalytics")
library(PortfolioAnalytics)
# 1. Crear un objeto de portafolio con PortfolioAnalytics
port_spec <- portfolio.spec(assets = tickers)

# 2. Agregar restricciones: 
#    - Límite de largo (no se permite venta en corto): $w_i \geq 0$
#    - Suma de pesos igual a 1: $\sum w_i = 1$
port_spec <- add.constraint(port_spec, type = "full_investment") # Suma = 1
port_spec <- add.constraint(port_spec, type = "box", min = 0, max = 1) # $w_i \geq 0$

# 3. Agregar objetivo: Maximizar el Ratio de Sharpe (Portafolio Tangente)
port_spec <- add.objective(port_spec, type = "risk_aversion", name = "mean_ETL", risk_aversion = 10)
port_spec <- add.objective(port_spec, type = "return", name = "mean")

# NOTA: En la práctica, se utiliza 'max_sharpe' para simplificar o 'risk_aversion'
# para la frontera. Aquí usaremos una aproximación para obtener el portafolio de Máximo Sharpe.

# 4. Enfoque alternativo: Maximizar Sharpe Ratio directamente (más común)
port_spec_sharpe <- portfolio.spec(assets = tickers)
port_spec_sharpe <- add.constraint(port_spec_sharpe, type = "full_investment")
port_spec_sharpe <- add.constraint(port_spec_sharpe, type = "box", min = 0, max = 1)
port_spec_sharpe <- add.objective(port_spec_sharpe, type = "risk", name = "StdDev")
port_spec_sharpe <- add.objective(port_spec_sharpe, type = "return", name = "mean", target = 0.0001) # Mínimo retorno esperado

# Para maximizar Sharpe Ratio, se utiliza 'max_sharpe' o se resuelve como minimización de riesgo 
# para un retorno objetivo y se busca el que maximiza Sharpe en la Frontera Eficiente.

# Usaremos la función `optimize.portfolio` con la opción `quadprog` (Maximum Sharpe Ratio)
install.packages("DEoptim")
library(DEoptim)

opt_sharpe <- optimize.portfolio(R = retornos_diarios,
                                 portfolio = port_spec_sharpe,
                                 optimize_method = "DEoptim",
                                 trace = TRUE,
                                 maxSR = TRUE)

# 5. Obtener los pesos óptimos
pesos_optimos <- extractWeights(opt_sharpe)
retorno_optimo <- Return.annualized(Return.portfolio(retornos_diarios, weights = pesos_optimos), scale = 252)
riesgo_optimo <- StdDev.annualized(Return.portfolio(retornos_diarios, weights = pesos_optimos), scale = 252)
sharpe_optimo <- SharpeRatio.annualized(Return.portfolio(retornos_diarios, weights = pesos_optimos), scale = 252)

# Imprimir resultados del portafolio óptimo
cat("\n--- Optimización (Máximo Ratio de Sharpe) ---\n")
print(pesos_optimos)
cat(sprintf("Retorno Anualizado Óptimo: %.2f%%\n", retorno_optimo * 100))
cat(sprintf("Volatilidad Anualizada Óptima: %.2f%%\n", riesgo_optimo * 100))
cat(sprintf("Ratio de Sharpe Óptimo: %.2f\n", sharpe_optimo))


##################################################
##################################################
install.packages("ROI")
install.packages("ROI.plugin.glpk")
install.packages("ROI.plugin.quadprog")
library(ROI)
library(ROI.plugin.glpk)
library(ROI.plugin.quadprog)
#C. Generación de Gráficos (Frontera Eficiente)
# 1. Calcular la Frontera Eficiente (para visualizar la optimización)
# Establecer un rango de retornos objetivo para el cálculo
ef <- create.EfficientFrontier(R = retornos_diarios, 
                               portfolio = port_spec_sharpe, 
                               type = "mean-StdDev")

chart.EfficientFrontier(ef, match.col = "StdDev", main = "Frontera Eficiente")

chart.EfficientFrontier(ef, main = "Frontera Eficiente")
# 2. Gráfico de la Frontera Eficiente
chart.EfficientFrontier(ef, 
                        match.col = "StdDev", 
                        main = "Frontera Eficiente", 
                        xlim = c(min(StdDev.annualized(retornos_diarios)) * 0.8, 
                                  max(StdDev.annualized(retornos_diarios)) * 1.2))

# 3. Agregar puntos al gráfico
# Portafolio de Mínima Varianza (el punto más a la izquierda de la curva)
# Portafolio de Máximo Sharpe (el punto tangente)
points(riesgo_optimo, retorno_optimo, col = "red", pch = 19, cex = 1.5)
text(riesgo_optimo, retorno_optimo, labels = "Máximo Sharpe", pos = 4, col = "red")

# Tu Portafolio Actual
points(riesgo_anualizado, retorno_anualizado, col = "blue", pch = 19, cex = 1.5)
text(riesgo_anualizado, retorno_anualizado, labels = "Actual", pos = 4, col = "blue")


add.objective(port_spec, type = "return", name = "mean")

port_spec <- portfolio.spec(assets = tickers)
port_spec <- add.constraint(port_spec, type = "full_investment")
port_spec <- add.constraint(port_spec, type = "long_only")
port_spec <- add.objective(port_spec, type = "return", name = "mean")

opt_max_return <- optimize.portfolio(R = retornos_diarios,
                                     portfolio = port_spec,
                                     optimize_method = "random",
                                     trace = TRUE)

# Imprimir resultados del portafolio óptimo
cat("\n--- Optimización (Máximo Retorno) ---\n")
pesos_max_return <- extractWeights(opt_max_return)
print(pesos_max_return)
cat(sprintf("Retorno Anualizado Óptimo: %.2f%%\n", retorno_optimo * 100))
cat(sprintf("Volatilidad Anualizada Óptima: %.2f%%\n", riesgo_optimo * 100))
cat(sprintf("Ratio de Sharpe Óptimo: %.2f\n", sharpe_optimo))
  