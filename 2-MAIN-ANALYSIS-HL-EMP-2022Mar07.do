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

set scheme s1color, permanently

cd "H:\NHANES_Employment\Hearing-Employment

use "../Data/mdf/mdf-NHANES-2021Aug27.dta"

********************************************************************************
********************************************************************************
*** ANALYTIC WEIGHTS
********************************************************************************
********************************************************************************

*gen full_time=full_emp														///
*	if employed==1

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

gen asample=1
	
	replace asample=0 if missing(pta_categories)

	replace asample=0 if ridageyr<25 | ridageyr>65 | ridageyr==.

	replace asample=0 if missing(age_grp)

	replace asample=0 if missing(labor_force)
	
	replace asample=0 if missing(edu_over20)
	
	replace asample=0 if missing(hsd010)
	
	replace asample=0 if missing(married)	
	
	replace asample=0 if missing(female)
	
	replace asample=0 if missing(race)	
	
	
	tab asample

/*
tab asample

    asample |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     91,353       90.17       90.17
          1 |      9,963        9.83      100.00
------------+-----------------------------------
      Total |    101,316      100.00
*/
	
recode occup (0 = 1)
		
********************************************************************************
********************************************************************************
*** Summary Statistics
********************************************************************************
********************************************************************************	

table1_mc if asample==1, by(pta_categories)									///
	vars(																	///
	ridageyr		contn %4.1f \											///
	female 			cat %4.1f \												///
	race			cat %4.1f \												///
	edu_over20		cat %4.1f \												///
	married			bin %4.1f \												///
	hsd010			contn %4.1f \											///
	dmdhhsiz		contn %4.1f \											///
	labor_force		cat	%4.1f \												///
	employed		cat	%4.1f \												///
	full_emp		cat %4.1f \												///
	hrs_week		contn %4.1f \											///
	occup			cat %4.1f )												///
	nospace onecol total(before) 											///
saving("Tables\1-TABLE1-SUMSTATS-COVARIATES-2022Mar07.xls", replace)	


svy, subpop(if asample==1 & labor_force==0 & ocq380!=2):					///
	tabulate ocq380 pta_categories
/*
********************************************************************************
*** Table 2 - LOGIT MODEL FOR THE PROBABILITY OF BEING IN THE LABOR FORCE		
********************************************************************************
	
global model1 					///
	i.pta_cat
	
global model2 					///
	${model1}					///
	c.ridageyr 					///
	c.age2						///
	i.female					///
	i.race
	
global model3 					///
	${model2}					///
	i.edu_over20				///
	i.married 					///
	c.hsd010					///
	c.dmdhhsiz 					///
	i.sddsrvyr	
*/

gen notlabor=labor_force

	recode notlabor (0 = 1) (1 = 0)

replace pta=pta/10

