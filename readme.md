# NIH Project Data, 2019-2024 

The following repository contains links and some sample code written in R to help you parse NIH project data. 

## NIH Project Data

The raw data in .CSV format is rather large, so it is stored here: https://drive.google.com/drive/folders/1iE3hYTTO7IXaBadpOJT9wL1VmBLJ3Wpc?usp=sharing

The original data can be found on the NIH website at the following URL: https://reporter.nih.gov/exporter/projects

The data dictionary, defining each column in the CSV, is available here: https://report.nih.gov/exporter-data-dictionary

For your convenience and so you can see it locally, I've replicated the data dictionary in this repo in the text file named NIH_RePORTER_Project_Data_Dictionary. 

## R sample code for parsing this data and making simple plots

The sample code contained here will help you do some basic data cleanup, like combining the .CSV file of each year of the RePORTER data into a single dataframe, and separating date columns into year, month, date columns to make them easier to work with. 








