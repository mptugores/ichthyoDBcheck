#-------------------------------------------------------------------------------
# Project: TUNIBAL, Vicenç Mut
# Authors: M.P. Tugores
# 
# Script para comprobar definición de estrutura igual en todas las tablas de 
# ecolarv
#
# Input: 
# - databaseversion: "ecolarv_comunidades_actual.accdb"
# - dbpath: directorio de la BD
# - Q1: código de la campaña
#
# Fecha actualización: 31/10/2024
# Versión 1.2.8
#-------------------------------------------------------------------------------


#***************
# Requirements
#***************
library(RODBC)

rm(list=ls(all=TRUE))

#***************
# Inputs
#***************
# Declare ECOLARV path and database name
# dbpath=getwd()
dbpath=paste(getwd(), "/", sep="")
databaseversion="ecolarv_comunidades_actual.mdb"

# Declare the name of the survey (to be checked)#####
Q1 <- 'TU0623'

# Declare the path where the folder "sig" is located
# It must contain the shapefile 'CCAA_longlat.shp'
wd = dbpath
# Ideally, the same as the scriptsDBcheck and ecolarv database, i.e.
# wd <- "D:/BLUEFINdata/basedatos_larvas/bd_tunibal/_ScriptsDBcheck/scriptsDBcheck"


# Check if selected survey is among available surveys
databasefile <- paste(dbpath, databaseversion,sep="")
channel <- odbcConnectAccess2007 (databasefile)  # Conectar a la BD Access

t_tallas <- sqlQuery(channel,
  query=paste(
    "SELECT",
    " to_campania",
    " FROM t_operaciones",
    sep="")
)
odbcCloseAll()

av_surv <- unique(t_tallas$to_campania); av_surv
av_surv <- av_surv[!grepl("MEDIAS", av_surv)] # Remove MEDIAS surveys as we are not interested

################################################################################
# Only intended to be RUN
# DO NOT CHANGE THE CODE BELOW
################################################################################

if(!dir.exists("outputs")) dir.create(path=paste(getwd(), "/outputs/", sep=""))
fileout <- paste("outputs/001_checksON_", Q1, ".txt", sep="")
 
# en aquellas tablas de ecolarv en que no estaban 100% bien definidas
databasefile=paste(dbpath, databaseversion,sep="")

channel <- odbcConnectAccess2007 (databasefile)  # Conectar a la BD Access

t_operaciones <- sqlQuery(channel, 
  query=paste(
    "SELECT",
    " *",
    " FROM t_operaciones",
    " WHERE to_campania = '",
    Q1,
    "'",
    sep="")
)

t_pescas <- sqlQuery(channel, 
  query=paste(
    "SELECT",
    " *",
    " FROM t_pescas",
    " WHERE tp_campania = '",
    Q1,
    "'",
    sep="")
)
 
t_colectores <- sqlQuery(channel, 
  query=paste(
    "SELECT",
    " *",
    " FROM t_colectores",
    " WHERE tc_campania = '",
    Q1,
    "'", 
    sep="")
)

t_tallas <- sqlQuery(channel,
  query=paste(
    "SELECT",
    " *",
    " FROM t_tallas",
    " WHERE tll_campania = '",
    Q1,
    "'",
    sep="")
)

t_infogrupo <- sqlQuery(channel, 
  query=paste(
    "SELECT",
    " *",
    " FROM t_infogrupo",
    " WHERE tg_campania = '",
    Q1,
    "'",
    sep="")  
)

#
#t_proces_target <- sqlQuery(channel,
#  query=paste(
#    "SELECT",
#    " *",
#    " FROM t_proces_target",
#    sep="")
#)

odbcCloseAll()

#*******************************************************************************

################################################################################
# 05/11/2021
# Los scripts tiran de 'tc_profundidad_max' NO de 'tp_prof_max', 
################################################################################

if(exists("n")) rm(n)
n <- 1  # Check num. order

#***************************
# Check: to_horallegada
#***************************
if(exists("check0")) rm(check0)
check0 <- t_operaciones[(t_operaciones$to_bongo90_500==1 | t_operaciones$to_bongo90_Viuda==1) & is.na(t_operaciones$to_horallegada),]
            