/*	
logit notlabor $model1 													///
	if asample==1, or											
eststo model1		


logit notlabor $model2 													///
	if asample==1, or											
eststo model2	
lfit, group(10) table

	
logit notlabor $model3 													///
	if asample==1 , or											
eststo model3		
lfit, group(10) table
	
#delimit ;

cap n estout * using Tables/Table2-LOGIT-LABOR-2022Mar07.xls,
			style(tab) label notype replace
			eform drop(_cons)
			cells("b(fmt(%10.2fc)) ci(fmt(%10.2fc)par)" "p(fmt(%10.3fc))")
			title(Summary Statistics by average cIMT levels (V1 to V4) )   
			collabels(none) eqlabels(none) mlabels(none) mgroups(none);

#delimit cr
cap n estimates clear


********************************************************************************
********************************************************************************
*** Table 3-1 - LOGIT MODEL FOR THE PROBABILITY OF BEING EMPLOYED		
********************************************************************************
********************************************************************************

logit employed $model1 													///
	if asample==1 , or											
eststo model1		
*lfit, group(10) table


logit employed $model2 													///
	if asample==1 , or											
eststo model2	
lfit, group(10) table

	
logit employed $model3 													///
	if asample==1 , or											
eststo model3		
lfit, group(10) table
	
#delimit ;

cap n estout * using Tables/Table3-1-LOGIT-EMPLOYED-2022Mar07.xls,
			style(tab) label notype replace
			eform drop(_cons)
			cells("b(fmt(%10.2fc)) ci(fmt(%10.2fc)par)" "p(fmt(%10.3fc))")
			title(Summary Statistics by average cIMT levels (V1 to V4) )   
			collabels(none) eqlabels(none) mlabels(none) mgroups(none);

#delimit cr
cap n estimates clear

********************************************************************************
********************************************************************************
*** Table 3-2 - LOGIT MODEL FOR THE PROBABILITY OF HAVING A FULL TIME EMPLOYMENT		
********************************************************************************
********************************************************************************

logit full_emp $model1 													///
	if asample==1 & employed==1, or											
eststo model1		
*lfit, group(10) table


logit full_emp $model2 													///
	if asample==1 & employed==1, or											
eststo model2	
lfit, group(10) table

	
logit full_emp $model3 													///
	if asample==1 & employed==1, or											
eststo model3		
lfit, group(10) table
	
#delimit ;

cap n estout * using Tables/Table3-2-LOGIT-FULL-EMPLOYED-2022Mar07.xls,
			style(tab) label notype replace
			eform drop(_cons)
			cells("b(fmt(%10.2fc)) ci(fmt(%10.2fc)par)" "p(fmt(%10.3fc))")
			title(Summary Statistics by average cIMT levels (V1 to V4) )   
			collabels(none) eqlabels(none) mlabels(none) mgroups(none);

#delimit cr
cap n estimates clear


********************************************************************************
********************************************************************************
*** Table S1 - WGT LOGIT MODEL FOR THE PROBABILITY OF BEING IN THE LABOR FORCE
********************************************************************************
********************************************************************************

svy, subpop(asample): logit notlabor $model1											
eststo model1		
*lfit, group(10) table


svy, subpop(asample): logistic notlabor $model2					
eststo model2	
*lfit, group(10) table

	
svy, subpop(asample): logistic notlabor $model3					
eststo model3		
*lfit, group(10) table

#delimit ;

cap n estout * using Tables/TableS1-LOGIT-LABOR-WGT-2022Mar07.xls,
			style(tab) label notype replace
			eform drop(_cons)
			cells("b(fmt(%10.2fc)) ci(fmt(%10.2fc)par)" "p(fmt(%10.3fc))")
			title(Summary Statistics by average cIMT levels (V1 to V4) )   
			collabels(none) eqlabels(none) mlabels(none) mgroups(none);
#delimit cr
cap n estimates clear

********************************************************************************
********************************************************************************
*** Table S2-1 - LOGIT MODEL FOR THE PROBABILITY OF BEING EMPLOYED	
********************************************************************************
********************************************************************************

svy, subpop(if asample==1): logit employed $model1											
eststo model1		
*lfit, group(10) table


svy, subpop(if asample==1): logit employed  $model2					
eststo model2	
*lfit, group(10) table

	
svy, subpop(if asample==1): logit employed $model3					
eststo model3		
*lfit, group(10) table

#delimit ;

cap n estout * using Tables/TableS2-1-LOGIT-EMPLOYED-WGT-2022Mar07.xls,
			style(tab) label notype replace
			eform drop(_cons)
			cells("b(fmt(%10.2fc)) ci(fmt(%10.2fc)par)" "p(fmt(%10.3fc))")
			title(Weighted)   
			collabels(none) eqlabels(none) mlabels(none) mgroups(none);
#delimit cr
cap n estimates clear

********************************************************************************
********************************************************************************
*** Table S2-2 - LOGIT MODEL FOR THE PROBABILITY OF BEING EMPLOYED	
********************************************************************************
********************************************************************************

svy, subpop(if asample==1 & employed==1): logit full_emp $model1											
eststo model1		
*lfit, group(10) table


svy, subpop(if asample==1 & employed==1): logit full_emp  $model2					
eststo model2	
*lfit, group(10) table

	
svy, subpop(if asample==1 & employed==1): logit full_emp $model3					
eststo model3		
*lfit, group(10) table

#delimit ;

cap n estout * using Tables/TableS2-2-LOGIT-FULL-EMPLOYED-WGT-2022Mar07.xls,
			style(tab) label notype replace
			eform drop(_cons)
			cells("b(fmt(%10.2fc)) ci(fmt(%10.2fc)par)" "p(fmt(%10.3fc))")
			title(Weighted)   
			collabels(none) eqlabels(none) mlabels(none) mgroups(none);
#delimit cr
cap n estimates clear

********************************************************************************
********************************************************************************
*** Table S1 - WGT LOGIT MODEL FOR THE PROBABILITY OF BEING IN THE LABOR FORCE
********************************************************************************
********************************************************************************
*/

