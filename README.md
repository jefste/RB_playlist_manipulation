# RB_playlist_manipulation

This code allows for a RadioBoss playlist file to be generated with a new category order as specified by an Excel file. 

## Prerequisites 

* [R](https://www.r-project.org/)
* [R Studio](https://www.rstudio.com/) - Not required but handy to use

### R Packages Required
* [Tidyverse](http://tidyverse.org/) - You'll need to install this package before you can load it into R. 
Simply type this into the console:
```r
install.packages("tidyverse")
```
This is the only command that is not given in the  R script file create_RB_playlist_from_algorithm_file.R

## How to Use This Code
After downloading all files in this repo, load the RB_playlist_manipulation.Rproj into R Studio if using. 

Open the create_RB_playlist_from_algorithm_file.R file. It contains all the code needed to alter a .genprs file using an .xlsx file as a template.  

Executing each line of the .R file will produce a new .genprs file.

### Parameters to Change

* Input .genprs file that is read with read_lines()
* Input algorithm file that is read with read_xlsx()
* Column of algorithm file that algorithm comes from
     + Currently reading the column "Monday", simply change all entries of Monday to a different column name within the algorithm file.


### Caveats
The categories used in the .xlsx file must exist in the .genprs file categories.

## Built With 

R version 3.4.0 (2017-04-21)