sink(file=fileout)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep=""))
if (nrow(check0)==0) print("Nice! All B90 operations have 'to_horallegada' declared")
if (nrow(check0)>0) {
  print(paste("Ups! There are ", nrow(check0), "NA values in to_horallegada for B90 hauls"))
  print(check0)
}
sink()

#**********************************
# Check: to_longitudoperacion
#**********************************
n <- n+1
if(exists("check0")) rm(check0)

x <- t_operaciones$to_longitudoperacion
check0 <- (any(is.na(x)) | any(x==0)) 

sink(file=fileout, append=TRUE)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep=""))
if(check0==FALSE) print(paste("Perfect!! All operations have 'longitude' declared in table 'tc_operaciones'.", " Total Num. operations: ", length(x), sep=""))
if(check0==TRUE) {
  print("Warning!!") 
  if(length(x[is.na(x)| x==0])== length(x)){
    print("The variable 'to_longitudoperacion' EQUALS 0 or NA in ALL operations.")
    print("Larval index scripts WILL NOT PROCEED normally!!")
    print("Please, modify ecolarv database.")
  }
  if(length(x[is.na(x)| x==0])< length(x)){
    print("The variable 'to_longitudoperacion' EQUALS 0 or NA")
    print(paste("in --- ", length(x[is.na(x)| x==0])," --- out of the ---", length(x), "--- operations."))
    print("Please, if it is an error, modify ecolarv database.")
  }
}
sink()

#*********************************
# Check: to_latitudoperacion
#*********************************
n <- n+1
if(exists("check0")) rm(check0)
if(exists("x")) rm(x)

x <- t_operaciones$to_latitudoperacion
check0 <- (any(is.na(x)) | any(x==0)) 

sink(file=fileout, append=TRUE)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep=""))
if(check0==FALSE) print(paste("Perfect!! All operations have 'latitude' declared in table 'tc_operaciones'.", " Total Num. operations: ", length(x), sep=""))
if(check0==TRUE) {
  print("Warning!!") 
  if(length(x[is.na(x)| x==0])== length(x)){
    print("The variable 'to_latitudoperacion' EQUALS 0 or NA in ALL operations.")
    print("Larval index scripts WILL NOT PROCEED normally!!")
    print("Please, modify ecolarv database.")
  }
  if(length(x[is.na(x)| x==0])< length(x)){
    print("The variable 'to_latitudoperacion' EQUALS 0 or NA")
    print(paste("in --- ", length(x[is.na(x)| x==0])," --- out of the ---", length(x), "--- operations."))
    print("Please, if it is an error, modify ecolarv database.")
  }
}
sink()

#********************************
# Check: operations over land
#********************************
n <- n+1
if(exists("check0")) rm(check0)

#library(maptools)
library(rgdal)
library(sf)

# Reading shapefile 
# wd <- "D:/BLUEFINdata/basedatos_larvas/bd_tunibal/_ScriptsDBcheck/scriptsDBcheck"
setwd(wd)
dirfile <- paste(getwd(), "/sig/", sep="")
filename <- "CCAA_longlat.shp"
# pols <- readOGR(paste(dirfile, filename, sep=""))
pols <- st_read(paste(dirfile, filename, sep=""))

opera_geo <- t_operaciones
coordinates (opera_geo) <- c("to_longitudoperacion", "to_latitudoperacion")
proj4string(opera_geo) <- CRS("+proj=longlat +datum=WGS84")

# estaciones sobre tierra
overlandpts <- over(opera_geo, as(as(pols, "Spatial"), "SpatialPolygons"))  # Los que tienen NA no están sobre tierra
pts <- opera_geo[!is.na(overlandpts),]

x <- t_operaciones$to_longitudoperacion
y <- t_operaciones$to_latitudoperacion

png(paste("outputs/Map_sampling_stations_", Q1, ".png", sep=""), width=480*1.6*2, height=480*2)
#dev.new(width=16, height=10)
plot(st_geometry(pols), col="darkgrey", xlim=c(min(x)-0.25, max(x)+0.25), 
  ylim=c(min(y)-0.25, max(y)+0.25), main=Q1)
