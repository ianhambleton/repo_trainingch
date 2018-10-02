**  DO-FILE METADATA
//  algorithm name				week02CH.do
//  project:							Stata training week 2
//  analysts:							Christina HOWITT
//	date last modified		20-Sep-2018
//  algorithm task:       Append and merge

** General algorithm set-up
version 15
clear all
macro drop _all
set more 1
set linesize 80

** Set working directories: this is for DATASET and LOGFILE import and export
** DATASETS to encrypted SharePoint folder
local datapath "X:\The University of the West Indies\DataGroup - repo_data\data_statatraining"
** LOGFILES to unencrypted OneDrive folder
local logpath "X:\OneDrive - The University of the West Indies\repo_trainingch"

** Close any open log fileand open a new log file
capture log close
log using "`logpath'\week02_CH", replace

** -----------------------------------------------------------------------------
** INSTRUCTIONS
** 1. Data preparation
** -----------------------------------------------------------------------------
** JOIN ALL DATASETS TOGETHER IN A SINGLE JCS DATASET
** Look at all the datasets separately to see how they are structured in order to merge
** static1
use "`datapath'\dataset03_static1.dta", clear
distinct pid  // there are 56 participants, 1 row per participant
** static2
use "`datapath'\dataset03_static2.dta", clear
distinct pid // there are 29 participants, 1 row per participant
** static3
use "`datapath'\dataset03_static3.dta", clear
distinct pid // there are 17 participants, 1 row per participant
** haematological info
use "`datapath'\dataset03_haem.dta", clear
distinct pid // there are 177 participants, with multiple rows per participant (7092 in total)
** clinical info
use "`datapath'\dataset03_clin.dta", clear
distinct pid // there are 111 participants, with multiple rows per participant (4495 in total)

** -----------------------------------------------------------------------------
** CH notes: I want to end up with a dataset with 1 row per participant per
** time point. The static datasets contain different participants, so should be
** appended. The clin and haem datasets contain information on the participants
** in the static dataset, and will overlap in terms of participants and some visit dates.
** -----------------------------------------------------------------------------
tempfile allstatic_CH static_clin static_haem

** STEP 1: COMBINE STATIC DATASETS
** These datasets contain different participants, so should be appended
use "`datapath'\dataset03_static1.dta", clear
append using "`datapath'\dataset03_static2.dta" "`datapath'\dataset03_static3.dta"
save `allstatic_CH', replace


**STEP 2: COMBINE STATIC AND HAEMATOLOGICAL DATASETS
*merge static dataset with haematological dataset
use `allstatic_CH', clear
merge 1:m pid using "`datapath'\dataset03_haem.dta"
/*
Result                           # of obs.
   -----------------------------------------
   not matched                         3,259
       from master                         0  (_merge==1)
       from using                      3,259  (_merge==2)

   matched                             3,833  (_merge==3)
   -----------------------------------------
*/

*look at characteristics of participants that exist in the haematological dataset but not static
distinct pid if _merge==2 // 75 participants (3259 observations). Dropping these ones on the assumption that if they were not in the static dataset,
                         // they aren't part of the cohort. Although that seems weird so should probably check that assumption.
drop if _merge==2
rename _merge merge_stathaem

save `static_haem', replace

* STEP 3: COMBINE STATIC AND CLINICAL DATASETS
** the clinical dataset contain information on the participants already in the static dataset, so should be merged
use `allstatic_CH', clear
merge 1:m pid using "`datapath'\dataset03_clin.dta"

/* merge results as follows:

    Result                           # of obs.
    -----------------------------------------
    not matched                         2,358
        from master                        49  (_merge==1)
        from using                      2,309  (_merge==2)

    matched                             2,186  (_merge==3)
    -----------------------------------------  */

