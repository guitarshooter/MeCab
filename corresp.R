library(MASS)
x<-read.csv("arrt_words_tf.txt",header=TRUE,row.names=1)
x.ca<-corresp(x,nf=3)
write.table(x.ca$cscore,"./corr_data_col.txt",quote=F,col.names=F)
write.table(x.ca$rscore,"./corr_data_row.txt",quote=F,col.names=F)

