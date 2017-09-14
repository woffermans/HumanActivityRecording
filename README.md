#Human Activity Recording With Mobile Devices
##Introduction
Accelerometers and gyroscopes, build into mobile devices, such as smart phones, produce signals. These signals can be interpreted as movement of the device itself, but consequently also as the movement of the body, both human and machine, wearing the device. Accelerometers and gyroscopes and sometimes magnetometers are incorporated into inertial measurement units. These units can be used to collect Human Activity data. Such data was provided and was downloaded. The data has been gathered from the recordings of 30 subjects performing activities of daily living while carrying a waist-mounted smartphone with embedded inertial sensors. The data stemmed from signals from the inertial sensors from the Samsung Galaxy S smartphone. A full description of the data is available at http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones.

##Motivation
The data, as obtained, was not in a tidy state. Moreover corresponding data was distributed over several files. The included R script enables to tidy up the data and to bring corresponding data into one data table. For information concerning the original variables, the original README.txt and features_info.txt files should be consulted.

##Description
The following files comprise this project:

- README.md
- CodeBook.md
- run_analysis.R
- TidyGroupedDataSet.txt
- FeatureLabelTransformation.txt

The ``run_analysis.R`` is an R-script. Upon running the script, it will download and unpack the data, if the data is not availabe locally. It will tidy the variable names according the ``FeatureLabelTransformation.txt`` file. It will move corresponding data from different files into a complete training and test set. It will merge data from the training and test set into one combined table. The data concerning the mean, standard deviation, activity and subject identification values are selected from the combined table and will be saved into a reduced data table. The mean of the values of the latter table are grouped by activity and by subject identification and will be saved into a grouped data table. The content of this grouped data table will be written into a file called ``TidyGroupedDataSet.txt``.

The R script exploits the following data that is available in the following original files:
        Trainingset extracted from "./UCI HAR Dataset/train/X_train.txt"
        Trainingset corresponding activities extracted from "./UCI HAR Dataset/train/y_train.txt"
        Trainingset corresponding subjects extracted from "./UCI HAR Dataset/train/subject_train.txt"
        Testset extracted from "./UCI HAR Dataset/test/X_test.txt"
        Testset corresponding activities extracted from "./UCI HAR Dataset/test/y_test.txt"
        Testset corresponding subjects extracted from "./UCI HAR Dataset/test/subject_test.txt"
        Feature labels (variables) extracted from "UCI HAR Dataset/features.txt"
        Activity labels (variables) extracted from "./UCI HAR Dataset/activity_labels.txt"
