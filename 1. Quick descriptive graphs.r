# Instalar y cargar ggplot2 y tidyverse (si no están instalados)
install.packages(c("ggplot2", "tidyverse", "reshape2"))
library(ggplot2)
library(tidyverse)
library(reshape2) # Utilizado para transformar los datos a formato 'largo'

windows()
print(g)


# 1. Normalizar los precios
precios_normalizados <- t(apply(precios_ajustados, 1, function(x) x / as.numeric(precios_ajustados[1, ])))

# 2. Convertir la matriz de precios normalizados a un data frame y formato 'largo' para ggplot
df_precios <- as.data.frame(precios_normalizados)
df_precios$Fecha <- as.Date(rownames(df_precios))
df_precios_largo <- melt(df_precios, id.vars = "Fecha", variable.name = "Activo", value.name = "Valor_Normalizado")

# 3. Generar el gráfico
g1 <- ggplot(df_precios_largo, aes(x = Fecha, y = Valor_Normalizado, color = Activo)) +
  geom_line(linewidth = 1) +
  labs(title = "Evolución de Precios Normalizados (Base $1)",
       subtitle = paste("Desde", min(df_precios_largo$Fecha)),
       y = "Crecimiento de $1",
       x = "Fecha",
       color = "Activo") +
  theme_minimal() +
  scale_y_continuous(labels = scales::dollar) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

print(g1)

# 1. Convertir la matriz de retornos a un data frame y formato 'largo'
df_retornos <- as.data.frame(retornos_diarios)
df_retornos$Fecha <- as.Date(rownames(df_retornos))
df_retornos_largo <- melt(df_retornos, id.vars = "Fecha", variable.name = "Activo", value.name = "Retorno_Diario")

# 2. Generar el gráfico de densidad y histograma
g2 <- ggplot(df_retornos_largo, aes(x = Retorno_Diario, fill = Activo)) +
      geom_histogram(aes(y = after_stat(density)), bins = 50, alpha = 0.6, position = "identity") +
      geom_density(alpha = 0.8) +
      labs(title = "Distribución de Retornos Diarios",
           subtitle = "Comparación de la Volatilidad",
           x = "Retorno Diario",
           y = "Densidad / Frecuencia") +
      facet_wrap(~ Activo, scales = "free_y") + # Separa por activo para mejor visualización
      theme_minimal() +
      scale_x_continuous(labels = scales::percent) +
      theme(plot.title = element_text(face = "bold", hjust = 0.5))

print(g2)

# Usaremos el data frame largo de retornos del gráfico 2: df_retornos_largo

# Generar el gráfico de cajas y bigotes
g3 <- ggplot(df_retornos_largo, aes(x = Activo, y = Retorno_Diario, fill = Activo)) +
      geom_boxplot(alpha = 0.7) +
      labs(title = "Boxplot de Retornos Diarios por Activo",
           subtitle = "Mediana, Dispersión y Outliers",
           y = "Retorno Diario",
           x = "Activo") +
      geom_hline(yintercept = 0, linetype = "dashed", color = "red") + # Línea de Retorno Cero
      theme_minimal() +
      scale_y_continuous(labels = scales::percent) +
      theme(plot.title = element_text(face = "bold", hjust = 0.5),
            legend.position = "none")

print(g3)
