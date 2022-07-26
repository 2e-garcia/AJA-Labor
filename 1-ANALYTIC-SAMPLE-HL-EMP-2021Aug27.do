 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* NHANES EMPLOYMENT AND HEARING LOSS
* * DATA SET-UP
* * * DECEMBER - 2019
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

clear
clear matrix
set more off
ssc install table1_mc
ssc install estout

set scheme s2color, permanently

cd "H:\NHANES_Employment\Hearing-Employment

use "../Data/mdf/mdf-NHANES-2021Aug27.dta"

********************************************************************************
********************************************************************************
*** ANALYTIC WEIGHTS
********************************************************************************
********************************************************************************


gen full_time=full_emp														///
	if employed==1

gen emp_wgt=wtsau4yr*(2/5) 													///
	if sddsrvyr==1 | sddsrvyr==2
	
	replace emp_wgt=wtmec2yr/5 												///
		if sddsrvyr==3
		
	replace emp_wgt=wtmec2yr/2 												///
		if sddsrvyr==7 | sddsrvyr==9
		
svyset [w=emp_wgt], psu(sdmvpsu) strata(sdmvstra) vce(linearized)

********************************************************************************
********************************************************************************
*** ANALYTIC SAMPLE DERIVATION
********************************************************************************
********************************************************************************

/*All working adults older than 25 that have complete hearing loss and eyesight 
information*/

gen analyticsample=1
	
	replace analyticsample=0 if missing(pta_categories)

	replace analyticsample=0 if missing(age_grp)

	replace analyticsample=0 if missing(employed)
	
	replace analyticsample=0 if missing(edu_over20)
	
	replace analyticsample=0 if missing(hsd010)
	
	replace analyticsample=0 if missing(married)	
	
	replace analyticsample=0 if missing(female)
	
	replace analyticsample=0 if missing(race)	
	
	replace analyticsample=0 if ridageyr<25 | ridageyr>65
	
	tab analyticsample			// 11,783

tab full_emp pta_categories if analyticsample==1, chi

codebook													///
	race													/// Missing N = 0
	female													/// Missing N = 0
	edu_over20												/// Missing N = 0
	married													/// Missing N = 0
	hsd010													/// Missing N = 17
	dmdhhsza												/// Missing N = 0
	sddsrvyr												///
		if analyticsample==1

********************************************************************************
********************************************************************************
*** Summary Statistics
********************************************************************************
********************************************************************************	

table1_mc if analyticsample==1, by(pta_categories)												///
	vars(																	///
	ridageyr		contn %4.1f \											///
	female 			cat %4.1f \												///
	race			cat %4.1f \												///
	edu_over20		cat %4.1f \												///
	married			bin %4.1f \												///
	hsd010			cat %4.1f \												///
	dmdhhsiz		contn %4.1f \											///
	employed		cat	%4.1f \												///
	full_time		cat %4.1f \												///
	occup			cat %4.1f )												///
	nospace onecol total(before) 											///
saving("Tables\1-TABLE1-SUMSTATS-COVARIATES.xls", replace)	

