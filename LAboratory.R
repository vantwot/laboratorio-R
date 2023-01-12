#Instalar paquete en caso de su ausencia
install.packages(c("readxl", "stringr"))

lapply(c("readxl", "stringr", "dplyr", "visdat"), require, character.only = TRUE)

#Ya tengo el data.frame de la tabla de los paises
xlm_object <- read_xls("paises.xls")

#Como primera observación los fileds de "GRUPOS" se encuentran en mayusculas y minusculas
# --- Corregir --- #
table(xlm_object$GRUPOS)

#**********  Corrección de las variables del campo GRUPOS  **********#
#Esto es para todos, Mejorar la forma

asia = c(ASIA = "ASIA", Asia = "ASIA", asia = "ASIA")
africa = c(AFRICA = "AFRICA", Africa = "AFRICA", africa = "AFRICA")
eu_oriental = c("Europa Oriental" = "EUROPA ORIENTAL")
iberoamerica = c("Iberoamerica" = "IBEROAMERICA", "iberoamerica" = "IBEROAMERICA")

key_field_groups = c(asia, africa, eu_oriental, iberoamerica)


#str_extract(new_ej, regex('\\basia\\b', ignore_case = TRUE))
xlm_object_trans = transform(xlm_object, 
    GRUPOS = factor(dplyr::recode(GRUPOS, !!!key_field_groups)))

rm(asia, africa, eu_oriental, iberoamerica, key_field_groups)
str(xlm_object_trans)


#**********  Cambio de nombre en la columna PNB  **********#
colnames(xlm_object_trans)[which(names(xlm_object_trans) == "PNB")] = "PIB"

#--------------------------------------------------------------------------#
# --------------    Pruebas Santiago  -------------- #
is.na(xlm_object_trans)  #Lista que me muestra los valores faltantes
x11()
visdat::vis_dat(xlm_object_trans)

names(xlm_object_trans) = xlm_object_trans$País

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
