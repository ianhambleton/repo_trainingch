* HEADER -----------------------------------------------------
**  DO-FILE METADATA
//  algorithm name			week02_examplecode.do
//  project:				Exercise using Merge and Append
//  analysts:				Ian HAMBLETON
//	date last modified		30-Aug-2018
//  algorithm task			Example code for the exercise

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
cap log using "`logpath'\week04_examplecode", replace
** HEADER -----------------------------------------------------

use "`datapath'\dataset04_ipv", clear

** ANALYSIS PART 1
** (A) Rename variables eb1, eb2, eb3, etc to strength01, strength02, strength03, etc
** (B) Rename variables ec1, ec2, ec3, etc to aggress01, aggress02, aggress03, etc
** (C) Label the three categories for all behavioural variables:
**        0 = not true at all
**        1 = somewhat true
**        2 = very true

** (A) / (B) Rename Questionnaire Variables
forval x = 1(1)31 {
    rename eb`x' strength`x'
}
forval x = 1(1)15 {
    rename ec`x' aggress`x'
}

** (A) / (B) ALTERNATIVE SOLUTION --> Rename Questionnaire Variables
** rename eb# strength#
** rename ec# aggress#

** (C) Label three categories
label define label_ 0 "not true at all" 1 "somewhat true" 2 "very true"
forval x = 1(1)31 {
    label values strength`x' label_
    cap label values aggress`x' label_
}



** ANALYSIS PART 2
** (A) Using a foreach loop, tab coi, sex, agey
local vars "coi sex agey"
foreach v in `vars' {
    tab `v'
}
qui levelsof coi, local(levels)
foreach l in `levels' {
    dis  _newline(3)
     dis "Country = `l'"   
     tabulate agey sex if coi == `l', row
}


** (B) Save SIX new temporary datasets, for each country-sex grouping
local xlab1 = "Jamaica"
local xlab2 = "Barbados"
local xlab3 = "Trinidad"
local ylab1 = "Females"
local ylab2 = "Males"
forval x=1(1)3 {
    forval y=1(1)2 {
        tempfile temp`y'_`x'
        preserve
            keep if coi==`x' & sex==`y'
            label data "Behaviour questionnaire:  `ylab`y'' from `xlab`x''"
            save  `temp`y'_`x''
        restore
    }
}

** As a proof of coding success, scroll through the SIX datasets
** looking at the data label
forval x = 1(1)3 {
    forval y = 1(1)2 {
        use `temp`y'_`x'', clear
    }
}

