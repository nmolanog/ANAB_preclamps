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

z1$proteinuria_1<-NA
z1$proteinuria_2<-NA
z1$proteinuria_3<-NA

z1[z1$met.prot %in% "1","proteinuria_1"]<-z1[z1$met.prot %in% "1","proteinuria"]
z1[z1$met.prot %in% "2","proteinuria_2"]<-z1[z1$met.prot %in% "2","proteinuria"]
z1[z1$met.prot %in% "3","proteinuria_3"]<-z1[z1$met.prot %in% "3","proteinuria"]

summary(z1)
setdiff(colnames(z1),choix$var)
new_choix<-data.frame(var=setdiff(colnames(z1),choix$var),type=c(rep("f",8),rep("c",3)),outcome=NA)
choix<-rbind(choix,new_choix)
choix[choix$var %in% toaddoutcomes$var,"outcome"]<-1

z0<-z1
####final check
colnames(z0)[!colnames(z0)%in% choix$var]

tempcn<-data.frame(colnames(z0),choix$var,stringsAsFactors =F)
tempcn%>%filter(colnames.z0.!=choix.var)

choix$var<-colnames(z0)
choix$var%>%table()->a
a[a>1]  
choix$type%>%table

summary(z0)
###exporting depurated data
save(z0,choix,file=paste0("../data/Rdata","/","dep_data.RData"))
