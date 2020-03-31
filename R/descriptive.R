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
ori_dir<-getwd()
path_RData<-"../data/Rdata"
output_path<-"../outputs"

if(!output_path %in% list.dirs(path="..")){
  dir.create(output_path)
}

list.files(path = path_RData)%>%str_subset(".RData")
load(paste0(path_RData,"/", "dep_data",".RData"))

z0%>%{map_dbl(.,~num.clas(.x))}->numclsz0
numclsz0%>%.[. %in% c("1","0") | is.na(.)]%>%names->constant_vars

choix$type%>%unique
c.vars<-setdiff(choix[choix$type %in% "c","var"],constant_vars)
d.vars<-setdiff(choix[choix$type %in% "f","var"],constant_vars)

vdep<-setdiff(choix[choix$outcome %in% 1,"var"],constant_vars)

summary(z0[,c.vars])
summary(z0[,d.vars])
summary(z0[,vdep])

setwd(output_path)
autores(z0,d.vars,c.vars,vdep,xlsxname ="descr_v1",fldr_name="descr_v1")
setwd(ori_dir)