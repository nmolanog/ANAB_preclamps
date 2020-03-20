#######################
###load data
#######################
rm(list=ls())
options(max.print=999999)
library(pacman)
p_load(here)
p_load(openxlsx)
p_load(tidyverse)
library(bueri)
oldir<-getwd()

####see available xlsx files to load
list.files("../data/raw")%>%str_subset(".xlsx")
###asign the apropiate name file. without xlsx extencion
file_nm<-"preclamsiasevera_19032020"
###load file
wb <- paste0("../data/raw/",file_nm,".xlsx")
getSheetNames(wb)
####load data
z0<-read.xlsx(wb, sheet =1, colNames = TRUE,na.strings = "NA")
####load dictionary
choix<-read.xlsx(wb, sheet =3, colNames = TRUE,na.strings = "NA")
####load regroup
regroup<-read.xlsx(wb, sheet =4, colNames = TRUE,na.strings = "NA")
####load regroup
toaddoutcomes<-read.xlsx(wb, sheet =5, colNames = TRUE,na.strings = "NA")
###remove conection
remove("wb")

###review choix
colnames(choix)
####compare names in choix and in colnames of z0
tempcn<-data.frame(colnames(z0),choix$var,stringsAsFactors =F)
tempcn%>%filter(colnames.z0.!=choix.var)

###if minor diferences fix that
choix$var<-colnames(z0)
###search for duplicated names
choix$var%>%table()->a
a[a>1]  

###verify available types
choix$type%>%table

###create folder if it is not already created
if(!"../data/Rdata" %in% list.dirs(path="..")){
  dir.create("../data/Rdata")
}

###save files as RData
save(z0,choix,regroup,toaddoutcomes,file=paste0("../data/Rdata","/","raw_data.RData"))
setwd(oldir)
