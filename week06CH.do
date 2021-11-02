**  DO-FILE METADATA
//  algorithm name				week06CH.do
//  project:					Stata training week 6
//  analysts:					Christina HOWITT
//	date last modified		    20-Jun-2019
//  algorithm task:             Posting data to an external file

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
log using "`logpath'\week06_CH", replace


use "`datapath'\dataset06_sabehealth.dta", replace

** -----------------------------------------------------------------------------
** INSTRUCTIONS
** Using DATASET 6 (dataset06_sabehealth.dta),
** Two-way tabulations of health and gender. Using the variable SEX, for each categorical variable that reports an aspect of health or nutrition, perform a 2-way tabulation and chi-squared test 
** (sex by health measure) in Stata. You should end up with 33 two-way tables and chi-squared tests.
** -----------------------------------------------------------------------------

local hmeas C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C13A C13B C13C C13D C13E C13F C13G C13H C13I C13J C13K C15 C16 C22A C22B C22C C22D C22E C22F C22G C22H C22I

foreach x in `hmeas'{
        tab `x' SEX, col chi 
}


