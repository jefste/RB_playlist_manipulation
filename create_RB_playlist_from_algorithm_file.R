library(tidyverse)
library(readxl)

# reading in of RB playlist file----
#use read_lines to preserve whitespace
df<-read_lines("WDRK - Thursday.genprs")


#convert to a tibble and rename column to 'X1'
df<-tibble(df)%>%select(X1=df)

# QA checks -----
#display how many unique CatIDs there are
filter(df,grepl("CatID",X1))%>%unique()

#display how many named categories there are
filter(df,grepl("Name",X1))

#grab categoryID for the above named categories 
# just offset by 1 row since the CatID is found right below the name
df[grep("Name",df$X1)-1,]


#check that same CatIDs are used in the name as are used in the bottom
setdiff(filter(df,grepl("CatID",X1))%>%unique(),
        mutate(df[grep("Name",df$X1)-1,],X1=gsub("Category","Cat",X1))
)


#check that same CatIDs are used in the name as are used in the bottom
# same as the previous, but with x and y switched
# NOTE shows an extra CatID!
setdiff(
  mutate(df[grep("Name",df$X1)-1,],X1=gsub("Category","Cat",X1)),
  filter(df,grepl("CatID",X1))%>%unique()
)


#shows that the same number of catIDs appear in the top of the file as are in the bottom
union(filter(df,grepl("CatID",X1))%>%unique(),
      mutate(df[grep("Name",df$X1)-1,],X1=gsub("Category","Cat",X1))
)

# create table for lookup of catID ----------
# Creates table with catID for each Name
df.catID.with.name<-transmute(df[grep("Name",df$X1)-1,],catid=gsub("Category","Cat",X1))%>%
  cbind(name.id=filter(df,grepl("Name",X1)))%>%
  select(catid,name.id=X1)%>%
  select(X1=catid,name.id)


#add a column that trims out all unnecessary text
# name.simple will be used as a key for algorithm data
df.catID.with.name<-mutate(df.catID.with.name,
                           name.simple=gsub("Name = '","",name.id), #gets rid of "Name = '"
                           name.simple=gsub("'","",name.simple),  # gets rid of single quote 
                           name.simple=trimws(name.simple)  #trims white space
)


# read in desired algorithm --------------
# this will need to be changed for different algorithms
df.algo<-read_xlsx("4-27-17 Algorithm.xlsx")





# QA check -----------
#check to make sure category 
# in this example, their are 2 'typos'
# 'Eaux claires Main' and 'National main' appear in algorithm but do not have CatID's in the genprs file
# (don't need to worry about NA vaule or X40, will deal with those later)
setdiff(df.algo$Monday%>%unique(),df.catID.with.name$name.simple)

# Fix spelling issues in algorithm file -----------
# Need to rename 'Eaux claires Main' to 'Eaux Claires Main' and 'National main' to 'National Main' in algorithm 
#note that this might change depending on other differences in typos
df.algo<-mutate(df.algo,Monday=gsub("Eaux claires Main","Eaux Claires Main",Monday),
                Monday=gsub("National main","National Main",Monday))


# QA check -------------
#shows that "Local New" is not in the algorithm playlist--I don't think this is really and issue
setdiff(
  df.catID.with.name%>%
    select(name.simple)%>%
    unlist%>%
    unname()%>%
    trimws(),
  df.algo%>%
    select(Monday)%>%
    unique()%>%
    filter(!is.na(Monday),Monday!="X40")%>%
    unlist%>%
    unname()
)


# create table for inserting correct catID in the proper place ----------
#Create data frame that will allow one to make the substitution for the new category
# Note that this is one entry short from the algorithm sheet as there are only x39 on National Main instead of x40
# this is due to the fact that there are only 39 entries in the original genprs file

df.new.id<-cbind(rowid_to_column(df,"rowid")%>% #create row to keep track of indices
                   filter(grepl("CatID",X1)),  #keep only values that have 'CatID' in them
                 df.algo%>%
                   select(new.cat=Monday)%>%
                   filter(!is.na(new.cat),new.cat!="X40")%>%
                   rbind(tibble(new.cat=rep("National Main",39)))
)



#gives the index of where the new CatID will go
df.subbed.values<-merge(df.new.id,select(df.catID.with.name,X2=X1,new.cat=name.simple))%>%
  select(rowid,X1=X2)


# replace from the old genprs file to the algorithm defined in the genprs file -------------
#rowid is the index, X1 is the column that has the CatID that is to be replaced
df[df.subbed.values$rowid,"X1"]<-df.subbed.values$X1

# write out new file ---------------
#creates new file with substituted catIDs based on xlsx file with algorithm
write.table(df,"Monday- with leading whitespace.genprs",col.names = F,row.names = F,quote=F)