points(t_operaciones$to_longitudoperacion, t_operaciones$to_latitudoperacion)   
dev.off()

png(paste("outputs/Map_sampling_stations_", Q1, "_withLabels.png", sep=""), width=480*1.6*2, height=480*2)
#dev.new(width=16, height=10)
plot(st_geometry(pols), col="darkgrey", xlim=c(min(x)-0.25, max(x)+0.25), ylim=c(min(y)-0.25, max(y)+0.25))
points(t_operaciones$to_longitudoperacion, t_operaciones$to_latitudoperacion, col="blue", pch=19)
text(t_operaciones$to_longitudoperacion, t_operaciones$to_latitudoperacion,t_operaciones$to_codestacion, cex=1, adj=c(1,1))   
dev.off()

check0 <- nrow(pts)==0

sink(file=fileout, append=TRUE)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep=""))
if(check0==TRUE) print("Perfect!! Any station is overland.")
if(check0==FALSE) {
  print(paste("Error! There are overland stations: --- ", nrow(pts), " --- out of the --- ",  nrow(opera_geo), " --- of survey ", Q1, ". Please, modify ecolarv database."))
  print(pts)
}
sink()

#***************************
# Check: to_idoperacion_num
#***************************
n <- n+1
if(exists("check0")) rm(check0)
if(exists("x")) rm(x)
if(exists("y")) rm(y)

x <- t_operaciones$to_idoperacion_num
check0 <- (any(is.na(x)) | any(x==0))

sink(file=fileout, append=TRUE)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep=""))
if(check0==FALSE) print("Nice! All operations have 'to_idoperacion_num' declared.")
if(check0==TRUE) {
  print("Warning! Operations with 'to_idoperation_num' equal to 0 or NA.")
  print("Larval index scripts WON'T PROCEED normally!!")
}
sink()

#***************************
# Check: tc_id_operacion_num
#***************************
n <- n+1
if(exists("check0")) rm(check0)
if(exists("x")) rm(x)

x <- t_colectores$tc_id_operacion_num
check0 <- (any(is.na(x)) | any(x==0))

sink(file=fileout, append=TRUE)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep=""))
if(check0==FALSE) print("Nice! All collectors have 'tc_id_operacion_num' declared.")
if(check0==TRUE) {
  print("Warning! Collectors with 'tc_id_operacion_num' equal to 0 or NA.")
  print("Larval index scripts WILL NOT PROCEED normally!!")
}
sink()

#****************************************************
# Check: Equal/unequal ranges 
# in 'to_idoperacion_num' and 'tc_id_operacion_num'
#****************************************************
n <- n+1
if(exists("check0")) rm(check0)
if(exists("x")) rm(x)

check1 <- range(t_operaciones$to_idoperacion_num)
check2 <- range(t_colectores$tc_id_operacion_num)
check0 <- all(check2==check1)

sink(file=fileout, append=TRUE)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep=""))
if(!is.na(check0) & check0==TRUE) print ("Nice! The range of values in 'to_idoperacion_num' equals the range of 'tc_id_operacion_num'")
if(check0==FALSE | is.na(check0)) print(paste("Warning!!! UNEQUAL RANGES in 'to_idoperacion_num' and 'tc_id_operacion_num'. Please, check the database before proceeding with further analysis"))
sink()

rm(check1, check2)

#***************************
# Check: to_fecha_estacion_llegada
#***************************
n <- n+1
if(exists("check0")) rm(check0)
if(exists("n_nas")) rm(n_nas)
if(exists("nsamp")) rm(nsamp)
check0 <- all(is.na(t_operaciones$to_fecha_estacion_llegada))
n_nas <- length(t_operaciones$to_fecha_estacion_llegada[is.na(t_operaciones$to_fecha_estacion_llegada)])
nsamp <- length(t_operaciones$to_fecha_estacion_llegada)

sink(file=fileout, append=TRUE)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep=""))
if(check0==FALSE) {
  print ("Nice! The variable 'to_fecha_estacion_llegada' seems to have been fulfilled")
  print (paste("Only   ", n_nas, "   out of   ", nsamp, "   samples are NAs"))
}
if(check0==TRUE) print(paste("Warning! The variable 'to_fecha_estacion_llegada' has no information. Scripts won't proceed normally"))
sink()

