**  DO-FILE METADATA
//  algorithm name				week05CH.do
//  project:					Stata training week 5
//  analysts:					Christina HOWITT
//	date last modified		    20-Jun-2019
//  algorithm task:             Publication quality graphics 1

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
log using "`logpath'\week05_CH", replace

**----------------------------------------------------------------------------------------------------------------------------------------------------
** INSTRUCTIONS
** Using DATASET 5 (dataset05_healthdisparity.dta), re-create the following graphs. 
** Each graph plots values for the Standardized Theil index (STI) on the y-axis (measure = 3) against time period on the x-axis year.

**NOTE TO IAN: TYPO IN THE ABOVE DESCRIPTION. STI IS CODED AS '7' NOT '3' 
**----------------------------------------------------------------------------------------------------------------------------------------------------
use "`datapath'\dataset05_healthdisparity.dta", replace

numlabel, add mask("#",)
tab measure
tab type 

*Create Figure 1. Create a line graph of STI by year for the Caribbean sub-region
*CH notes: need a twoway graph, as both x and y axis are numeric; using the connected option, as aiming to show points and the line connecting them
graph twoway connected _le year if measure==7 & type==15, name(figure1)

*Create Figure 2. Add a line for Central America to the same graphic
graph twoway (connected _le year if measure==7 & type==15) (connected _le year if measure==7 & type==16), name(figure2)

*Create Figure 3. Now add a line for South America. Add commenting in your graph, and (for added readability) allow your graphics code for Figure 3 to run over several lines of text.

#delimit ; 

    graph twoway 
            (connected _le year if measure==7 & type==15) /// Caribbean
            (connected _le year if measure==7 & type==16) /// Central America
            (connected _le year if measure==7 & type==17) /// South America
            ,
            name(figure3)
            ;
#delimit cr 

*create figure 4 by formatting the x and y axes
#delimit ; 

    graph twoway 
            (connected _le year if measure==7 & type==15) /// Caribbean
            (connected _le year if measure==7 & type==16) /// Central America
            (connected _le year if measure==7 & type==17) /// South America
            ,
            /// Format x axis
            /// change label text and change angle of labels to 45 degrees
            xlab(1965 "1965-70" 1975 "1975-80" 1985 "1985-90" 1995 "1995-00" 2005 "2005-10", angle(45))
            /// change title 
            xtitle (Year)
            /// add ticks in between labelled years
            xmtick (1970(10)2000)

            /// Format y axis
            /// change label orientation
            ylab(0(20)80, labs(small) nogrid angle(0))
            /// change title. Can't work out how to move the title so it's not squished up next to the label (tried to make it better my making label text small)
            ytitle("STI disparity measure")           
            /// add ticks
            ytick (0(10)80) ymtick (5(10)75) 

            name(figure4)
            ;
#delimit cr 

*Figure 5: format legend
#delimit ; 

    graph twoway 
            (connected _le year if measure==7 & type==15) /// Caribbean
            (connected _le year if measure==7 & type==16) /// Central America
            (connected _le year if measure==7 & type==17) /// South America
            ,
            /// Format x axis
            /// change label text and change angle of labels to 45 degrees
            xlab(1965 "1965-70" 1975 "1975-80" 1985 "1985-90" 1995 "1995-00" 2005 "2005-10", angle(45))
            /// change title 
            xtitle (Year)
            /// add ticks in between labelled years
            xmtick (1970(10)2000)

            /// Format y axis
            /// change label orientation
            ylab(0(20)80, labs(small) nogrid angle(0))
            /// change title. Can't work out how to move the title so it's not squished up next to the label (tried to make it better my making label text small)
            ytitle("STI disparity measure")           
            /// add ticks
            ytick (0(10)80) ymtick (5(10)75) 

            /// format legend 
            /// change position and stack labels vertically. The colours of my lines are different - not sure why but as it doesn't make a difference, I will leave it
            legend (position(12) cols(1)
			lab(1 "Caribbean")
			lab(2 "Central America")
			lab(3 "South America") 
            )

            name(figure5)
            ;
#delimit cr 

*Figure 6: format graph region and plot region 
#delimit ; 

    graph twoway 
            (connected _le year if measure==7 & type==15) /// Caribbean
            (connected _le year if measure==7 & type==16) /// Central America
            (connected _le year if measure==7 & type==17) /// South America
            ,
            /// Format x axis
            /// change label text and change angle of labels to 45 degrees
            xlab(1965 "1965-70" 1975 "1975-80" 1985 "1985-90" 1995 "1995-00" 2005 "2005-10", angle(45))
            /// change title 
            xtitle (Year)
            /// add ticks in between labelled years
            xmtick (1970(10)2000)

            /// Format y axis
            /// change label orientation
            ylab(0(20)80, labs(small) nogrid angle(0))
            /// change title. Can't work out how to move the title so it's not squished up next to the label (tried to make it better my making label text small)
            ytitle("STI disparity measure")           
            /// add ticks
            ytick (0(10)80) ymtick (5(10)75) 

            /// format legend 
            /// change position and stack labels vertically. The colours of my lines are different - not sure why but as it doesn't make a difference, I will leave it
            legend (position(12) cols(1)
			lab(1 "Caribbean")
			lab(2 "Central America")
			lab(3 "South America") 
            )

            /// Graph region and plot region. 
            graphregion (c(gs16))
            ysize(6)
            


            name(figure6)
            ;
#delimit cr 



*Figure 7: format graph lines
#delimit ; 

    graph twoway 
            (connected _le year if measure==7 & type==15, lp("l") mc("26 81 60") lc("26 81 60")) /// Caribbean
            (connected _le year if measure==7 & type==16, lp("-") mc("85 209 161") lc("85 209 161")) /// Central America
            (connected _le year if measure==7 & type==17, lp("-") mc("110 155 138") lc("110 155 138")) /// South America
            ,
            /// Format x axis
            /// change label text and change angle of labels to 45 degrees
            xlab(1965 "1965-70" 1975 "1975-80" 1985 "1985-90" 1995 "1995-00" 2005 "2005-10", angle(45))
            /// change title 
            xtitle (Year)
            /// add ticks in between labelled years
            xmtick (1970(10)2000)

            /// Format y axis
            /// change label orientation
            ylab(0(20)80, labs(small) nogrid angle(0))
            /// change title. Can't work out how to move the title so it's not squished up next to the label (tried to make it better by making label text small)
            ytitle("STI disparity measure")           
            /// add ticks
            ytick (0(10)80) ymtick (5(10)75) 

            /// format legend 
            /// change position and stack labels vertically. The colours of my lines are different - not sure why but as it doesn't make a difference, I will leave it
            legend (position(12) cols(1)
			lab(1 "Caribbean")
			lab(2 "Central America")
			lab(3 "South America") 
            )

            /// Graph region and plot region. 
            graphregion (c(gs16))
            ysize(7.5)
            


            name(figure7)
            ;
#delimit cr 

