# Project Template

A small repository that contains stata code to fetch external data 
1.  BLS on wages and other labor statistics.
2.  St. Louis Federal reserve, using stata's FREDUSE, to get PPIs and compute a factor to normalize to an arbitrary base year. 

You can  extract data from the QCEW County high level files and the quarterly singlefile.

You can also extract OES data, if you can use wget. Alternatively, you can modify that code to use stata's copy.

The code runs a little slowly, because it has to download some large files and then import excel or csvs into stata. This data could be obtained faster using the BLSs API (https://www.bls.gov/developers/). 


# NOAA Requirements
This repository is a scientific product and is not official communication of the National Oceanic and Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project code is provided on an ‘as is’ basis and the user assumes responsibility for its use. Any claims against the Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.”


1. who worked on this project:  Min-Yang Lee
1. when this project was created: November 14, 2021 
1. what the project does: Get BLS data 
1. why the project is useful:  Gets BLS data 
1. how users can get started with the project: Download and follow the readme
1. where users can get help with your project:  email me or open an issue
1. who maintains and contributes to the project. Min-Yang

# License file
See here for the [license file](License.txt)
