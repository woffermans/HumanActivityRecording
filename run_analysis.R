#**********************************************************************************************************************#
# Create the right workspace
#**********************************************************************************************************************#

# create a fresh list

	rm(list=ls())

# load libraries

	library(dplyr)
	library(tibble)
	library(tidyr)

#**********************************************************************************************************************#
# Download, unpack data, and import data
#**********************************************************************************************************************#

# Download data, if necessary

	fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
	if(!file.exists("./HumanActivityRecognition.zip")){
		download.file(fileUrl,"./HumanActivityRecognition.zip")
	}

# Unzip data, if necessary

	if(!dir.exists("./UCI HAR Dataset")){
		unzip("./HumanActivityRecognition.zip")
	}

# Import data

	TrainingSet<-read.table("./UCI HAR Dataset/train/X_train.txt",header = FALSE, dec=".")
	TrainingSetActivity<-read.table("./UCI HAR Dataset/train/y_train.txt",header = FALSE)
	TrainingSetSubject<-read.table("./UCI HAR Dataset/train/subject_train.txt",header = FALSE)
	TestSet<-read.table("./UCI HAR Dataset/test/X_test.txt",header = FALSE,dec=".")
	TestSetActivity<-read.table("./UCI HAR Dataset/test/y_test.txt",header = FALSE)
	TestSetSubject<-read.table("./UCI HAR Dataset/test/subject_test.txt",header = FALSE)
	FeatureLabel<-read.table("UCI HAR Dataset/features.txt")
	ActivityLabel<-read.table("./UCI HAR Dataset/activity_labels.txt")

#**********************************************************************************************************************#
# Tidy variable names
# It is a combined effort to fullfil the following conditions:
#
# Uses descriptive activity names to name the activities in the data set.
# Appropriately labels the data set with descriptive variable names. 
#**********************************************************************************************************************#

# Assign proper variable/column names to Subject tables

	names(TestSetSubject)<-c("SubjectID")
	names(TrainingSetSubject)<-c("SubjectID")

# Assign proper variable/column names to ActivityLabel table

	names(ActivityLabel)<-c("ActivityID","Activity")

# Assign proper variable/column names to Activity tables

	colnames(TrainingSetActivity) <- c("ActivityID")
	colnames(TestSetActivity) <- c("ActivityID")

# Create suitable and descriptive labels for the variables of Test- and Training set

	FeatureLabel$feature<-
				sub('Gyro','Gyroscope',
				sub('ArCoeff','AutoregressionCoefficients',
				sub('Iqr','InterquartileRange',
				sub('Mad','MedianAbsoluteDeviation',
				sub('Sma','SignalMagnitudeArea',
				sub('Mag','Magnitude',
				sub('Acc','Accelerometer',
				sub('(\\,)([a-z])','\\U\\2',
				sub('Std','StandardDeviation',
				sub('(,)([0-9X-Z])','_\\2',
				sub('(-)([0-9])','\\2',
				sub('^f','Frequency',
				sub('^t','Time',
				gsub('(-)([a-zA-Z])','\\U\\2',
				gsub('\\(','',
				gsub('\\)','',FeatureLabel[,2])),perl = TRUE)))))),perl = TRUE))))))))

# Handle duplicated labels

	if(!sum(duplicated(FeatureLabel$feature))==0){
		FeatureLabel$feature<-make.names(FeatureLabel$feature,unique = TRUE,allow_ = TRUE)
	}
	FeatureLabel$feature<-sub('(.*)\\.([0-9]+)','\\2_\\1',FeatureLabel$feature)

# Change the variable names of Test- and Trainingset

	colnames(TrainingSet)<-FeatureLabel$feature
	colnames(TestSet)<-FeatureLabel$feature

# Write table of transformation of the feature labels

	FeatureLabel<-FeatureLabel[,2:3]
	colnames(FeatureLabel)<-c("OldFeatureLabel","NewFeatureLabel")
	write.table(FeatureLabel,file="./UCI HAR Dataset/FeatureLabelTransformation.txt",row.names = FALSE)

