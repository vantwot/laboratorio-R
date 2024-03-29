#------------------------------------------------------#
#-- Universidad del Valle: Escuela de Estadistica    --#
#-- Asignatura: Probabilidad y Estadistica           --#
#-- Integrantes : Santiago Ramirez - 1841391         --#
#--               Deiby Rodriguez - 1842917          --#
#--               Valentina Salamanca - 1842427      --#
#-- Laboratorio                                      --#
#------------------------------------------------------#

#1. PREPOCESAMIENTO Y LIMPIEZA DE DATOS 

#------------------------------------------------------#
#   0. Configuración inicial-Librerias requeridas      #
#------------------------------------------------------#

library("easypackages")
#Librerias necesarias para el script
lib_req<-c("lubridate","dplyr","visdat","missMDA","mice","DMwR2","editrules", "corrplot")

#Llamando librerias necesarias
lapply(c("readxl", "stringr", "dplyr", "visdat", "editrules", "ggplot2", "ggrepel", "data.table"), require, character.only = TRUE)

#Leer archivo xls
xlm_object <- read_xls("paises.xls")

#----------------------------------------------------------------------#
####                1. Inspección de datos                          ####
#----------------------------------------------------------------------#

#Como primera observación los fileds de "GRUPOS" se encuentran en 
#mayusculas y minusculas, se procede a hacer correciones

table(xlm_object$GRUPOS)

asia = c(ASIA = "ASIA", Asia = "ASIA", asia = "ASIA")
africa = c(AFRICA = "AFRICA", Africa = "AFRICA", africa = "AFRICA")
eu_oriental = c("Europa Oriental" = "EUROPA ORIENTAL")
iberoamerica = c("Iberoamerica" = "IBEROAMERICA", "iberoamerica" = "IBEROAMERICA")

key_field_groups = c(asia, africa, eu_oriental, iberoamerica)

xlm_object_trans = transform(xlm_object, 
                             GRUPOS = factor(dplyr::recode(GRUPOS, !!!key_field_groups)))

rm(asia, africa, eu_oriental, iberoamerica, key_field_groups)
str(xlm_object_trans)

#----------------------------------------------------------------------#
#### 2. Validación de reglas de consistencia en los datos           ####
#----------------------------------------------------------------------#

# Carga del archivo de reglas de validación
Rules <- editrules::editfile("consistencia.txt")

# Conexión entre las  reglas
windows()
plot(Rules)

# Verificación de las reglas sobres los datos
editrules::violatedEdits(Rules, xlm_object_trans)
Valid_Data = editrules::violatedEdits(Rules, xlm_object_trans)
summary(Valid_Data)

# Visualización del diagnóstico
windows()
plot(Valid_Data)

#Correción error 1
xlm_object_trans$validaciones1 <- Valid_Data[, 1]
xlm_object_trans$Esperanza.vida.mujer = ifelse(xlm_object_trans$validaciones1 == FALSE,
                                               xlm_object_trans$Esperanza.vida.mujer, 
                                               round(xlm_object_trans$Esperanza.vida.hombre * 1.12,1))

#Correción error 2
xlm_object_trans$validaciones3 <- Valid_Data[, 2]
xlm_object_trans$Esperanza.vida.mujer = ifelse(xlm_object_trans$validaciones3 == FALSE,
                                               xlm_object_trans$Esperanza.vida.mujer, 
                                               round(xlm_object_trans$Esperanza.vida.hombre * 1.12,1))



#----------------------------------------------------------------------#
#### 3. Mostrar datos faltantes                                     ####
#----------------------------------------------------------------------#

is.na(xlm_object_trans)  #Lista que me muestra los valores faltantes
x11()
visdat::vis_dat(xlm_object_trans)

graph_na_fields = function(d, plot=T) {
  rows = nrow(d)
  cols = ncol(d)
  nombres_row = rownames(d)
  
  #Numero de filas completas
  rows_completed = sum(complete.cases(d))
  #indices de los datos completos
  index_completed = which(complete.cases(d))
  
  #Numero de filas con NA
  rows_incompleted = sum(!complete.cases(d))
  #Indices de las filas imcompletas
  index_incompleted = which(!complete.cases(d))
  
  data_na = is.na(d)
  #suma el numero de Trues en las columnas, recordar que los True indican que en 
  # ese campo hay un dato NA
  number_na_col = sort(colSums(data_na), decreasing = T)
  
  #Porcentaje de valores NA por columna, lo redondea
  percent_na_col = round(number_na_col/rows, 2)
  
  #Suma el numero de Trues en las filas
  number_na_row = sort(rowSums(data_na), decreasing = T)
  
  #Porcentaje de na por fila
  percent_na_row = round(number_na_row/cols, 2)
  
  lst = list(num_rows = rows, 
             num_col = cols, 
             total_complete = rows_completed, 
             index_completed = index_completed,
             rows_incompleted = rows_incompleted,
             index_incompleted = index_incompleted,
             number_na_col = number_na_col,
             percent_na_col = percent_na_col,
             number_na_row = number_na_row,
             percent_na_row = percent_na_row)
  
  
  if(plot) {
    windows(width = 10, height = 10)
    par(mfrow=c(1,2))
    
    coord <- barplot(percent_na_col, plot = F)
    barplot(percent_na_col,xaxt="n",horiz=T,yaxt="n",xlim=c(-0.2,1), ylim=c(0,max(coord)+1),main= "% datos faltantes por variable")
    axis(2,at=coord,labels=names(percent_na_col), cex.axis=0.5,pos=0,las=2)
    axis(1,seq(0,1,0.2),seq(0,1,0.2),pos=0)
    
    coord<-barplot(percent_na_row, plot=F)
    barplot(percent_na_row,xaxt="n",horiz=T,yaxt="n",xlim=c(-0.2,1), ylim=c(0,max(coord)+1),main= "% datos faltantes por registro")
    axis(2,at=coord,labels=names(percent_na_row),cex.axis=0.5,pos=0,las=2)
    axis(1,seq(0,1,0.2),seq(0,1,0.2))
  }
  
  return(invisible(lst))
}

