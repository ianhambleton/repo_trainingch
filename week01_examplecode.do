** HEADER -----------------------------------------------------
**  DO-FILE METADATA
//  algorithm name			week01_examplecode.do
//  project:				Exercise using Collapse and Reshape
//  analysts:				Ian HAMBLETON
//	date last modified		15-Aug-2018
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
cap log using "`logpath'\week01_examplecode", replace
** HEADER -----------------------------------------------------





** ************************************************************
** EXAMPLE DATASET 1
** ************************************************************
** LOAD the Meteorology dataset
use "`datapath'\dataset01_meteorology", clear

** Temporary datasets
tempfile met01 met02 met03 met04

** Widen so that each measure is a separate variable
** This will help as we collpase the data to weekly, monthly and quarterly summaries
reshape wide value, i(dov) j(measure)
rename value* (avt rh maxt mint rain)
label var avt "Average daily temperature (Celcius)"
label var rh "Relative humidity (%)"
label var maxt "Maximum daily temperature (Celcius)"
label var mint "Minumum daily temperature (Celcius)"
label var rain "Daily rainfall (mm)"
sort dov
** USEFUL EXTRA. Save variable labels for re-attaching after collapse commands
foreach v of var * {
    local l`v' : variable label `v'
        if `"`l`v''"' == "" {
            local l`v' "`v'"
	       }
       }
** Drop end of sequence (July-2013 and onwards - have no data yet)
drop if avt==. & rh==. & maxt==. & mint==. & rain==.
label data "Barbados daily meteorology data wide format: 2000 - 2013"
save `met01', replace

** Weekly summary
** Create running week variable
gen year = year(dov)
gen month = month(dov)

preserve
    gen woy = week(dov)
	label var woy "Week of year (1 to 52)"
	gen tweek = yw(year, woy)
	format tweek %tw
	collapse (mean) avt mint maxt rh (sum) wrain=rain, by(tweek)
	replace wrain = . if tweek<tw(2003w1)
	sort tweek
    foreach v of var * {
        label var `v' "`l`v''"
        }
    label var tweek "Rolling week code"
    label var wrain "Weekly rainfall total (mm)
    label data "Barbados weekly meteorology data wide format: 2000 - 2013"
	save `met02', replace
restore

** Monthly summary
preserve
	gen tmonth = ym(year, month)
	format tmonth %tm
	collapse (mean) avt mint maxt rh (sum) mrain=rain, by(tmonth)
	replace mrain = . if tmonth<tm(2003m1)
	sort tmonth
    foreach v of var * {
        label var `v' "`l`v''"
        }
    label var tmonth "Rolling month code"
    label var mrain "Monthly rainfall total (mm)
	label data "Barbados monthly meteorology data wide format: 2000 - 2013"
	save `met03', replace
restore

** Quarterly summary
preserve
	gen quarter = quarter(dov)
	label var quarter "Quarter of year (1 to 4)"
	gen tquarter = yq(year, quarter)
	format tquarter %tq
	collapse (mean) avt mint maxt rh (sum) qrain=rain, by(tquarter)
	replace qrain = . if tquarter<tq(2003q1)
	sort tquarter
    foreach v of var * {
        label var `v' "`l`v''"
        }
    label var tquarter "Rolling quarter code"
    label var qrain "Quarterly rainfall total (mm)
    label data "Barbados quarterly meteorology data wide format: 2000 - 2013"
	save `met04', replace
restore

** Tabulate and graph quarterly temperatures (minimally formatted graphic)
use `met04', clear
 tabstat avt mint maxt , by(tquarter) stat(mean) format(%9.1f)
#delimit ;
    gr twoway   (line  avt mint maxt tquarter,  lp("l" "-") lc(gs0 gs10 red%50))
                ,
                graphregion(color(gs16))
                ysize(1)
                xtitle("Quarter Year", size(5) margin(t=3))
                ytitle("Celcius", size(5))
                ylab(20(2)34) ytick(20(1)34)
                legend(position(11) order(3 1 2) cols(3)
                lab(3 "Av Max temperate")
                lab(1 "Av Temperature")
                lab(2 "Av Min Temperature"))
                name(temperature_quarter)
            ;