#***************************
# Check: to_profundidad_operacion
#***************************
n <- n+1
if(exists("check0")) rm(check0)
if(exists("n_nas")) rm(n_nas)
if(exists("nsamp")) rm(nsamp)
check0 <- all(is.na(t_operaciones$to_profundidad_operacion))
n_nas <- length(t_operaciones$to_profundidad_operacion[is.na(t_operaciones$to_profundidad_operacion)])
nsamp <- length(t_operaciones$to_profundidad_operacion)

sink(file=fileout, append=TRUE)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep=""))
if(check0==FALSE) {
  print ("Nice! The variable 'to_profundidad_operacion' seems to have been fulfilled")
  print (paste("Only   ", n_nas, "   out of   ", nsamp, "   samples are NAs"))
}
if(check0==TRUE) print(paste("Warning! The variable 'to_profundidad_operacion' has no information. Scripts won't proceed normally"))
sink()

#***************************
# Check: tp_prof_max
#***************************
n <- n+1
if(exists("check0")) rm(check0)
if(exists("n_nas")) rm(n_nas)
if(exists("nsamp")) rm(nsamp)
check0 <- all(is.na(t_pescas$tp_prof_max))
n_nas <- length(t_pescas$tp_prof_max[is.na(t_pescas$tp_prof_max)])
nsamp <- length(t_pescas$tp_prof_max)

sink(file=fileout, append=TRUE)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep=""))
if(check0==FALSE) {
  print ("Nice! The variable 'tp_prof_max' seems to have been fulfilled")
  print (paste("Only   ", n_nas, "   out of   ", nsamp, "   samples are NAs"))
}
if(check0==TRUE) print(paste("Warning! The variable 'tp_prof_max' has no information. Scripts could not proceed normally. However, we are retrieving info from 'tc_profundidad_max'"))
sink()

#***************************
# Check: tc_profundidad_max
#***************************
n <- n+1
if(exists("check0")) rm(check0)
if(exists("n_nas")) rm(n_nas)
if(exists("nsamp")) rm(nsamp)
check0 <- all(is.na(t_colectores$tc_profundidad_max))
n_nas <- length(t_colectores$tc_profundidad_max[is.na(t_colectores$tc_profundidad_max)])
nsamp <- length(t_colectores$tc_profundidad_max)

sink(file=fileout, append=TRUE)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep=""))
if(check0==FALSE) {
  print ("Nice! The variable 'tc_profundidad_max' seems to have been fulfilled")
  print (paste("Only   ", n_nas, "   out of   ", nsamp, "   samples are NAs"))
}
if(check0==TRUE) print(paste("Warning! The variable 'tc_profundidad_max' has no information. Scripts could not proceed normally.'"))
sink()

#***************************
# Check: tp_tipo_pesca
#***************************
n <- n+1
if(exists("check0")) rm(check0)
check0 <- t_pescas[t_pescas$tp_estructura=="B90" & is.na(t_pescas$tp_tipo_pesca),]

sink(file=fileout, append=TRUE)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep=""))
if (nrow(check0)==0) print("Nice! All B90 hauls have a 'tp_tipo_pesca' declared")
if (nrow(check0)>0) {
  print(paste("Ups! There are ", nrow(check0), "NA values in tp_tipo_pesca for B90 hauls"))
  print(check0)
}
sink()

t_pescas[t_pescas$tp_estructura=="B90" & is.na(t_pescas$tp_tipo_pesca),]
# En la campaï¿½a nueva, no hay pescas con tipo de pesca igual a NA

#***************************
# Check: tc_m3
#***************************
n <- n+1
# Comprobar que todos los colectores estï¿½ndard de la B90 y malla 500 tienen volumen declarado
if(exists("check0")) rm(check0)
check0 <- t_colectores[t_colectores$tc_estructura=="B90" & t_colectores$tc_malla==500 & is.na(t_colectores$tc_m3),]

