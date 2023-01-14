#------------------------------------------------------#
#-- Universidad del Valle: Escuela de Estadística    --#
#-- Curso: Porbabilidad y Estadística             --#
#-- Profesor: Ivan Mauricio Bermudez Vera            --#
#------------------------------------------------------#

#------------------------------------------------------#
#   0. Configuración inicial-Librerias requeridas      #
#------------------------------------------------------#

#install.packages("easypackages")        # Libreria especial para hacer carga automática de librerias
library("easypackages")

lib_req<-c("lubridate","dplyr","visdat","missMDA","mice","DMwR2","editrules", "corrplot")# Listado de librerias requeridas por el script
easypackages::packages(lib_req)         # Verificación, instalación y carga de librerias.




#----------------------------------------------------------------------#
#### 1. Inspección y actualización de niveles para factores     ####
#----------------------------------------------------------------------#

#Creando un conjunto de datos

observacion=c(1,2,3,4,5)
age=c(21,2,18,21,34)
agegroup=c("Adult","child","adult","elderly","child")
height=c(6.0, 3.0 , 5.7, 5.0, -7.0)
status = c("single","Married","MARRIED","widowed","married")
yearsmarried=c(-1,0,20,2,3)

Datos = data.frame(age,agegroup,height,status,yearsmarried)
rm(age,agegroup,height,status,yearsmarried)

str(Datos)
summary(Datos)                                  

### Observando las etiquetas en algunas de las variables tipo Factor
table(Datos$agegroup)
table(Datos$status)

# Declaración de niveles correctos para las variables tipo Factor
level_agegroup <- c(adult="adult", Adult="adult")
level_status <- c(married="married", Married="married", MARRIED="married")

## Modificación del formato y transformación de variables
Datos <- transform(Datos,
                   agegroup=factor(dplyr::recode(agegroup, !!!level_agegroup)),
                   status=factor(dplyr::recode(status, !!!level_status))
)

str(Datos)
summary(Datos)   



#----------------------------------------------------------------------#
#### 2. Validación de reglas de consistencia en los datos - editrules     ####
#----------------------------------------------------------------------#


# Carga del archivo de reglas de validación
Rules <- editrules::editfile("Rules_File.txt")

# Conexión entre las  reglas
windows()
plot(Rules)

# Verificación de las reglas sobres los datos
editrules::violatedEdits(Rules, Datos)
Valid_Data = editrules::violatedEdits(Rules, Datos)
summary(Valid_Data)

#Identificar que observaciones presentan violaciones a las reglas
#which(Valid_Data)
#matrix(data=1:55, 5, 11)

# Visualización del diagnóstico
windows()
plot(Valid_Data)




#----------------------------------------------------------------------#
#### 3. Crear/Recodificando variables     ####
#----------------------------------------------------------------------#

# 1. Clasificar la variable edad respecto a su media como "mayor" o "menor"

Datos <- dplyr::mutate(Datos,
                       age.1 = ifelse(age > mean(age), "mayor", "menor"))


# 2. Convierta la edad de años a meses
Datos <- dplyr::mutate(Datos,
                       age.meses = age*12)



#------------------------------------------------------------------------#
#### 3. Identificación y cuantificación de datos faltantes                ####
#------------------------------------------------------------------------#

# Ejemplo previo ilustrativo

Nombre <- c("Alejandro", "Katterine","Jaime","Herney","Kevin", "Gina")
Genero <- c("H", "M", "H","H","H","M")
Edad <- c(23,NA,40,NA,24, 28)
Equipo <- c("América", "Indiferente","América","Cali",NA,"Cali")

Datos <- data.frame(Genero,Edad,Equipo)
rownames(Datos)<-Nombre

rm(Nombre,Genero,Edad, Equipo)                  # Borrar los objetos innecesarios

View(Datos)
is.na(Datos)                                    # para cada elemento de Datos verifica si es NA
x11()
visdat::vis_miss(Datos)                          # Una función que visualiza los datos faltantes en la hoja de calculo


# Función que evalua e identifica los datos faltantes por variable e individuo.

miss<-function(Datos,plot=T){  
  n=nrow(Datos);p=ncol(Datos)
  names.obs<-rownames(Datos)
  
  
  nobs.comp=sum(complete.cases(Datos))         # Cuenta los registros completos
  Obs.comp=which(complete.cases(Datos))        # Identifica los registros completos
  nobs.miss = sum(!complete.cases(Datos))      # Identifica los registros con datos faltantes.
  Obs.miss=which(!complete.cases(Datos))       # Identifica los registros con datos faltantes.
  
  Datos.NA<-is.na(Datos)
  Var_Num<- sort(colSums(Datos.NA),decreasing=T)
  Var_per<-round(Var_Num/n,3)
  Obs_Num<-rowSums(Datos.NA)
  names(Obs_Num)<-names.obs
  Obs_Num<-sort(Obs_Num,decreasing=T)
  Obs_per<-round(Obs_Num/p,3)
  lista<-list(n.row = n, n.col = p,n.comp = nobs.comp,Obs.comp = Obs.comp,n.miss = nobs.miss,Obs.miss = Obs.miss, Var.n = Var_Num , Var.p = Var_per, Obs.n= Obs_Num, Obs.per= Obs_per)
  
  if(plot){
    windows(height=10,width=15)
    par(mfrow=c(1,2))
    coord<-barplot(Var_per,plot=F)
    barplot(Var_per,xaxt="n",horiz=T,yaxt="n",xlim=c(-0.2,1), ylim=c(0,max(coord)+1),main= "% datos faltantes por variable")
    axis(2,at=coord,labels=names(Var_per), cex.axis=0.5,pos=0,las=2)
    axis(1,seq(0,1,0.2),seq(0,1,0.2),pos=0)
    
    coord<-barplot(Obs_per,plot=F)
    barplot(Obs_per,xaxt="n",horiz=T,yaxt="n",xlim=c(-0.2,1), ylim=c(0,max(coord)+1),main= "% datos faltantes por registro")
    axis(2,at=coord,labels=names(Obs_per),cex.axis=0.5,pos=0,las=2)
    axis(1,seq(0,1,0.2),seq(0,1,0.2))
  }
  return(invisible(lista))
}

