** HEADER -----------------------------------------------------
**  DO-FILE METADATA
//  algorithm name			    week02_examplecode.do
//  project:				        Ipolate missing data
//  analysts:						    Ian HAMBLETON
//	date last modified	    28-Aug-2018
//  algorithm task			    Week 02 Stata training - Hambleton example code

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
local logpath X:\OneDrive - The University of the West Indies\repo_datagroup\repo_trainingch

** Close any open log fileand open a new log file
capture log close
cap log using "`logpath'\week02_examplecode", replace
** HEADER -----------------------------------------------------

** We have the following DATASETS
** STATIC DATA      --> THREE files
** HAEM DATA        --> Hb, HbF, NBC, in a single file
** CLINICAL DATA    --> Y1, D5, R5 events in a single file

** Temporary datasets
tempfile static static_haem all

** --------------------------------------------------------
** 1. DATA PREPARATION
** - Join all the datasets into a single JCS dataset
** - Describe what records were dropped whilst joining datasets, and why
** - Record the number of participants, and the number of observations,
** - Record the average number of haematological measurements per participants
** - Record the average number of clinical visits per person
** --------------------------------------------------------

** Append the THREE static files - documenting any problems
use "`datapath'\dataset03_static1", clear
append using "`datapath'\dataset03_static2"
append using "`datapath'\dataset03_static3"
save `static', replace

** Brief review of the variables
list in 1/5
codebook, compact
misstable sum

** Brief review of haematology
use "`datapath'\dataset03_haem", clear
list in 1/5
codebook, compact
misstable sum

** Brief review of clnical events
use "`datapath'\dataset03_clin", clear
list in 1/5
codebook, compact
misstable sum

** Merge STATIC with HAEMATOLOGY
use `static', clear
merge 1:m pid using "`datapath'\dataset03_haem"
rename _merge haem_merge
label define haem_merge_ 1 "static only" 2 "haem only" 3 "both"
label values haem_merge haem_merge_
** We only want participants that were in STATIC file
keep if haem_merge==1 | haem_merge==3
save `static_haem', replace

** ANSWER
** Describe what records were dropped whilst joining datasets, and why
**      Dropped from Haematology data
**      _merge == 2 data were dropped.
**      N=3,259 data points dropped
**      Haematology associated with participants NOT in STATIC file

** Merge Resulting file with CLINICAL EVENTS
use `static_haem', clear
merge m:m pid dov using "`datapath'\dataset03_clin"
rename _merge clin_merge
label define clin_merge_ 1 "static_haem only" 2 "clin only" 3 "both"
label values clin_merge clin_merge_
** We only want participants that were in STATIC file
keep if clin_merge==1 | clin_merge==3
save `all', replace

** ANSWER
** Describe what records were dropped whilst joining datasets, and why
**      Dropped from Clinical data
**      _merge == 2 data were dropped.
**      N=3,083 data points dropped
**      Clinical events associated with participants NOT in STATIC file

** Record the number of participants, and the number of observations,
xtset pid dov

** Record the average number of haematological measurements per participants
preserve
    collapse (count) hb hbf nbc, by(geno pid)
    table geno, c(mean hb mean hbf mean nbc) format(%9.2f)
restore

** Record the average number of clinical visits per person
preserve
    gen y1 = 0
    replace y1 = 1 if c==481
    gen r5 = 0
    replace r5 = 1 if c==365
    collapse (count) y1c=y1 r5c=r5, by(pid c)
    table c, c(mean y1c mean r5c) format(%9.2f)
restore


** --------------------------------------------
** 2. ANALYSIS (SS only)
** - In SS, AVERAGE NBC during STEADY STATE (Y1)
** - In SS, AVERAGE NBC during ACUTE CHEST SYNDROME (R5)
** - In SS, COMPARE NBC between Y1 and R5 states
** --------------------------------------------
use `all', clear
keep if geno==1
keep if agey>=5
xtset pid dov
** In SS, AVERAGE NBC during Y1 and during R5
bysort geno: xtsum hb if c==481
bysort geno: xtsum hb if c==345
** In SS, COMPARE NBC between Y1 and R5 states
xtreg nbc ib481.c, re
