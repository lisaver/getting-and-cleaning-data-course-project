## library activation
library(data.table)

## Open files in R using read.table and fread: X_test, X_train, Y_test, Y_train, subject_test, subject_train
X_train <- read.table("~/cursussen/R/getting and cleaning data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/train/X_train.txt", 
                      quote="\"", comment.char="")
X_test <- read.table("~/cursussen/R/getting and cleaning data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/test/X_test.txt", 
                     quote="\"", comment.char="")
Y_test <- fread("~/cursussen/R/getting and cleaning data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/test/Y_test.txt")
Y_train <- fread("~/cursussen/R/getting and cleaning data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/train/Y_train.txt")
subject_test <- fread("~/cursussen/R/getting and cleaning data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/test/subject_test.txt")
subject_train <- fread("~/cursussen/R/getting and cleaning data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/train/subject_train.txt")

## merge X_test and X_train on rows to X_testtrain
X_testtrain <- rbind(X_test, X_train)

## add variable labels of the features to X_testtrain
features <- read.table("~/cursussen/R/getting and cleaning data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/features.txt", 
                       quote="\"", comment.char="")
names(features) <- c("number", "measurement")
names(X_testtrain) <- features$measurement

## merge subject and Y_test en train, with activity numbers of test and train & add labels
subject_file <- rbind(subject_test, subject_train)
names(subject_file) <- "subject"
Activities <- rbind(Y_test, Y_train)
names(Activities) <- "activity"

## merge subject, activities, data (X_testtrain) on colums to total
total <- cbind(subject_file, Activities, X_testtrain)

## load activity_labels and rename variable activity into informative names
activity_labels <- fread("~/cursussen/R/getting and cleaning data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/activity_labels.txt")

## copied number and names to of the activity_labels to the syntax for renaming
library(plyr)
total$activity <- as.factor(total$activity)
total$activity <- revalue(total$activity, c("1" =  "WALKING", "2" = "WALKING_UPSTAIRS", "3" = "WALKING_DOWNSTAIRS", 
                               "4"= "SITTING", "5" = "STANDING", "6" = "LAYING"))

## subsetting columns about including info about mean and std
total.1 <- select(total, subject,activity)
total.2 <- select(total, contains("mean"))
total.3 <- select(total, contains("std"))

## merging it back to the final 1st tidy dataset_1
tidy_dataset_1 <- cbind(total.1, total.2, total.3)

## control for NA  
any(is.na(tidy_dataset_1))

###########################

## second part step 5, create new file first rename to tidy_dataset_2: 
seconddataset <- tidy_dataset_1 

## remove the std columns
select_set <- select(seconddataset, -contains("std"))

## prepare for melt function vars list with grep functin from features table.
library(reshape2_1.4.1)
vars <- grep("mean", features$measurement, value=TRUE) 

#melt the dataset to prepare for means. 
narrowdataset <- melt(select_set, id=c("subject","activity"), measure.vars=vars)  
tidy_dataset_2 <- dcast(narrowdataset, subject + activity ~ variable, mean)

#checking the resulting tidy_dataset_2
head(tidy_dataset_2)
summary(tidy_dataset_2)

write.table(tidy_dataset_2, file = "~/cursussen/R/getting and cleaning data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/test/tidydataset.txt", row.name=FALSE)
