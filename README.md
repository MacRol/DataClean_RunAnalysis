README file associated with the run_analysis.R R script
=======================================================

Assumptions and Requirements
----------------------------

The run_analysis.R script assumes that the UCI HAR data set has been
downloaded to the local disk and that the zip file has been unzipped
such that all the actual files all reside below "./UCI HAR Dataset/".

So the script will be loading file contents in order to do its work
by accessing files via the path "./UCI HAR Dataset/...".

For instance, the file y_test.txt can be loaded via the following path:
"./UCI HAR Dataset/test/y_test.txt"

The script has relied on basic packages typically part of standard R
builds, and did not rely on `plyr` or other packages needed loading.

The script, when it runs successfully, produces two files that have
similar contents:

"./factored_averages_txt.txt" is a text formatted file
"./factored_averages_csv.csv" is a csv formatted file

Output File Description
-----------------------

The files have 180 rows and 81 columns, as follows:

+ All columns are "tidied" in that they include column names
+ The 1st column identifies the Subject, i.e., the person
+ The 2nd column has the activity type (1 of 6) by character description.
+ The remaining 79 columns have averages factored by subject/activity.
+ The 180 rows capture the 6 activities * 30 subjects, as factors.
+ Note that the file includes subjects from training and test sets.

Per the instructions, the script performs row-wise merges of various
files in order to merge the training and test data set contents.

It starts off by building a column of Subject Identifiers, in order
to start practicing tidiness by always naming all variables.

Then, the script uses the activity mapping file to add descriptive,
character-string, activity descriptions, in addition to their coded
numerical values.

The data frames above are bound column-wise to start joining things
towards the output data frame with features as well as labels.

The script then performs the feature extraction functions, whereby
only features that are means or standard deviations are kept. This
is done by leveraging the files that list all variable names, and
building intermediate data structures with the right indices for
the "keeper variables" but also the corresponding names, again in
the spirit of tidiness.

Finally, with the reduced data frame that only keeps features that
measure means or standard deviations, we apply the `aggregate()`
function with the proper factor list (Subject and Activity), which
yields the 180 rows of averages for the 30 subjects * 6 activities.

We then write out the data frame as a .txt file and a .csv file.
