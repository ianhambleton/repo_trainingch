** HEADER -----------------------------------------------------
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
cap log using "`logpath'\week03_dataprep01", replace
** HEADER -----------------------------------------------------


** --------------------------------------
** WEEK 03
** _n, _N, and subscripting
** A short exerise making use of subscripting in stata
** --------------------------------------

** temp files
tempfile dataset1 dataset2 dataset3 dataset4
** Dataset 2
input score group
72 1
84 2
76 1
89 3
82 2
90 1
85 1
72 2
56 3
57 3
20 2
24 1
59 3
end
save `dataset1', replace


** DATASET 2
clear
input id score
117 72.1
204 84.2
311 76.6
289 79.3
141 82.7
277 60.0
465 66.2
289 78.3
182 84.5
167 78.2
183 54.4
205 67.9
204 68.1
345 55.2
673 55.1
56 53.8
87 68.8
64 69.5
465 66.2
276 58.3
189 84.6
164 96.4
182 84.5
205 89.9
234 88.1
36 55.2
683 45.1
45 93.8
23 58.8
64 89.5
end
save `dataset2', replace


** DATASET 3
clear
input id score m1 m2 m3 m4 m5 m6
117 72 3 16 42 7 59 61
204 84 6 12 44 9 51 66
141 82 2 17 41 5 56 61
311 76 9 14 46 1 58 62
289 89 4 13 48 3 55 68
141 82 2 17 41 5 56 61
277 90 3 12 44 6 52 65
465 85 5 19 43 2 54 64
289 88 7 18 45 4 58 69
182 84 1 11 47 7 52 61
141 90 4 13 43 4 51 65
end
save `dataset3', replace

** DATASET 4
clear
input year population mrate
1990	   34237274	234
1991	   34687425	245
1992	   35131662	243
1993	   35569279	254
1994	   35999964	256
1995	   36423237	249
1996	   36838907	278
1997	   37246271	265
1998	   37643880	252
1999	   38030111	270
2000	   38403986	243
2001	   38765019	225
2002	   39114069	234
2003	   39453535	232
2004	   39786576	221
2005	   40115790	216
2006	   40441529	224
2007	   40763754	211
2008	   41083981	213
2009	   41403983	201
2010	   41724731	213
2011	   42047196	190
2012	   42370627	201
2013	   42691676	194
2014	   43005785	187
2015	   43309611	190
2016	   43601839	188
2017	   43883319	189
2018	   44155323	179
end
save `dataset4', replace


** ANALYSES

** ----------------------------------
** PART 1. Using *DATASET 1*, do the following:<br/>
** ----------------------------------
use `dataset1', clear
**    Keeping the data entry order, generate a unique identifier for this dataset.
gen id = _n
order id, first
**    Create a second indicator, representing scores from highest to lowest
gsort -score
gen id2 = _n
order id2, after(id)
**    Generate a new variable (called `ntot`) containing the total number of observations
gen ntot = _N
order ntot, last
**   Create two more variables.
**        The first is an indicator, representing highest to lowest score *in each group*
gsort group -score
by group: gen idg = _n
order idg, after(id2)
**   Create two more variables.
**        The second is a variable containing the number of observations *in each group*
by group: gen ntotg = _N
order ntotg, after(ntot)



** ----------------------------------
** PART 2. Using *DATASET 2*, do the following:<br/>
** ----------------------------------
use `dataset2', clear
**    Using 1 line of code, detect any duplicate records in this dataset.
sort id
list if id == id[_n + 1], sep(1) noobs

** Create a new variable called dup, with the following categories:
**    dup = 0 No duplicates
**    dup = 1 Duplicate and score different
**    dup = 2 Duplicate and score the same
sort id
gen dup = 0
replace dup = 1 if id==id[_n+1] & score!=score[_n+1]
replace dup = 2 if id==id[_n+1] & score==score[_n+1]
label define dup_ 0 "not dup" 1 "dup / score diff" 2 "dup /score same"
label values dup dup_



** ----------------------------------
** PART 3. Using *DATASET 3*, do the following:<br/>
** ----------------------------------
use `dataset3', clear
sort id score m1 m2 m3 m4 m5 m6
by id score m1 m2 m3 m4 m5 m6: generate n1 = _N
list if n1>1
** OR...
bysort * : generate n2 = _N
list if n2>1

gen ndup = .
replace ndup = 1 if n2>1



** ----------------------------------
** PART 4. Using *DATASET 4*, do the following:<br/>
** ----------------------------------
use `dataset4', clear
** Format population size view
format population %12.0fc

** Calculate the difference between the population in each year and the population 5-years before
gen pdiff5 = population - population[_n-5]
** Calculate a 3-year rolling average mortality rate
gen rav3 = (mrate[_n-1] + mrate + mrate[_n+1]) / 3
** calculate a 5-year rolling average mortality rate
gen rav5 = (mrate[_n-2] + mrate[_n-1] + mrate + mrate[_n+1] + mrate[_n+2]) / 5

** Plot Mortality rate by YEAR, with rolling average overlay
#delimit ;
    gr twoway   (line  rav3 year,  lp("-") lc(blue%50))
                (line  rav5 year,  lp("-") lc(green%50))
                (sc mrate year,  mc(gs10) m(oh))
                ,
                graphregion(color(gs16))
                ysize(5) xsize(10)
                xtitle("Mortality Rate", size(4) margin(t=3))
                xlab(1990(5)2015) xtick(1990(1)2018)
                ytitle("Year", size(4))
                ylab(180(20)280) ytick(180(10)280)
                legend(position(11) order(3 1 2) cols(3)
                lab(1 "3-year average")
                lab(2 "5-year average")
                lab(3 "Mortality Rate"))
                name(mortality)
            ;
#delimit cr
