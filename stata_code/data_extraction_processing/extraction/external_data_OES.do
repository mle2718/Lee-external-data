/*
This code requires wget, which is a linux thing.   I'm not going to switch it over to windows right now, but 

copy 

would work




BLS's OES collects data on wages and employment by occupation.  There are a few potentially relevant occupations
1.  453011   Fishers and Related Fishing Workers Use nets, fishing rods, traps, or other equipment to catch and gather fish or other aquatic animals from rivers, lakes, or oceans, for human consumption or other uses.  May haul game onto ship.  Aquacultural laborers who work on fish farms are included in "Farmworkers, Farm, Ranch, and Aquacultural Animals" (45-2093).
2.  45-2093  Farmworkers, Farm, Range, and Aquacultural Animals. Attend to live farm, ranch, or aquacultural animals that may include cattle, sheep, swine, goats, horses and other equines, poultry, finfish, shellfish, and bees.  Attend to animals produced for animal products, such as meat, fur, skins, feathers, eggs, milk, and honey.  Duties may include feeding, watering, herding, grazing, castrating, branding, de-beaking, weighing, catching, and loading animals.  May maintain records on animals; examine animals to detect diseases and injuries; assist in birth deliveries; and administer medications, vaccinations, or insecticides as appropriate.  May clean and maintain animal housing areas.  Includes workers who shear wool from sheep, and collect eggs in hatcheries.
3.  53-5011  Sailors and Marine Oilers. Stand watch to look for obstructions in path of vessel, measure water depth, turn wheel on bridge, or use emergency equipment as directed by captain, mate, or pilot.  Break out, rig, overhaul, and store cargo-handling gear, stationary rigging, and running gear.  Perform a variety of maintenance tasks to preserve the painted surface of the ship and to maintain line and ship equipment.  Must hold government-issued certification and tankerman certification when working aboard liquid-carrying vessels.  Includes able seamen and ordinary seamen.
4. 53-5021   Captains, Mates, and Pilots of Water Vessels	Command or supervise operations of ships and water vessels, such as tugboats and ferryboats.  Required to hold license issued by U.S. Coast Guard.  Excludes “Motorboat Operators" (53-5022).
5. 53-5031   Ship Engineers	Supervise and coordinate activities of crew engaged in operating and maintaining engines, boilers, deck machinery, and electrical, sanitary, and refrigeration equipment aboard ship.


 

*/

version 15.1
cap mkdir $data_external/OES

cd $data_external/OES




/*download data 
local startyear 00
local endyear 02
nois _dots 0, title(Loop running) reps(20)
qui foreach myy in 00 01 02 {
	! wget https://www.bls.gov/oes/special.requests/oes`myy'st.zip
	nois _dots `myy' 0     
}
qui foreach myy in 00 01 02 {
	!unzip  oes`myy'st.zip
}

nois _dots 0, title(Loop running) reps(20)
qui foreach myy in 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
	! wget https://www.bls.gov/oes/special.requests/oesm`myy'st.zip

	nois _dots `myy' 0     
}
qui foreach myy in 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
	!unzip oesm`myy'st.zip
}
A  little manual renaming here.
*/


/*get into stata dta */
clear
tempfile oeswage
import excel using state_2000_dl.xls, cellrange(A43) firstrow
renvars, lower
keep if occ_code=="53-5021"
gen dbyear=2000
quietly save `oeswage'


qui foreach myy in  2001 2002 {
	tempfile oeswage2
	local oe2 `"`oe2'"`oeswage2'" "'  
	clear
	import excel using state_`myy'_dl.xls , firstrow
	renvars, lower
	keep if inlist(occ_code,"45-3011","45-2093","53-5011","53-5021","53-5031")

	gen dbyear=`myy'
	quietly save `oeswage2'
}




forvalues myy =  2003/2013 {
	tempfile oeswage3
	local oe3 `"`oe3'"`oeswage3'" "'  
	clear
	di `myy'
	import excel using state_M`myy'_dl.xls , firstrow
	renvars, lower
	keep if inlist(occ_code,"45-3011","45-2093","53-5011","53-5021","53-5031")
	gen dbyear=`myy'
	quietly save `oeswage3'
}



forvalues myy = 2014/2018 {
	tempfile oeswage4
	local oe4 `"`oe4'"`oeswage4'" "'  
	clear
	di `myy'
	import excel using state_M`myy'_dl.xlsx , firstrow
	renvars, lower
	keep if inlist(occ_code,"45-3011","45-2093","53-5011","53-5021","53-5031")
	gen dbyear=`myy'
	quietly save `oeswage4'
}

dsconcat `oeswage' `oe2' `oe3' `oe4'

drop emp_prse h_wpct10 h_wpct25 h_wpct75 h_wpct90 a_wpct10 a_wpct25 a_wpct75 a_wpct90 h_pct10 h_pct25 h_pct75 h_pct90 a_pct10 a_pct25 a_pct75 a_pct90 locquotient loc_q
drop group occ_group
drop annual release year
replace occ_title=occ_titl if occ_title==""
drop occ_titl hourly jobs_1000
rename dbyear year


foreach var of varlist tot_emp occ_code h_mean a_mean mean_prse h_median a_median{
egen c`var'=sieve(`var'), char(0123456789.)
}
destring, replace
format area %02.0f

drop tot_emp occ_code h_mean a_mean mean_prse h_median a_median

renvars ctot_emp cocc_code ch_mean ca_mean cmean_prse ch_median ca_median, predrop(1)


order area year st state occ_title



save "$data_external/OES/OES_wages_all.dta", replace
use"$data_external/OES/OES_wages_all.dta", replace


gen NER=inlist(st,"CT","DE","ME","MD","MA","NH","NJ")
replace NER=1 if inlist(st,"NY","NC","PA","RI","VT","VA")
keep if NER==1

collapse (mean) h_mean [fw=tot_emp], by(year occ_code occ_title)
replace h_mean=round(h_mean,0.01)
rename h_mean hourlywage_OES
notes hourlywage_OES: nominal gross wages for OES category (occ_code,"45-3011","45-2093","53-5011","53-5021","53-5031")
notes hourlywage_OES: average for the Northeast Region, weighted by total employment in each state. Confidential entries receive zero weight.
notes hourlywage_OES: NER is CT, DE, ME, MD, MA, NH, NJ, NY, NC, PA, RI, VT, VA
notes: The hourly wages are all highly correlated, with the exception of fishing. Fishing only has a small number of datapoints.
save "$data_external/OES/OES_NERall.dta", replace



/*
tempfile t1

use"$my_datadir/external/OES/OES_wages_all.dta", replace


gen NER=inlist(st,"CT","DE","ME","MD","MA","NH","NJ")
replace NER=1 if inlist(st,"NY","NC","PA","RI","VT","VA")
keep if NER==1
bysort st occ_code: egen ebar=mean(tot)
replace tot=floor(ebar) if tot==.
collapse (mean) h_mean [fw=tot_emp], by(year occ_code )
rename h_mean hourlywage_OES2
tempfile t1
save `t1', replace
use "$my_datadir/external/OES/OES_NERall.dta", replace
 
 merge 1:1 year occ_code using `t1'
tsset year
tsline hourlywage*
*/
/*basically the same */
