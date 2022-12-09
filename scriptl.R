#------------------------------------------------------#
#-- Universidad del Valle: Escuela de Estadistica    --#
#-- Asignatura: Probabilidad y Estadistica           --#
#-- Integrantes : Santiago Ramirez -                 --#
#--               Deiby Rodriguez -                  --#
#--               Valentina Salamanca - 1842427      --#
#-- Laboratorio                                      --#
#------------------------------------------------------#


#### Lectura de datos ####

datos <- read.table("paises.txt", header=TRUE,fill = TRUE)

names(datos) #nombres de las variables en la BD.
str(datos)  #Indica el tipo de variable
head(datos) #Muestra las primeras lineas de la BD.
