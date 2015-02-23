## Getting and Cleaning Data project #################################

install.packages("reshape2")
install.packages("Hmisc")
install.packages("plyr")
library(reshape2)
library(Hmisc)
library(plyr)

## import data.frame ##################################################
setwd("/Users/kunyang/Desktop/Coursera/Getting and cleaning data")
train <- read.table("./UCI HAR Dataset/train/X_train.txt")
train_y <- read.table("./UCI HAR Dataset/train/y_train.txt")
test <- read.table("./UCI HAR Dataset/test/X_test.txt")
test_y <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
features <- read.table("./UCI HAR Dataset/features.txt")

## write the column names for the feature variables ##################
colnames(train) <- features$V2
colnames(test) <- features$V2
head(train)
head(test)

## introduce rows with mean or standard diviation in features #########
indices <- c(1:6,41:46, 81:86,121:126,161:166,201:202,214:215,227:228,
             240:241,253:254,266:271,345:350, 424:429, 503:504, 516:517, 
             529:530, 542:543)
newfeatures <- features[indices,]
newfeatures <- as.vector(newfeatures$V2)
newtrain <- train[,newfeatures]
newtest <- test[,newfeatures]
head(newtrain)
head(newtest)

## add activity info into the dataset ################################
newtrain <- cbind(train_y, newtrain)
newtest <- cbind(test_y, newtest)

## rename dataset with descriptive names in dataset ##################
level <- c("WALKING","WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING")
newtrain$V1 <- factor(newtrain$V1, 1:6, level)
newtest$V1 <- factor(newtest$V1, 1:6, level)

## rename the column of the activity in dataset ######################
names(newtrain)[1]<-paste("activity")
names(newtest)[1]<-paste("activity")
newtrain[1,]
newtest[1,]

## add subject info ####################################################
newtrain <- cbind(subject_train, newtrain)
newtest <- cbind(subject_test, newtest)

names(newtrain)[1]<-paste("subject")
names(newtest)[1]<-paste("subject")

## combine data from train and test into dataset ########################
newtrain$dataset <- 1
newtest$dataset <- 0
dataset <- rbind(newtrain,newtest)
dataset$dataset <- factor(dataset$dataset, c(1,0), c("train","test"))

## melt the data #########################################################
Melt <- melt(dataset, id = c("subject", "activity"), measure.vars=newfeatures)

# create the second dataset to get the mean value for each activity and each subject
dataset2 <- dcast(Melt,subject+activity ~ variable, mean)
write.table(dataset2, file="galaxyinfo.txt")
