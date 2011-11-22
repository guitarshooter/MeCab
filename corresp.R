library(MASS)
y<-read.csv("arrt_words_tf_select.txt",header=TRUE,row.names=1)
x <- y[rowSums(y) != 0, ]
x.ca<-corresp(x,nf=3)
write.table(x.ca$cscore,"./corr_data_col.csv",sep=",",quote=F,col.names=F)
write.table(x.ca$rscore,"./corr_data_row.csv",sep=",",quote=F,col.names=F)