sink(file=fileout, append=TRUE)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep=""))
if (nrow(check0)==0) print("Nice! All B90 colectors and malla = 500 have a 'tc_m3' declared")
if (nrow(check0)>0) {
  print(paste("Ups! There are ", nrow(check0), "NA values in tc_m3 for B90 colectors with malla = 500"))
  print(check0)
}
sink()

tmp <- t_colectores
tmp[tmp$tc_estructura=="B90" & tmp$tc_malla==500 & is.na(tmp$tc_m3),]
nrow(tmp[tmp$tc_estructura=="B90" & tmp$tc_malla==500 & is.na(tmp$tc_m3),])

# Hay 20 B90 con volúmenes == NA, son pescas donde 'tc_larval_index' es igual también a NA
 
#***************************
# Check: to_idBAMAR
#***************************
n <- n+1
if(exists("check0")) rm(check0)
check0 <- all(is.na(t_operaciones$to_idIBAMAR))
n_nas <- length(t_operaciones$to_idIBAMAR[is.na(t_operaciones$to_idIBAMAR)])
nsamp <- length(t_operaciones$to_idIBAMAR)

sink(file=fileout, append=TRUE)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep=""))
if(check0==FALSE) {
  print ("Nice! The variable 'to_idIBAMAR' seems to have been fulfilled")
  print (paste("Only   ", n_nas, "   out of   ", nsamp, "   samples are NAs"))
}
if(check0==TRUE) print(paste("Warning! The variable 'to_idIBAMAR' has no information. Scripts won't proceed normally"))
sink()

#***************************
# Check: tc_larval_index_BFT ### nota diego: aqui poner cuantos son positivos
#***************************
#check if the survey has declared the colectors that should be integrated in the larval index
# it tells how many colectors have been decalred for larval index
n <- n + 1
if (exists("check0")) rm(check0)
# Verificar si hay algún NA
check0 <- any(is.na(t_colectores$tc_larval_index_BFT))
# Contar la cantidad de valores NA
n_nas <- sum(is.na(t_colectores$tc_larval_index_BFT))
# Contar la cantidad de valores iguales a 1
n_ones <- sum(t_colectores$tc_larval_index_BFT == 1, na.rm = TRUE)
# Obtener el número total de muestras
nsamp <- length(t_colectores$tc_larval_index_BFT)

sink(file = fileout, append = TRUE)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep = ""))
if (check0 == FALSE) {
  print("Nice! The variable 't_colectores$tc_larval_index_BFT' seems to have been correctly fulfilled")
}
if (check0 == TRUE) {
  print(paste("Warning! The variable 't_colectores$tc_larval_index_BFT' has some NA data"))
  print(paste("Some ", n_nas, " out of ", nsamp, " are NAs"))
}
# Imprimir la cantidad de valores iguales a 1
print(paste("The variable 't_colectores$tc_larval_index_BFT' has ", n_ones, " values equal to 1 out of ", nsamp))
sink()

#***************************
# Check: colectores declarados para 'Xiphiidae'
#***************************
n <- n + 1
if (exists("check0")) rm(check0)
# Verificar si hay algÃºn NA
check0 <- any(is.na(t_colectores$tc_xiphiidae))
# Contar la cantidad de valores NA
n_nas <- sum(is.na(t_colectores$tc_xiphiidae))
# Contar la cantidad de valores iguales a 1
n_ones <- sum(t_colectores$tc_xiphiidae == 1, na.rm = TRUE)
# Obtener el nÃºmero total de muestras
nsamp <- length(t_colectores$tc_xiphiidae)

sink(file = fileout, append = TRUE)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep = ""))
if (check0 == FALSE) {
  print("Nice! The variable 't_colectores$tc_xiphiidae' seems to have been correctly fulfilled")
}
if (check0 == TRUE) {
  print(paste("Warning! The variable 'tc_xiphiidae' has some NA data"))
  print(paste("Some ", n_nas, " out of ", nsamp, " are NAs"))
}
# Imprimir la cantidad de valores iguales a 1
print(paste("The variable 't_colectores$tc_xiphiidae' has ", n_ones, " values equal to 1 out of ", nsamp))
sink()

#*******************************************************************************