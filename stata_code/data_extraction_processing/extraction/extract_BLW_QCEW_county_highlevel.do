/* Download County High level QCEW data from BLS 

https://www.bls.gov/cew/downloadable-data-files.htm

Unzip the zip files to xlsx files
Convert to stata datasets
*/

#delimit cr
version 15.1
pause on
clear all

cap mkdir $data_external/county_highlevel

/* which years do you want to download. */
local startyear 2018
local endyear 2020

/************************************************************************/
/************************************************************************/
/* Download QCEW data from BLS */
/************************************************************************/
/************************************************************************/


 /* This automatically gets data from the cew  for the years that you want and puts them into data_external*/
forvalues myy=`startyear'/`endyear'{
	copy "https://www.bls.gov/cew/data/files/`myy'/xls/`myy'_all_county_high_level.zip" "${data_external}/county_highlevel/`myy'_all_county_high_level.zip"
}



/************************************************************************/
/************************************************************************/
/*Unzip the zip files to xlsx files */
/************************************************************************/
/************************************************************************/
/*stata's unzipfile only will unzip to the working directory, which is a little lame */
	cd $data_external/county_highlevel

forvalues myy=`startyear'/`endyear'{
	unzipfile  "${data_external}/county_highlevel/`myy'_all_county_high_level.zip", replace
}





/************************************************************************/
/************************************************************************/
/* Convert to stata datasets

 This can be pretty slow, stata is not particularly fast at reading in xlsx files. */
/************************************************************************/
/************************************************************************/

local myfilelist: dir "${data_external}/county_highlevel" files "*.xlsx"

foreach myfile of local myfilelist{
	clear
	import excel "$data_external/county_highlevel/`myfile'", sheet("US_St_Cn_MSA") firstrow 
	local len=strlen("`myfile'")
	local filestub=substr("`myfile'",1, `len'-5)
	save "${data_external}/county_highlevel/`filestub'.dta", replace
}




pause

/* before you cleanup, you should verify that you have what you expect. */
/* for each year, you should have 5 dtas. 

therefore mm should be 5* number of years*/

local dtas: dir "${data_external}/county_highlevel" files "*.dta"
local mm: word count `dtas'

pause

/* cleanup step */
cd ${data_external}/county_highlevel
!rm *.xlsx
!rm *.zip



cd ${my_projdir}


