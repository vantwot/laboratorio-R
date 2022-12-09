# Laboratorio en R

## El preprocesamiento y limpieza de los datos.

En  una  inspección  rápida  de  la  hoja  de  datos,  usted  podrá  notar  la  presencia  de  algunos  registros inconsistentes y datos faltantes. Para evitar sesgos sobre los resultados y pérdida de registros, es necesario que usted, previo a realizar cualquier análisis, realice una actividad de limpieza de datos utilizando las dos herramientas de software estudiadas en clase.

Para realizar el ejercicio en R, usted debe seguir el siguiente libreto de limpieza ypreprocesamiento:
  1. Lea la hoja de datos y adecúe el formato de cada variable, verificando que dispone de una hoja de datos técnicamente correcta.
  2. Construya el archivo: consistencia.txt, en el cual incluya las ecuaciones que usted considera necesarias para verificar la consistencia de los datos     en el conjunto de variables.
  3. Aplique estas reglas sobre la hoja de datos y genere un pequeño reporte de sus resultados.
  4. Visualice e identifique los registros que presentan datos     faltantes.
  5. Con los resultados de los puntos anteriores, usted dispone del listado con registros inconsistentes y con datos faltantes. Es necesario corregirlo.
  
## Visualización de datos.

El  objetivo  en  este  análisis  de  datos  consiste  en  identificar  particularidades  que  logren  contribuir  en  la explicación del comportamiento del anterior conjunto de indicadores. 

Utilice su pericia para resumir los datos en uno o pocos tableros gráficos:

  1. Como está conformada la muestra(distribución)de países según grupo.
  2. En un solo esquema gráfico, analice la existencia de diferencia en los indicadores (Tasas de Mortalidad, Tasa de Natalidad, Mortalidad Infantil)         evaluados para los países que conforman los diferentes grupos. 
  3. Genere una nueva variable denominada PNB per cápita, que equivale al cociente entre PNB/# habitantes. Grafique esta variable (en un solo esquema         gráfico) para cada uno de los grupos e interprete los resultados. 
  4. Sobre la nueva variable calculada, calcule los respectivos Cuartiles, Generando 4 grupos que cumplan con las siguientes condiciones: 
   
   * Bajo= conformado por el 25% más pobre 
   * Medio Bajo= Conformado por los países que superan el percentil 25% pero son inferiores al 50% 
   * Medio Alto= Conformado por los países que superan el percentil 50% pero son inferiores al 75% 
   * Alto= Conformado por el 25% Más rico. 

Para cada grupo de países (Variable Grupos existente en la base de datos), calcule el porcentaje de países que son clasificados en los diferentes niveles de pobreza (Alto, Medio Alto, Medio Bajo, Bajo), represente en  un  tabla  de  frecuencia  y  genere  un gráficoque  resuma  tal  tabla. ¿Cree  que  el  nivel  de  riqueza  está asociado con el grupo de clasificación?