# Transform ActivityID of Test- and Training set into a clear Activity description
# Mind that there are three options: merge, join, and factor
# Join and factor give similar results. The results are equal in values, but not equal in row orders. 
# Merge gave an unexpected result, initially!!!
# Mind that the order of the records is extremely important to bind the data column wise.
# It is suspected that the merge function reorders the data in un unexpected way.
# This is already reported. See:
# https://www.r-statistics.com/2012/01/merging-two-data-frame-objects-while-preserving-the-rows-order/

### merge did not do what I expected, initially.
### 
###
#	TestSetActivity<-merge(TestSetActivity,ActivityLabel,by.x = "ActivityID",by.y = "ActivityID",,all=TRUE,sort=FALSE)
#	TrainingSetActivity<-merge(TrainingSetActivity,ActivityLabel,by.x = "ActivityID",by.y = "ActivityID",all=TRUE,sort=FALSE)
###
### merge did not do what I expected, initially

### merge did not do what I expected, initially.
### With some extra work, merge will also perform.
###
#	TestSetActivity$Index<-seq_along(TestSetActivity$ActivityID)
#	TestSetActivity<-merge(TestSetActivity,ActivityLabel,by.x = "ActivityID",by.y = "ActivityID",,all=TRUE,sort=FALSE)
#	TestSetActivity<-arrange(TestSetActivity,Index)
#	TestSetActivity<-select(TestSetActivity,-Index)
#	TrainingSetActivity$Index<-seq_along(TrainingSetActivity$ActivityID)
#	TrainingSetActivity<-merge(TrainingSetActivity,ActivityLabel,by.x = "ActivityID",by.y = "ActivityID",all=TRUE,sort=FALSE)
#	TrainingSetActivity<-arrange(TrainingSetActivity,TrainingSetActivity$Index)
#	TrainingSetActivity<-select(TrainingSetActivity,-Index)
###
### merge did not do what I expected, initially

### join did do what I expected.
###
	TestSetActivity<-join(TestSetActivity,ActivityLabel,by = "ActivityID")
	TrainingSetActivity<-join(TrainingSetActivity,ActivityLabel,by = "ActivityID")
###
### join did do what I expected.

### factor is another option to perform the task
###
#	TestSetActivity$Activity<-factor(TestSetActivity$ActivityID,labels = ActivityLabel$Activity)
#	TrainingSetActivity$Activity<-factor(TrainingSetActivity$ActivityID,labels = ActivityLabel$Activity)
###
### factor is another option to perform the task

#**********************************************************************************************************************#
# Merges the training and the test sets to create one data set.
#**********************************************************************************************************************#

# bind columns of Activity and Subject to Test- and TrainingSet

	TestSet<-bind_cols(TestSet,TestSetActivity)
	TrainingSet<-bind_cols(TrainingSet,TrainingSetActivity)
	TestSet<-bind_cols(TestSet,TestSetSubject)
	TrainingSet<-bind_cols(TrainingSet,TrainingSetSubject)

# remove ActivityID from Test- and TrainingSet

	TestSet<-select(TestSet,-ActivityID)
	TrainingSet<-select(TrainingSet,-ActivityID)

# Combine rows of Test- and TrainingSet

	CombinedSet<-bind_rows(TestSet,TrainingSet)

#**********************************************************************************************************************#
# Extracts only the measurements on the mean and standard deviation for each measurement.
#**********************************************************************************************************************#

	ReducedSet<-tbl_df(CombinedSet[,matches('Mean|StandardDeviation|Activity|SubjectID',ignore.case=TRUE,names(CombinedSet))])

#**********************************************************************************************************************#
# Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#**********************************************************************************************************************#

	GroupedSet<-summarise_all(group_by(ReducedSet,Activity,SubjectID),mean)

# Adjust the variable names to the grouping operation

	colnames(GroupedSet)<-
				sub('MeanOfSubjectID','GroupedBySubjectID',
				sub('MeanOfActivity','GroupedByActivity',
				paste("MeanOf",names(GroupedSet),sep="")))

# Save the Grouped set to a file

	write.table(GroupedSet,file="./UCI HAR Dataset/TidyGroupedDataSet.txt")
