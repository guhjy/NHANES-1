library(foreign)

xpt_files<-list.files(pattern='*.XPT')
data_type<-readline("Data type? (lab/enviro) ")
if(!(data_type=="lab"|data_type=="enviro")){
    cat("Data type must be one of 'lab' or 'enviro'!\n")
    quit("no")
}

# arbitrary...
master<-data.frame(rep(NA,4))
names(master)<-"SEQN"
cat("Merging!\n")
for (xpt in xpt_files){
    xpt_file<-read.xport(xpt)
    master<-merge(xpt_file,master,by="SEQN",all=TRUE)
}

# remove duplicate columns
cat("Removing duplicates!\n")
# get rid of all the y, don't need em
y_dupes<-names(master)[grep(".y[.1-9]*",names(master))]
# get list of x dupes
x_dupes<-names(master)[grep(".x[.1-9]*",names(master))]
# extract unique measurements
names<-NULL
for (dupename in x_dupes){
    nm<-strsplit(dupename,".x[.1-9]*")[[1]]
    names<-c(names,nm)
}
# select the measurement with the most data from the unique ones
uniqs<-unique(names)
to_lose<-y_dupes
for (name in uniqs){
    options<-names(master)[grep(name,names(master))]
    nas<-colMeans(is.na(master[,options]))
    best<-which(nas==min(nas))[1]
    to_lose<-c(to_lose,names(nas)[-best])
}
# exterminate!
to_keep<-setdiff(names(master),to_lose)
master<-subset(master,select=to_keep)

# some of the rows have NA seq number somehow
master<-master[!is.na(master$"SEQN"),]

# fix labelling
colnames(master)<-gsub(".x[.1-9]*","",colnames(master))

# save
filename<-paste(data_type,"_data.txt",sep="")
cat("Saving to",filename,"\n")
write.table(master,file=filename,row.names=master$"SEQN",col.names=T,quote=FALSE)
#write.table(master,file=filename,col.names=T,quote=FALSE)