#delimit cr
/*

** Tabulate and graph monthly temperatures (minimally formatted graphic)
use `met03', clear
qui tabstat avt mint maxt , by(tmonth) stat(mean) format(%9.1f)
#delimit ;
    gr twoway   (line  avt mint maxt tmonth,  lp("l" "-") lc(gs0 gs10 red%50))
                ,
                graphregion(color(gs16))
                ysize(1)
                xtitle("Month", size(5) margin(t=3))
                ytitle("Celcius", size(5))
                ylab(20(2)34) ytick(20(1)34)
                legend(position(11) order(3 1 2) cols(3)
                lab(3 "Av Max temperate")
                lab(1 "Av Temperature")
                lab(2 "Av Min Temperature"))
                name(temperature_month)
            ;
#delimit cr


** Tabulate and graph weekly temperatures (minimally formatted graphic)
use `met02', clear
qui tabstat avt mint maxt , by(tweek) stat(mean) format(%9.1f)
#delimit ;
    gr twoway   (line  avt mint maxt tweek,  lp("l" "-") lc(gs0 gs10 red%50))
                ,
                graphregion(color(gs16))
                ysize(1)
                xtitle("Month", size(5) margin(t=3))
                ytitle("Celcius", size(5))
                ylab(20(2)34) ytick(20(1)34)
                legend(position(11) order(3 1 2) cols(3)
                lab(3 "Av Max temperate")
                lab(1 "Av Temperature")
                lab(2 "Av Min Temperature"))
                name(temperature_week)
            ;
#delimit cr





** ************************************************************
** EXAMPLE DATASET 2
** ************************************************************
** LOAD the Athsma dataset
use "`datapath'\dataset02_asthma", clear

** We have daily asthma admissions (1996-2005) and environmental conditions
** We want:
** (a) Number of annual paediatric events AND dust summary
** (b) Number of annual paediatric events BY SEX, AND rainfall/dust summaries
** (c) Look for admission variation by week (Sun to Sat) and by month (Jan to Dec)

tempfile asthma01 asthma02 asthma03 asthma04 asthma05 asthma06

** (A) Number of annual paediatric events AND dust summary
preserve
    collapse (sum) pa (mean) ydust=dust, by(yoa)
    save `asthma01', replace
    char yoa[varname] "Year"
    char pa[varname] "Paediatric admission"
    char ydust[varname] "African dust"
    format ydust %9.1f
    list yoa pa ydust, table div sep(5) noobs subvarname linesize(80) ab(20) mean(ydust) sum(pa)
restore

** (B) Number of annual paediatric events BY SEX, AND rainfall/dust summaries
**  Method 1
preserve
    collapse (sum) pam paf rain (mean) ydust=dust, by(yoa)
    list yoa pam paf rain ydust, table div sep(5) noobs subvarname linesize(80) ab(20)
    ** Wide format dataset
    save `asthma02', replace
    ** Long format dataset
    rename pa* pa#, renumber
    reshape long pa, i(yoa rain ydust) j(sex)
    label define sex_ 1 "men" 2 "women"
    label values sex sex_
    list yoa sex pa rain ydust, table div sep(2) noobs subvarname linesize(80) ab(20)
    save `asthma03', replace
restore

** (c) Look for admission variation by week (Sun to Sat)
preserve
    gen k=1
    collapse (sum) pa (count) cpa=pa (mean) meanpa=pa (sd) sdpa=pa (semean) sepa=pa, by(k)
    save `asthma04', replace
restore

collapse (sum) pa (count) cpa=pa (mean) meanpa=pa (sd) sdpa=pa (semean) sepa=pa, by(dow)
append using `asthma04'
gen pacl = meanpa-1.96*sepa
gen pacu = meanpa+1.96*sepa
** Graphical display of weekly difference
replace dow = dow+1
label define dow_ 1 "sunday" 2 "monday" 3 "tuesday" 4 "wednesday" 5 "thursday" 6 "friday" 7 "saturday"
label values dow dow_
** Overall average for graphic
gen weekav1 = meanpa if k==1
egen weekav = min(weekav1)
drop weekav1 k

#delimit ;
    gr twoway   (rcap pacl pacu dow, horiz lc(gs10))
                (sc dow meanpa, mc(gs0))
                (line dow weekav)
                ,
                graphregion(color(gs16))
                ysize(10) xsize(5)
                ytitle("")
                ylab(1(1)7, valuelab nogrid angle(0))
                yscale(reverse range(0.5(0.5)7.5))
                xtitle("Average admissions", margin(t=3))
                legend(position(11) order(2 1) cols(1)
                lab(2 "Average admissions")
                lab(1 "95% CI"))
                name(admission)
                ;
#delimit cr
