#-------------------------------------------------------------------------------
# Project: TUNIBAL, Vicenç Mut
# Authors: M.P. Tugores
# 
# Script para comprobar definición de estrutura igual en todas las tablas de 
# ecolarv
#
# Input: 
# Access database: "ecolarv_comunidades_actual.accdb"
# dbpath: directorio de la BD
#
# Fecha actualización: 2023/07/28
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
# Declare path ECOLARV database
# dbpath=getwd()
dbpath=paste(getwd(), "/", sep="")
databaseversion="ecolarv_comunidades_actual.mdb"

################################################################################
# Only RUN
# DO NOT CHANGE THE CODE BELOW
################################################################################ 
# en aquellas tablas de ecolarv en que no estaban 100% bien definidas
databasefile=paste(dbpath, databaseversion,sep="")


file.exists(databasefile)

channel <- odbcConnectAccess2007 (databasefile)  # Conectar a la BD Access

t_pescas <- sqlQuery(channel, 
  query=paste(
    "SELECT",
    " tp_estructura",
    " FROM t_pescas",
    sep="")
)
 
t_colectores <- sqlQuery(channel, 
  query=paste(
    "SELECT",
    " tc_estructura", 
    " FROM t_colectores", 
    sep="")
)

t_tallas <- sqlQuery(channel,
  query=paste(
    "SELECT",
    " tll_estructura",
    " FROM t_tallas",
    sep="")
)

t_infogrupo <- sqlQuery(channel, 
  query=paste(
    "SELECT",
    " tg_estructura",
    " FROM t_infogrupo",
    sep="")  
)

odbcCloseAll()

levels(as.factor(t_pescas[,1]))
levels(as.factor(t_colectores[,1]))
levels(as.factor(t_infogrupo[,1]))
levels(as.factor(t_tallas[,1]))

if(!dir.exists("outputs")) dir.create(path=paste(getwd(), "/outputs/", sep=""))

sink(file="outputs/000_general_checks.txt")
print("#------------------------------------------------------------")
print(paste("#", 1, " CHECK", sep=""))
print("# Check estructura on several tables")
print("#-----------------------------------------------------------------------")
print ("t_pescas") 
print(levels(as.factor(t_pescas[,1])))
print("#-----------------------------------------------------------------------")
print ("t_colectores") 
print(levels(as.factor(t_colectores[,1])))
print("#-----------------------------------------------------------------------")
print ("t_infogrupo") 
print(levels(as.factor(t_infogrupo[,1])))
print("#-----------------------------------------------------------------------")
print ("t_tallas") 
print(levels(as.factor(t_tallas[,1])))
sink()
#*******************************************************************************