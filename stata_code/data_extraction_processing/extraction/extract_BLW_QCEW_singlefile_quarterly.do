/* Download Singlefile Quarterly QCEW data from BLS. These are pretty large -- 300MB per year.

https://www.bls.gov/cew/downloadable-data-files.htm

Unzip the zip files to csv files
Convert to stata datasets
*/

#delimit cr
version 15.1
pause on
clear all
global singlefile $data_external/singlefile_quarterly

cap mkdir ${singlefile}


/* which years do you want to download. */
local startyear 2004
local endyear 2020

/************************************************************************/
/************************************************************************/
/* Download QCEW data from BLS */
/************************************************************************/
/************************************************************************/

	cd $data_external/singlefile_quarterly

 /* This automatically gets data from the cew  for the years that you want and puts them into data_external, unzips to csv, and deletes the zip.*/
forvalues myy=`startyear'/`endyear'{
	copy "https://data.bls.gov/cew/data/files/`myy'/csv/`myy'_qtrly_singlefile.zip" "${singlefile}/`myy'_qtrly_singlefile.zip"
	unzipfile  "${singlefile}/`myy'_qtrly_singlefile.zip", replace
	!rm   "${singlefile}/`myy'_qtrly_singlefile.zip"

}


/************************************************************************/
/************************************************************************/
/* Convert to stata datasets

 This can be pretty slow, stata is not particularly fast at reading in csv files. */
/************************************************************************/
/************************************************************************/

local myfilelist: dir "${singlefile}" files "*.csv"

foreach myfile of local myfilelist{
	clear
	import delimited "${singlefile}/`myfile'"
	local len=strlen("`myfile'")
	local filestub=substr("`myfile'",1, `len'-4)
	save "${singlefile}/`filestub'.dta", replace
}





/* before you cleanup, you should verify that you have what you expect. */
/* for each year, you should have 1 dtas. 

therefore mm should be number of years*/

local dtas: dir "${singlefile}" files "*.dta"
local mm: word count `dtas'

pause

/* cleanup step */
cd ${singlefile}
!rm *.csv



cd ${my_projdir}


