# Course Project for Getting and Cleaning Data
Ermanno Cavalli  
Saturday, May 23, 2015  

run_analysis() function implements the Course Project for "Getting and Cleaning Data" source.

Starting point is the UCI HAR Dataset that contains various measurements of six *activities* (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) done by 30 *subjects* wearing a smartphone.

Target is a tidy dataset that only contains averages of each variable that contains **mean** and **std** in the name, grouped by *subject* and *activity*.

The logical flow is:

1. read feature names and select only the variables with *mean* or *std* in the name

1. read activity labels

1. operate on training values: we need to read x values and match each of them with appropriate y value

        + read X training values
        + select only meaningful variables
        + give appropriate names to variables
        + read y training values
        + extend data frame for x values with y value

1. same as above, now for testing values

1. read subject values, for both training and testing sets

1. concatenate training and testing values

1. group by subject and activity

1. calculate means on grouped values

1. write new tidy data set

A detailed explanation of each step follows.

We starting with loading appropriate libraries:


```r
        library("stringr")
        library("data.table")
        library("dplyr")
```
# read feature names and select only the variables with *mean* or *std* in the name
First step is reading features from file **features.txt** 

```r
        features <- read.table("features.txt")
```
we then select only features with **mean** or **std** in the feature name

```r
        selectedFeatures <- features[str_detect(features$V2, "mean") | str_detect(features$V2, "std"),]
```
and rename variable names from **V1** to **featureName** and from **V2** to **featureIndex**

```r
        selectedFeatures <- rename(selectedFeatures, featureIndex = V1, featureName = V2)
```
# read activity labels
activity lables are in file **activity_lables.txt**. Variables are renamed from **V1** to **activityId** and from **V2** to **activityLabel**

```r
        activityLabels <- read.table("activity_labels.txt")
        activityLabels <- rename(activityLabels, activityId = V1, activityLabel = V2)
```
# operate on training values: we need to read x values and match each of them with appropriate y value

Training values are read from file **train/X_train.txt**

```r
        trainXfull <- read.table("train/X_train.txt")
```

Only meanigful features are selected

```r
        trainXselected <- select(trainXfull, selectedFeatures$featureIndex)
```

variable names are changed from **V???** to meaningful variable names

```r
        setnames(trainXselected, names(trainXselected), as.character(selectedFeatures$featureName))
```

Activity Ids for training values are read from file **train/y_train.txt**

```r
        trainY <- read.table("train/y_train.txt")
```

Variable name is changed from **V1** to **activityId**

```r
        trainY <- rename(trainY, activityId = V1)
```

We use **cbind()** to add id of activity as variable to the data frame for training values

```r
        trainData <- cbind(trainXselected, trainY)
```

final step on training values is to use **inner_join()** from dplyr() package to add a variable with appropriate activity labels based on activity id

```r
        trainData <- inner_join(trainData, activityLabels)
```
# same as above, now for testing values
test values are in files **test/X_test.txt** and **test/y_test.txt**

```r
        testXfull <- read.table("test/X_test.txt")
        testXselected <- select(testXfull, selectedFeatures$featureIndex)
        setnames(testXselected, names(testXselected), as.character(selectedFeatures$featureName))
        testY <- read.table("test/y_test.txt")
        testY <- rename(testY, activityId = V1)
        testData <- cbind(testXselected, testY)
        testData <- inner_join(testData, activityLabels)
```
# we can now read subject values, for both training and testing sets
subject values are in files **train/subject_train.txt** and **text/subject_test.txt**

```r
        trainSubjects <- read.table("train/subject_train.txt")
        testSubjects <- read.table("test/subject_test.txt")
```
we now concatenate subjects for train and test values

```r
        allSubjects <- rbind(trainSubjects, testSubjects)
```
Last step on subjects is to give meaningful name to variables

```r
        allSubjects <- rename(allSubjects, subjectId = V1)
```
# concatenate training and testing values
we now have full values for training and testing values, including activities and subject
we first concatenate observations for train and test values

```r
        fullData <- rbind(trainData, testData)
```
and we now add the variable for subjects

```r
        fullData <- cbind(fullData, allSubjects)
```
# group by subject and activity
we now group by subject and activity

```r
        groupedData <- group_by(fullData, subjectId, activityId)
```
# calculate means on grouped values

```r
        summarizedTidyData <- summarise_each(groupedData, "mean")
```
# write new tidy data set

```r
        write.table(summarizedTidyData, "tidyDataset.txt", row.names = FALSE)
```
