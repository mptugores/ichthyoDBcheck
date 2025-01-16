#-------------------------------------------------------------------------------
# Project: TUNIBAL, Vicenç Mut
# Authors: M.P. Tugores
# 
# The script checks, for a particular species and survey, 
# if the length data is within the range data of the whole ECOLARV database
#
# Input: 
# - databaseversion: "ecolarv_comunidades_actual.accdb"
# - dbpath: directorio de la BD
# - Q1: código de la campaña
#
# Fecha actualización: 2023/11/22
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
# Declare the name of the survey (to be checked)#####
Q1 <- 'TU0623'


# One of the values in the variable to_campania variable of the table t_operaciones in ECOLARV
sp_code <- '340' 
# 340 (Thunnus thynnus), 342 (Thunnus alalunga), 336 (Auxis rochei), 337 (Euthynus alletteratus)
# 344 (Xiphias gladius) # so far, no length-data for this species exist

# Check available surveys
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
# Only RUN
# DO NOT CHANGE THE CODE BELOW
################################################################################
if(!dir.exists("outputs")) dir.create(path=paste(getwd(), "/outputs/", sep=""))

fileout <- paste("outputs/002_checksON_", sp_code, "_LengthData_", Q1, ".txt", sep="")
 
# en aquellas tablas de ecolarv en que no estaban 100% bien definidas
databasefile=paste(dbpath, databaseversion,sep="")

channel <- odbcConnectAccess2007 (databasefile)  # Conectar a la BD Access

t_tallas <- sqlQuery(channel,
  query=paste(
    "SELECT",
    " *",
    " FROM t_tallas",
    " WHERE tll_campania = '",
    Q1,
    "'",
    " AND tll_sppid = ",
    sp_code,
    sep="")
)

t_tallas_hist <- sqlQuery(channel,
  query=paste(
    "SELECT",
    " *",
    " FROM t_tallas",
    " WHERE tll_sppid = ",
    sp_code,
    "",
    sep="")
)

t_tallas_hist_2 <- sqlQuery(channel,
  query=paste(
    "SELECT",
    " *",
    " FROM t_tallas",
    " WHERE tll_sppid = ",
    sp_code,
    "",
    " AND tll_campania <> '",
    Q1,
    "'",
    sep="")
)
odbcCloseAll()

#*******************************************************************************

if(exists("n")) rm(n)
n <- 1  # Check num. order

#***************************
# Check: length distribution 
#***************************
if(exists("check0")) rm(check0)
check0 <- min(t_tallas_hist_2$tll_talla) <= min (t_tallas$tll_talla)
check1 <- max(t_tallas_hist_2$tll_talla) >= max (t_tallas$tll_talla)
check2 <- min(t_tallas$tll_talla)< 0
check3 <- max(t_tallas$tll_talla)> max(t_tallas_hist_2$tll_talla)+100*sd(t_tallas_hist_2$tll_talla)

if(sp_code=="340" | sp_code=="342") check4 <- max (t_tallas$tll_talla) > 8.5 
            
sink(file=fileout)
print("#------------------------------------------------------------")
print(paste("#", n, " CHECK", sep=""))

print("#------------------------------------------------------------")
print(paste("Length-range of the survey being processed --- ", Q1, " ---:"))
print(range(t_tallas$tll_talla))

print(paste("Historical Length-range without survey being processed :"))
print(range(t_tallas_hist_2$tll_talla))

if (all(check0, check1)) print(paste("Nice!  For species ",  sp_code, ": data in 'tll_talla' of survey  ", Q1, "  is within the range of the whole database."))

if (!check0) { # equals to check0 == FALSE
  if (check2) {
  print(paste("Stop!!  Error in 'tll_talla' in survey -- ", Q1, " -- . Minimum length is smaller than 0!!!")) 
  }
  if (!check2) {  
  print(paste("Warning!  Minimum length in survey  ", Q1, 
  " (", min(t_tallas$tll_talla), " mm)", 
  " is smaller than historical min (",  
  min(t_tallas_hist_2$tll_talla), " mm).", sep="")) 
  }
} 
if (!check1) {
  if (!check3) {
  print(paste("Warning!  Maximum length in survey  ", Q1, 
  " (", max(t_tallas$tll_talla), " mm)", 
  " is bigger than historical max (",  
  max(t_tallas_hist_2$tll_talla), " mm).", sep=""))
  }
  if (check3) {
  print(paste("Stop!!  Error in 'tll_talla' in survey -- ", Q1, " -- . Please, check the database before proceeding!")) 
  }
}

if(sp_code=="340" | sp_code=="342") {
  if (check4) {
    print(paste("Be careful! There are larvae > 8.5 mm in survey -- ", Q1, "--", sep=""))
    print(nrow(t_tallas[t_tallas$tll_talla>8.5,])) # number of larvae greater than 8.5 mm
    print(t_tallas[t_tallas$tll_talla>8.5,]) # print larvae greater than 8.5 mm
  }
  if (!check4) print(paste("Any larvae was bigger than 8.5 mm -- ", Q1, "-- . Is it ok?", sep=""))
}

sink()


#*******************************************************************************