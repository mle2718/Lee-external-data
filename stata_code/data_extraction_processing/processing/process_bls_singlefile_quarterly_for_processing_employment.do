/* Code to process the bls qcew singlefile data */


global singlefile ${data_external}/singlefile_quarterly

/* All States */
/*naics codes */

/*
NAICS 42446 Fish and seafood merchant wholesalers
NAICS 424460 Fish and seafood merchant wholesalers

NAICS17 44522 Fish and seafood markets
NAICS17 445220 Fish and seafood markets

NAICS 44525 Fish and seafood retailers
NAICS 445250 Fish and seafood retailers

NAICS 3117 Seafood product preparation and packaging 
NAICS 31171 Seafood product preparation and packaging
NAICS 311710 Seafood product preparation and packaging
NAICS07 311711 Seafood canning
NAICS07 311712 Fresh and frozen seafood processing

*/

forvalues yr=2000/2023{
	tempfile new1
	local NEWfiles `"`NEWfiles'"`new1'" "'  
	clear
	
	use "${singlefile}/`yr'.q1-q4.singlefile.dta" 
	gen keep=0
	replace keep=1 if inlist(industry_code, "42446", "424460",  "44522","445220", "44525", "445250")
	replace keep=1 if inlist(industry_code, "3117", "31171", "311710", "311711","311712" )
	keep if keep==1
	drop keep
	gen str sourcefile="`yr'.q1-q4.singlefile.dta"
	save `new1', replace emptyok
	}
clear

append using `NEWfiles'


destring , replace


gen caldq=yq(year, qtr)
format  caldq %tq
notes caldq: calendar quarterly date
compress
save ${data_main}\BLS_QCEW_processorsB_${vintage_string}.dta, replace