result_graph = graph_na_fields(xlm_object_trans)

#----------------------------------------------------------------------#
#### 5. Corregir datos faltantes                                    ####
#----------------------------------------------------------------------#

library(mice)

#Imputación por regresión
imputR = mice::mice(xlm_object_trans, maxit = 1, method = "norm.predict", seed = 2018, print = F)
xlm_object_trans_imputR = mice::complete(imputR)


# Guardar datos corregidos

saveRDS(xlm_object_trans_imputR, file = "imputacionDatos.rds")
imputadosf = readRDS(file = "imputacionDatos.rds")

#2. VISUALIZACIÓN DE DATOS
#----------------------------------------------------------------------#
#### 1. Distribución de países según grupo                          ####
#----------------------------------------------------------------------#

grupos <- imputadosf %>% group_by(GRUPOS) %>% count()
grupos$eti <- round(100 * grupos$n/sum(grupos$n), 2)

ggplot(grupos, aes(x = GRUPOS, y = eti, fill = GRUPOS)) +
  geom_bar(width = 1, stat = "identity", color="white", alpha=0.8) + 
  ylab("porcentaje") + geom_text(aes(label = paste(eti,"%"), vjust=-0.6))+
  theme(legend.position = "none") + ggtitle("Distribución por grupos")

#----------------------------------------------------------------------#
#### 2. Indicadores de tasas de mortalidad y natalidad              ####
#----------------------------------------------------------------------#
x <- imputadosf[,c("Tasa.natalidad","Tasa.mortalidad","Mortalidad.infantil","GRUPOS")]
long <- melt(setDT(x), id.vars = c("GRUPOS"), variable.name = "Indicadores")
long <- long %>% group_by(Indicadores, GRUPOS) %>% summarise(valor1 = mean(value))

ggplot(long, aes(fill=Indicadores, y=valor1, x=GRUPOS)) + 
  geom_bar(position="dodge", stat="identity") +
  ylab("porcentaje") + geom_text(
    aes(x = GRUPOS, y = valor1, label = " ", group = Indicadores),
    position = position_dodge(width = 1),
    vjust = -0.5, size = 4 ) + ggtitle("Indicadores de tasas de mortalidad y natalidad")
  
#----------------------------------------------------------------------#
#### 3. PNB POR GRUPOS                                              ####
#----------------------------------------------------------------------#
imputadosf$y <- imputadosf$PNB/imputadosf$Poblacion.miles
long1 <- imputadosf %>% group_by(GRUPOS) %>% summarise(valor2 = mean(y))
long1

ppc <- ggplot(imputadosf, aes(y=y, fill=GRUPOS, x=GRUPOS)) + 
  geom_boxplot() + ggtitle("PNB per cápita") + ylab("PNB per cápita")

ppc

#----------------------------------------------------------------------#
#### 4. CUARTILES POR PNB                                           ####
#----------------------------------------------------------------------#

#cuartiles

Q1 <- quantile(imputadosf$y, na.rm = TRUE, c(0.25), type = 6); Q1

Q2 <- quantile(imputadosf$y, na.rm = TRUE, c(0.50), type = 6); Q2

Q3 <- quantile(imputadosf$y, na.rm = TRUE, c(0.75), type = 6); Q3

imputadosf$TIPO <- "BAJO"
imputadosf$TIPO[imputadosf$y >= Q1 & imputadosf$y < Q2] <- "MEDIO_BAJO"
imputadosf$TIPO[imputadosf$y >= Q2 & imputadosf$y < Q3] <- "MEDIO_ALTO"
imputadosf$TIPO[imputadosf$y > Q3] <- "ALTO"

z <- imputadosf[,c("TIPO","GRUPOS", "y", "País")]
#Variable que almacena el contador de los niveles de pobreza según el grupo
a <- imputadosf %>% group_by(TIPO,GRUPOS) %>% count()

ggplot(a, aes(fill=TIPO, y=n, x=GRUPOS)) + 
  geom_bar(position="dodge", stat="identity") +
  ylab("porcentaje") + geom_text(
    aes(x = GRUPOS, y = n, label = paste(n), group = TIPO),
    position = position_dodge(width = 1),
    vjust = -0.5, size = 4 ) + ggtitle("Indicadores de tasas de mortalidad y natalidad")
