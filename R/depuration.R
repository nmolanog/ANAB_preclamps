#######################
###load data
#######################
rm(list=ls())
options(max.print=999999)
library(pacman)
p_load(here)
p_load(openxlsx)
p_load(tidyverse)
p_load(lubridate)
p_load(chron)
library(bueri)
ori_dir<-getwd()
path_RData<-"../data/Rdata"
output_path<-"../outputs"

if(!output_path %in% list.dirs(path="..")){
  dir.create(output_path)
}

list.files(path = path_RData)%>%str_subset(".RData")

load(paste0(path_RData,"/", "raw_data",".RData"))

######fix NA
for(i in colnames(z0)){
  z0[z0[,i] %in% c(9999,99999),i]<-NA
}

###fix c vars
z0[,"dosisasa"]<-z0[,"dosisasa"]%>%str_replace(" mg dia","")
z0[,"dosisantihta2"]<-z0[,"dosisantihta2"]%>%str_replace(" mg ","")

choix[choix$type %in% "c","var"]%>%{z0[,.]}%>%map(unique)
options(warn = 2)
for(i in choix[choix$type %in% "c","var"]){
  z0[,i]%>%str_replace(",","\\.")->z0[,i]
  z0[,i]<-as.numeric(z0[,i])
}
# i
# z0[,i]%>%unique
# for(j in seq_along(z0[,i])){
#   as.numeric(z0[,i][j])
# }
# z0[,i][j]
options(warn = 1)

####fix f vars
z0[,choix[choix$type %in% "f","var"]]%>%map(unique)
for(i in choix[choix$type %in% "f","var"]){
  z0[,i]<-factor(z0[,i])
}

summary(z0)
#####regroup vars and cuts
regroup0<-regroup
regroup<-regroup[!regroup$categorias %in% "num",]

z1<-regroup_vars(z0, regroup)

regroup0[regroup0$categorias %in% "num",]
cut_df<-data.frame(name=regroup0[regroup0$categorias %in% "num","new_name"],
           source=regroup0[regroup0$categorias %in% "num","var"],
           formula2=7,
           close="r",stringsAsFactors = F)

z0[,cut_df$source]%>%summary

z1<-cutvars(cut_df,z1)

summary(z1)
