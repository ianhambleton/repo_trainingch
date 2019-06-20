**  DO-FILE METADATA
//  algorithm name				week04CH.do
//  project:					Stata training week 4
//  analysts:					Christina HOWITT
//	date last modified		    20-Jun-2019
//  algorithm task:             Local Macros, ForValues, ForEach

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
log using "`logpath'\week04_CH", replace

** -----------------------------------------------------------------------------
** INSTRUCTIONS
** 1. Using DATASET 4 (dataset04_ipv.dta), do the following:
** -----------------------------------------------------------------------------
**Rename variables eb1, eb2, eb3, etc to strength01, strength02, strength03, etc
use "`datapath'\dataset04_ipv.dta", clear 

forvalues x = 1(1)9 {
    rename eb`x' strength0`x'
} 

forvalues x = 10(1)31 {
    rename eb`x' strength`x'
}

*Rename variables ec1, ec2, ec3, etc to aggress01, aggress02, aggress03, etc
forvalues x = 1(1)9 {
    rename ec`x' aggress0`x'
}

forvalues x = 10(1)15 {
    rename ec`x' aggress`x'
}

**Label the three categories for all behavioural variables:
**      0 = not true at all
**      1 = somewhat true
**      2 = very true

label define behav 0 "not true at all" 1 "somewhat true" 2 "very true"

*use macro to define behavioural variables, then apply label using a loop 
local var strength* aggress*

foreach x in `var' { 
    label values `x' behav
}

** -----------------------------------------------------------------------------
** INSTRUCTIONS
**  Using DATASET 4 (dataset04_ipv.dta), do the following:
**  Using a foreach loop, tabulate coi, sex, and agey
** -----------------------------------------------------------------------------

local var2 coi sex agey
foreach x in `var2' {
    tab `x'
}

*Using a foreach loop, provide a twoway tabulation of age and sex for each country
*NOT A CLUE HOW TO DO THIS


**Using forvalue loops Save SIX new datasets, for each country-sex grouping
**  Include a suitable dataset label for each saved dataset

*NOT A CLUE HOW TO DO THIS ONE EITHER