*Look at characteristics of 49 participants that exist in static dataset but not clinical
list pid geno status if _merge==1 // they are all genotype aa (controls),so won't have had a clinic visit. Can be dropped from this dataset.
drop if _merge==1
*look at characteristics of participants that exist in the clinical dataset but not static
distinct pid if _merge==2 // 58 participants (2309 observations). Using the same rationale as for previous merge, will drop these ones.
drop if _merge==2

rename _merge merge_statclin
save `static_clin', replace

* STEP 4: MERGE THE STATIC/HAEMATOLOGICAL AND STATIC/CLINICAL DATASETS
merge m:m pid dov using `static_haem'
rename _merge merge_all
sort pid dov
order merge_stathaem merge_statclin, after(merge_all)

** -----------------------------------------------------------------------------
** Q: Record the number of participants, and the number of observations
** -----------------------------------------------------------------------------
distinct pid // there are 102 participants with 4607 observations

** -----------------------------------------------------------------------------
** Q: Record the average number of haematological measurements per participant
** -----------------------------------------------------------------------------
* -----------------------------------------------------------------------------
** CH notes: I get that I should be using xt commands from here, but I am seriously
** confused, so doing it the long way.
** I tried the following:
** xtset pid dov
** Then tried to summarize the xtsum haemvis
** -----------------------------------------------------------------------------

* create a variable that describes the number of haematological measurements per visit
gen hb_meas = 0
replace hb_meas=1 if hb!=.
gen hbf_meas = 0
replace hbf_meas=1 if hbf !=.
gen nbc_meas = 0
replace nbc_meas=1 if hbf !=.
egen haem_meas= rowtotal (hb_meas hbf_meas nbc_meas)

* -----------------------------------------------------------------------------
** CH notes: I get that I should be using xt commands from here, but could not get
** it to work.
**-----------------------------------------------------------------------------
/* I tried the following:
   xtset pid dov
   Then tried to summarize the number of haem measurements:
   xtsum haem_meas
   But that's not what I want. Help!
*/
** so continuing without xt....
egen n_haemmeas = sum(haem_meas), by (pid)
order hb_meas hbf_meas nbc_meas haem_meas n_haemmeas, after(pid)

* average measurements per person
preserve
  duplicates drop pid, force
  tabstat n_haemmeas, stat(mean) // average number of measurements per person is 70.8
restore

** -----------------------------------------------------------------------------
** Q: Record the average number of clinical visits per participant
** -----------------------------------------------------------------------------
* create a variable that describes whether or not the visit was a clinical visit
gen clinvis = 0
replace clinvis=1 if tov!=.
order clinvis, after (tov)
codebook clinvis

* create a variable that counts the clinical visits per participant
egen n_clinvis = count(clinvis), by (pid)
order n_clinvis, after(clinvis)

* average visits per person
preserve
  duplicates drop pid, force
  tabstat n_clinvis, stat(mean) // average number of visits per participant is 45
restore

** -----------------------------------------------------------------------------
** INSTRUCTIONS
** 2. Among SS participants only:
** Report the average nucleated blood count (nbc) at steady state (clinical code y1),
** -----------------------------------------------------------------------------
* Set data as longitudinal
xtset pid dov
xtsum nbc if c==481 & geno==1  // mean nbc is 14.7
sum nbc if c==481 & geno==1

** -----------------------------------------------------------------------------
** Report the average nucleated blood count (nbc) during the acute chest syndrome (clinical code r5)
** -----------------------------------------------------------------------------
xtsum nbc if c==345 & geno==1 // mean nbc is 29.6

** -----------------------------------------------------------------------------
**Compare nbc at steady state with nbc during the acute chest syndrome
** -----------------------------------------------------------------------------
recode c 481=0 345=1
xtreg nbc c if geno==1
xtreg nbc c agey sex if geno==1
** Interpretation: after controlling for age and sex, nbc is on average 13.4 (units?) (95%CI: 12.2, 14.7) higher in those with SCD during acute chest syndrome
** vs steady state.