Summary.NA = miss(Datos)                  # Asignamos el resultado a un objeto lista para consultarlo
#------------------------------------------------------------------------------#


#-------------------------------------------------------------------------#
#### 3.1. Caso 2 (Airquality), Identificación y manejo de datos faltantes    ####
#-------------------------------------------------------------------------#

rm(Datos,Summary.NA)       # Antes de Seguir, vamos a eliminar todos los objetos del proyecto anterior

## Lectura de datos Airquality (mide algunas variables de calidad del aire)
Datos = data.frame(airquality)
str(Datos)

## Ajuste del formato de Variables y visualización rápida
Datos = transform(Datos,                                                                          
                  Month=factor(Month,levels=5:9,labels=month.abb[5:9]),                                    # Conversión a formato fecha
                  Day=factor(Day,levels=1:31,labels=1:31))
str(Datos)
summary(Datos)

## Visualizando y Cuantificando los datos faltantes

is.na(Datos)                                 
x11()
visdat::vis_miss(Datos) 
Summary.NA = miss(Datos,T)                     

attach(Datos) 

## Lo que sucede cuando trabajamos con datos faltantes
Visualizar.AQ= function(Datos){   #Una función para visualizar los datos AQ
  with(Datos,{
    ## Tendencia Temporal
    windows(height=10,width=15)
    par(mfrow=c(2,2))
    plot(Ozone,type="l",col="Red")
    plot(Solar.R,type="l",col="Blue")
    plot(Wind,type="l",col="Gray")
    plot(Temp,type="l",col="Green")
    
    ## Variación mensual
    windows(height=10,width=15)
    par(mfrow=c(2,2))
    plot(Ozone~Month,type="l",col="Red")
    plot(Solar.R~Month,type="l",col="Blue")
    plot(Wind~Month,type="l",col="Gray")
    plot(Temp~Month,type="l",col="Green")
  })
  
  ## Correlación entre covariables cuantitativas
  Datos.cuant=Datos[,1:4]
  AQ.cor = cor(Datos.cuant,method="pearson")
  print(AQ.cor)
  windows(height=10,width=15)
  corrplot::corrplot(AQ.cor, method = "ellipse",addCoef.col = "black",type="upper")
  windows(height=10,width=15)
  pairs(Datos.cuant,lower.panel = panel.smooth, pch = 15)
}

## Visualización.
Visualizar.AQ(Datos)


## Una primera solución, identificar y completar.(Opción poco Probable)

## Una segunda aproximación, omitir los registros con datos faltantes.

Datos_clean=na.omit(Datos)                    # se omiten todos los registros con datos faltantes
windows(height=10,width=15); visdat::vis_miss(Datos_clean) 
Visualizar.AQ(Datos_clean)

## Tercera aproximación, Imputar

# Imputación por la media.
mean(Datos$Ozone)
mean(Datos$Ozone,na.rm=T)
mean(Datos$Solar.R,na.rm=T)

imputM = mice::mice(Datos, maxit = 1, method = "mean",seed = 2018,print=F)
Datos_ImputM = mice::complete(imputM)
windows(height=10,width=15); visdat::vis_miss(Datos_ImputM) 
Visualizar.AQ(Datos_ImputM)


## Imputación por regresion.
imputR = mice::mice(Datos, maxit = 1, method = "norm.predict",seed = 2018,print=F)
Datos_ImputR = mice::complete(imputR)
windows(height=10,width=15); visdat::vis_miss(Datos_ImputR) 
Visualizar.AQ(Datos_ImputR)

x11()
boxplot(Datos_ImputR$Ozone); abline(h=0,col="red")


## La imputación puede cambiar los resultados de los modelos - Una comparación

# Un modelo de regresión

model_miss=lm(Ozone~.,Datos[,-6])             # Con los Datos Faltantes
summary(model_miss)

model_clean=lm(Ozone~.,Datos_clean[,-6])      # Eliminando registros con Datos Faltantes
summary(model_clean)

model_ImputM=lm(Ozone~.,Datos_ImputM[,-6])    # Con Imputación por la media
summary(model_ImputM)

model_ImputR=lm(Ozone~.,Datos_ImputR[,-6])    # Con Imputación por Regresión
summary(model_ImputR)

