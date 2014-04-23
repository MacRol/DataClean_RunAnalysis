#
# Script to reduce "wearable computing" UCI / Samsung dataset
# Tasks include:
#
# 1. Merge training and test data sets to form a single data set
# 2. Extract only mean() and std() measurements of features
# 3. Use descriptive activity names for the data set
# 4. Label the data set with these descriptive names
# 5. Create a second, independent, data set with the average
#    of each variable for each activity and each subject.
#
# Start by loading the data:
# --------------------------
#
# Load the files with training subset and test subset of Subjects (i.e., IDs)
#
id_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names="SubjectID")
id_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names="SubjectID")
#
# Now merge them row-wise, with the test data appended behind the train data
# Call the new single-column data frame `subj_id`
#
subj_id <- rbind(id_train, id_test)
#
# Load the files with training subset and test subset of Labels (i.e., Activity)
#
act_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names="NumAct")
act_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names="NumAct")
#
# Now merge tham row-wise, with the test data appended behind the train data
# Call the new single-column data frame `num_act`
# This data frame still has the numeric coding for the activities
# We will later on form a column with descriptive labels for activities
#
num_act <- rbind(act_train, act_test)
#
# Now form data frame with descriptive names for activities
# First load the file with the activity coding
#
act_coding <- read.table("UCI HAR Dataset/activity_labels.txt", col.names=c("Code", "Desc")
                         )
#
# Convert Desc column into character, per instructions of giving descriptive names
#
act_coding$Desc <- as.character(act_coding$Desc)
#
# Now create `desc_act` single-column, character data frame with activity labels
#
desc_act <- data.frame(DescAct = as.character(act_coding$Desc[num_act$NumAct]))
desc_act$DescAct <- as.character(desc_act$DescAct)
#
# Now bind the numeric and character activity data frames column-wise
# This will be our activity label data frame, with activity in both forms
#
act_label <- cbind(num_act, desc_act)
#
# Check that we have properly done the coding of numerical to descriptive activity
# To do so, we compare the first and second columns of act_label via the coding
# We'd sum the results of the comparisons, and expect 10,299 if they're all true.
#
# sum(act_label$DescAct == act_coding$Desc[act_label$NumAct])
#
# Now we merge the train/test feature data sets into a single feature data set
# Then we will whittle down the features to just those that are means / stdevs
#
feat_train <- read.table("UCI HAR Dataset/train/X_train.txt")
feat_test <- read.table("UCI HAR Dataset/test/X_test.txt")
#
# Now merge them row-wise, with test appended behind train as with the others
#
features <- rbind(feat_train, feat_test)
#
# Now remove feat_train and feat_test to save memory
rm(feat_train)
rm(feat_test)
#
# Now build vector whose entries are the column indices 
# of the features which we want to retain, out of the initial
# list of 561 features.
#
# We use the 'features.txt' file, where all feature names are listed.
#
feat_map <- read.table("UCI HAR Dataset/features.txt")
feat_fram <- data.frame(FeatIndx=feat_map[,1], FeatName=feat_map[,2])
feat_fram$FeatIndx <- as.integer(feat_fram$FeatIndx)
feat_fram$FeatName <- as.character(feat_fram$FeatName)
#
# We now use the feat_fram feature mapping frame to extract needed features
# `means` stores column indices and names of features that have means
# `stdvs` stores column indices and names of features that have std devs
#
means <- feat_fram[grep("-mean", feat_fram$FeatName),]
stdvs <- feat_fram[grep("-std", feat_fram$FeatName),]
#
# Now build the desired feature columns with the corresponding names
#
# Initialise the output data set with the subject IDs and the
# activity labels, in numeric as well as character forms.
# 
out_feat <- cbind(subj_id, act_label)
#
# Now iterate over the needed column indices in features and, for each,
# extract the column, give it the proper feature name, and bind it to
# the `out_feat` data frame column-wise.
#
# First those with means in them
#
for (i in 1:nrow(means)) {
  vect <- data.frame(features[,means$FeatIndx[i]])
  colnames(vect) <- means$FeatName[i]
  out_feat <- cbind(out_feat, vect)
}
#
# Then those with std devs in them
#
for (i in 1:nrow(stdvs)) {
  vect <- data.frame(features[,stdvs$FeatIndx[i]])
  colnames(vect) <- stdvs$FeatName[i]
  out_feat <- cbind(out_feat, vect)
}
#
# So now `out_feat` is a data frame with 82 columns:
# - Subject ID in the 1st column
# - Numeric Activity Label in the 2nd column
# - Descriptive (character) Activity Label in the 3rd column
# - 79 features that have means or stdev in the next columns
# and with 10,299 rows:
# - original training entries in the first 7,352 rows
# - original test entries in the following 2,947 rows
#
# Next and last, we calculate averages of each remaining feature
# for each subject and each activity for that subject, and we
# save the output in a new data set.
#
out_avgs <- as.data.frame(aggregate(out_feat[,4:82], list(Subject=out_feat$SubjectID, Activity=out_feat$DescAct), mean))
#
# Now write the data frame `out_avgs` to a tabular formatted text file
# and write a second file in a csv format, to enable Excel or Numbers.
#
write.table(out_avgs, "./factored_averages_txt.txt")
write.table(out_avgs, "./factored_averages_csv.csv")
