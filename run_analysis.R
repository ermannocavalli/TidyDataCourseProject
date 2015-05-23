## requires packages stringr, dplyr and data.table
##
run_analysis <- function() {
        library("stringr")
        library("data.table")
        library("dplyr")
        
        features <- read.table("features.txt")
        selectedFeatures <- features[str_detect(features$V2, "mean") | str_detect(features$V2, "std"),]
        selectedFeatures <- rename(selectedFeatures, featureIndex = V1, featureName = V2)
        
        activityLabels <- read.table("activity_labels.txt")
        activityLabels <- rename(activityLabels, activityId = V1, activityLabel = V2)
        
        trainXfull <- read.table("train/X_train.txt")
        trainXselected <- select(trainXfull, selectedFeatures$featureIndex)
        setnames(trainXselected, names(trainXselected), as.character(selectedFeatures$featureName))
        trainY <- read.table("train/y_train.txt")
        trainY <- rename(trainY, activityId = V1)
        trainData <- cbind(trainXselected, trainY)
        trainData <- inner_join(trainData, activityLabels)
        
        testXfull <- read.table("test/X_test.txt")
        testXselected <- select(testXfull, selectedFeatures$featureIndex)
        setnames(testXselected, names(testXselected), as.character(selectedFeatures$featureName))
        testY <- read.table("test/y_test.txt")
        testY <- rename(testY, activityId = V1)
        testData <- cbind(testXselected, testY)
        testData <- inner_join(testData, activityLabels)
        
        trainSubjects <- read.table("train/subject_train.txt")
        testSubjects <- read.table("test/subject_test.txt")
        allSubjects <- rbind(trainSubjects, testSubjects)
        allSubjects <- rename(allSubjects, subjectId = V1)
        
        fullData <- rbind(trainData, testData)
        fullData <- cbind(fullData, allSubjects)
        groupedData <- group_by(fullData, subjectId, activityId)
        summarizedTidyData <- summarise_each(groupedData, "mean")
        write.table(summarizedTidyData, "tidyDataset.txt", row.names = FALSE)
}