global model1 					///
	c.pta
	
global model2 					///
	${model1}					///
	c.ridageyr 					///
	c.age2						///
	i.female					///
	i.race
	
global model3 					///
	${model2}					///
	i.edu_over20				///
	i.married 					///
	c.hsd010					///
	c.dmdhhsiz 					///
	i.sddsrvyr	

	
svy, subpop(asample): logit notlabor $model1											
eststo model1		
*lfit, group(10) table


svy, subpop(asample): logistic notlabor $model2					
eststo model2	
*lfit, group(10) table

	
svy, subpop(asample): logistic notlabor $model3					
eststo model3		
*lfit, group(10) table

#delimit ;

cap n estout * using Tables/TableS1-LOGIT-LABOR-PTA-2022Mar07.xls,
			style(tab) label notype replace
			eform drop(_cons)
			cells("b(fmt(%10.2fc)) ci(fmt(%10.2fc)par)" "p(fmt(%10.3fc))")
			title(Summary Statistics by average cIMT levels (V1 to V4) )   
			collabels(none) eqlabels(none) mlabels(none) mgroups(none);
#delimit cr
cap n estimates clear
	
	
	
	
********************************************************************************
********************************************************************************
*** Table S3 - WGT LOGIT MODEL FOR THE PROBABILITY OF BEING IN THE LABOR FORCE
********************************************************************************
********************************************************************************

global model1 					///
	i.pta_cate					///
	i.htrouble
	
global model2 					///
	${model1}					///
	c.ridageyr 					///
	c.age2						///
	i.female					///
	i.race						///
	i.htrouble
	
global model3 					///
	${model2}					///
	i.edu_over20				///
	i.married 					///
	c.hsd010					///
	c.dmdhhsiz 					///
	i.sddsrvyr					///
	i.htrouble

	
svy, subpop(asample): logit notlabor $model1											
eststo model1		
*lfit, group(10) table


svy, subpop(asample): logit notlabor $model2					
eststo model2	
*lfit, group(10) table

	
svy, subpop(asample): logit notlabor $model3					
eststo model3		
*lfit, group(10) table

#delimit ;

cap n estout * using Tables/TableS3-LOGIT-LABOR-WGT-2021Sep13.xls,
			style(tab) label notype replace
			eform drop(_cons)
			cells("b(fmt(%10.2fc)) ci(fmt(%10.2fc)par)" "p(fmt(%10.3fc))")
			title(Summary Statistics by average cIMT levels (V1 to V4) )   
			collabels(none) eqlabels(none) mlabels(none) mgroups(none);
#delimit cr
cap n estimates clear

********************************************************************************
********************************************************************************
*** Table S3-1 - LOGIT MODEL FOR THE PROBABILITY OF BEING EMPLOYED	
********************************************************************************
********************************************************************************

svy, subpop(if asample==1): logit employed $model1											
eststo model1		
*lfit, group(10) table


svy, subpop(if asample==1): logit employed  $model2					
eststo model2	
*lfit, group(10) table

	
svy, subpop(if asample==1): logit employed $model3					
eststo model3		
*lfit, group(10) table

#delimit ;

cap n estout * using Tables/TableS3-1-LOGIT-EMPLOYED-WGT-2021Sep13.xls,
			style(tab) label notype replace
			eform drop(_cons)
			cells("b(fmt(%10.2fc)) ci(fmt(%10.2fc)par)" "p(fmt(%10.3fc))")
			title(Weighted)   
			collabels(none) eqlabels(none) mlabels(none) mgroups(none);
