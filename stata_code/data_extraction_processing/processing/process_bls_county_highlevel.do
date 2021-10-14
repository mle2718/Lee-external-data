/* after you download, you need to stat-transfer into stata format. */


/* I moved all the dtas into subfolder (dtas) in this directory so they wouldn't clog everything up*/
local fileslist: dir "${data_external}/county_highlevel" files "all*.dta"

/* 
CEW sometimes uses NAICS "Supersectors" whcih are 4 digit aggregations of the NAICS classifications

https://www.bls.gov/cew/classifications/industry/industry-supersectors.htm


NAICS YOU MAY CARE ABOUT: 

Manufacturing is NAICS 31-33, the QCEW supersector is 1013

NAICS 11 Agriculture, Forestry, Fishing, and Hunting and  NAICS 21 Mining are aggregated together into QCEW supersector 1011



*/


quietly foreach l of local fileslist{
	tempfile new1
	local NEWfiles `"`NEWfiles'"`new1'" "'  
	clear
// 	use ${data_external}/county_highlevel/`l'
	renvars, subst("_" )
	renvars,lower
	
	keep if strmatch(areatype,"County")
	keep if strmatch(naics,"1013")
	drop st cnty area areatype stname 

	cap tostring annualaveragestatuscode, replace
	cap tostring statuscode, replace
	/* do some stuff */
	gen str sourcefile="`l'"
	save `new1', replace emptyok
	
}
/* This puts everything in a single dataset */
clear
append using `NEWfiles'
	renvarlab, lower
	compress
	duplicates report
preserve
keep if strmatch(qtr,"A")==1
destring, replace
keep areacode own naics year qtr industry status annual* *locationquotient* sourcefile
compress
save "${data_main}/annual_BLS_${vintage_string}.dta", replace

restore


drop if strmatch(qtr,"A")==1
destring, replace
compress


gen caldq=yq(year, qtr)
gen dateq=caldq-1
format dateq caldq %tq
notes dateq: This is as close as we can get to the groundfish fishing year (Q=April, May, June)
notes caldq: calendar quarterly date

save "${data_main}/quarterly_BLS_${vintage_string}.dta", replace
