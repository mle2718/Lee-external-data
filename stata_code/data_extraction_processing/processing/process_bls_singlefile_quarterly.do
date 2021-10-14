/* Code to process the bls qcew singlefile data */


global singlefile ${data_external}/singlefile_quarterly

/* Trimmed to These Regions	
CT
DE
ME
MD
MA
NH
NJ
NY
NC
PA
RI
VA
DC*/

/*naics codes */

/*
Captains
4831 Sea, coastal, and great lakes transportation
488330 Navigational services to shipping

Crew
488320 Marine cargo handling
488310 Port and Harbor operationss
488991 Packing and crating
713930 Marinas
*/

forvalues yr=2004/2020{
	tempfile new1
	local NEWfiles `"`NEWfiles'"`new1'" "'  
	clear
	
	use "${singlefile}/`yr'.q1-q4.singlefile.dta" 
	gen keep=0
	replace keep=1 if inlist(area_fips,"US000","09000","10000","23000","24000", "25000", "33000", "34000", "36000")
	replace keep=1 if inlist(area_fips,"37000", "44000", "51000", "11000" )
	keep if keep==1
	replace area_fips="99999" if area_fips=="US000"
	
	keep if inlist(industry_code, "4831","488330", "488320", "488310","488991","713930")
	gen str5 laborcat="CaptA" if  inlist(industry_code,"4831")
	replace laborcat="CaptB" if inlist(industry_code, "488330")
	replace laborcat="Crew" if inlist(industry_code,"488320", "488310","488991","713930")
	drop if laborcat==""
	gen str sourcefile="`yr'.q1-q4.singlefile.dta"
	save `new1', replace emptyok
	}
clear

append using `NEWfiles'


	destring , replace

/* be careful here with non-disclosable
will need to drop these before aggregating further.
 */

tab disclosure_code, missing
keep if disclosure_code==""


/* Compute average number employees in a quarter, total quarterly compensation.  Use that to get a weekly wage*/
gen avgQ_emp=(month1_emplvl + month2_emplvl +month3_emplvl)/3

/* Taking the weighted sum of average weekly wages, then dividing by total employment does the same thing
preserve

gen mark=1
collapse (sum) avg_wkly_wage mark [iweight=tot_emp], by(year qtr laborcat)
replace avg=avg/mark
tempfile m1
save `m1'

restore
*/


collapse (sum) total_qtrly qtrly_estabs avgQ_emp, by(year qtr laborcat)

gen avg_wkly_wage=total_qtrly_wages/(avgQ_emp*13)
keep year qtr laborcat avg_wkly_wage avgQ_emp


notes laborcat: "CaptA" if  inlist(industry_code,"4831")
notes laborcat: "CaptB" if inlist(industry_code, "488330")
notes laborcat: "Crew" if inlist(industry_code,"488320", "488310","488991","713930")


gen caldq=yq(year, qtr)
gen dateq=caldq-1
format dateq caldq %tq
notes dateq: This is as close as we can get to the groundfish fishing year (Q=April, May, June)
notes caldq: calendar quarterly date

save ${data_main}\BLS_QCEW_relevant_wages_${vintage_string}.dta, replace