#delimit cr
cap n estimates clear

********************************************************************************
********************************************************************************
*** Table S3-1 - LOGIT MODEL FOR THE PROBABILITY OF BEING EMPLOYED	
********************************************************************************
********************************************************************************

svy, subpop(if asample==1 & employed==1): logit full_emp $model1											
eststo model1		
*lfit, group(10) table


svy, subpop(if asample==1 & employed==1): logit full_emp  $model2					
eststo model2	
*lfit, group(10) table

	
svy, subpop(if asample==1 & employed==1): logit full_emp $model3					
eststo model3		
*lfit, group(10) table

#delimit ;

cap n estout * using Tables/TableS3-2-LOGIT-FULL-EMPLOYED-WGT-2021Sep13.xls,
			style(tab) label notype replace
			eform drop(_cons)
			cells("b(fmt(%10.2fc)) ci(fmt(%10.2fc)par)" "p(fmt(%10.3fc))")
			title(Weighted)   
			collabels(none) eqlabels(none) mlabels(none) mgroups(none);
#delimit cr
cap n estimates clear
*/

svy, subpop(if asample==1 & notlabor==1): 									///
	tab ocq380 pta_cat, col

tab ocq380, gen(reason_)	


svy, subpop(if asample==1 & notlabor==1): 									///
	reg reason_1 i.pta_cat

svy, subpop(if asample==1 & notlabor==1): 									///
	reg reason_3 i.pta_cat	

svy, subpop(if asample==1 & notlabor==1): 									///
	reg reason_4 i.pta_cat		

svy, subpop(if asample==1 & notlabor==1): 									///
	reg reason_6 i.pta_cat	
	
/*

clear 

import excel 																///
	"Tables\Reasons-Bars.xlsx",	sheet("Sheet1") firstrow
	
destring umean, replace	

replace mean=round(mean,0.001)

gen mean_pc=mean*100
format mean_pc %9.1fc

twoway bar mean reasonx if reason==1, barw(.15) color(navy*.40) ||			///
	rcap lmean umean reasonx if reason==1, lcolor(navy)	||					///
	bar mean reasonx if reason==2, barw(.15) color(maroon*.40) ||			///
	rcap lmean umean reasonx if reason==2, lcolor(maroon) ||				///
	bar mean reasonx if reason==3, barw(.15) color(green*.40) ||			///
	rcap lmean umean reasonx if reason==3, lcolor(green) ||					///
	bar mean reasonx if reason==4, barw(.15) color(gold*.40) ||				///
	rcap lmean umean reasonx if reason==4, lcolor(gold) ||					///
	scatter mean reasonx if reason==1, msymbol(none) mlabel(mean_lbl)		///
		mlabposition(1)	mlabc(black) mlabs(small) ||						///
	scatter mean reasonx if reason==2, msymbol(none) mlabel(mean_lbl)		///
		mlabposition(1)	mlabc(black)  mlabs(small) ||						///
	scatter mean reasonx if reason==3, msymbol(none) mlabel(mean_lbl)		///
		mlabposition(1)	mlabc(black)  mlabs(small) ||						///
	scatter mean reasonx if reason==4, msymbol(none) mlabel(mean_lbl)		///
		mlabposition(1)	mlabc(black)  mlabs(small)							///
	xlabel(0.3 "No Hearing Loss" 1.3 "Mild HL" 2.3 "Moderate/Severe HL" 2.75 " ",		///
	labsize(small) notick)													///
	xtitle(" " "Hearing", size(small))										///
	legend( order(1 3 5 7) label(1 "Homemaker") label(3 "Retired")	 		///
		label(5 "Unable to work") label(7 "Disabled") rows(1) size(small))	///
	ytitle("Percentage Reported" " ", size(small)) 							///
	ylabel(0 "0" .2 "20" .4 "40" .6 "60", labsize(small)) 					///
	note("Pearson Chi2 < 0.001" "* p<0.001 for differences with respect to no HL group")
graph export "Graphs\Reason-Out-Labor-Force-2022Mar01.wmf", replace
