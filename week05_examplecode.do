** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    week05_examplecode.do
    //  project:				    Stata training
    //  analysts:					Ian HAMBLETON
    // 	date last modified	        7-SEP-2018
    //  algorithm task			    Building a Publication Quality graphic in STAGES

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
    cap log using "`logpath'\week05_examplecode", replace
** HEADER -----------------------------------------------------

use "`datapath'\dataset05_healthdisparity.dta", replace



** GRAPHIC FOR STI
** MEASURE - measures of disparity (Generalised Measures of Entropy)
** MLD  = mean log deviation
** T    = Theil index
** STI  = Standardized Theil Index

** 1 -  Basic graph without formatting - Caribbean only
gr twoway (connect _le year if measure==3 & type==15),  name(figure1)

** 2 -  Add line for Central America to same graph
gr twoway (connect _le year if measure==3 & type==15) (connect _le year if measure==3 & type==16), name(figure2)


** 3 -  Add lines for Central & South America onto same graph. \
**      Add commenting and allow command to flow over several lines of text editor (for ease of reading)
#delimit ;   /* Semi-colon needed to end a command instead of a carriage return */
	gr twoway
          /// Central America
		  (connect _le year if measure==3 & type==16)
          /// Southern America
		  (connect _le year if measure==3 & type==17)
          /// Caribbean
		  (connect _le year if measure==3 & type==15)
          ,
          name(figure3)
          ;   /* Notice the semi-column to end the command now */
#delimit cr

** 4 -  Format X and Y AXES
**          xlab() / ylab()
**          xtitle() / ytitle()
**          xtick() / ytick()
#delimit ;
	gr twoway
		  (connect _le year if measure==3 & type==16)
		  (connect _le year if measure==3 & type==17)
		  (connect _le year if measure==3 & type==15)
		  ,
			/// X-AXIS FORMATTING
			/// Add readable x-axis text, set text size as medium, set text 45 degree angle, set grid off
			xlab(1965 "1965-70" 1975 "1975-80" 1985 "1985-90" 1995 "1995-00" 2005 "2005-10", labs(medium) nogrid angle(45))
			/// Add x-axis title
			xtitle("Year", margin(t=3) size(medlarge))
			/// Add ticks between labels
			xmtick(1965(5)2010)

			/// Y-AXIS FORMATTING
			ylab(0(20)80, labs(medium) nogrid glc(gs14) angle(0) format(%9.0f))
			ytitle("STI disparity measure", margin(r=3) size(medlarge))
			/// Add major and minor ticks between labels
			ytick(0(10)80) ymtick(0(5)80)
            name(figure4)
			;
#delimit cr


** 5 -  Format LEGEND
**          legend()
**          Important sub-options...
**              position()
**              cols()
**              order()
**              lab()
#delimit ;
	gr twoway
		  (connect _le year if measure==3 & type==16)
		  (connect _le year if measure==3 & type==17)
		  (connect _le year if measure==3 & type==15)
		  ,
			xlab(1965 "1965-70" 1975 "1975-80" 1985 "1985-90" 1995 "1995-00" 2005 "2005-10", labs(medium) nogrid angle(45))
			xtitle("Year", margin(t=3) size(medlarge))
			xmtick(1965(5)2010)

			ylab(0(20)80, labs(medium) nogrid glc(gs14) angle(0) format(%9.0f))
			ytitle("STI disparity measure", margin(r=3) size(medlarge))
			ytick(0(10)80) ymtick(0(5)80)

			/// FORMAT LEGEND
			// Legend position is 12 o'clock, legend as a single column, medium text size
			legend(size(medium) position(12) bm(t=1 b=0 l=0 r=0) colf cols(1)
			/// Legend color is white, order text with 3rd command first (so Caribbean first)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) order(3 1 2)
			lab(1 "Central America")
			lab(2 "Southern America")
			lab(3 "Caribbean")
			)
            name(figure5)
            ;
#delimit cr


** 6 -  Format GRAPH region (colour of graph background, overall graph shape)
**          plotregion()
**          graphregion()
**          ysize() / xsize()
#delimit ;
	gr twoway
		  (connect _le year if measure==3 & type==16)
		  (connect _le year if measure==3 & type==17)
		  (connect _le year if measure==3 & type==15)
		  ,
			/// Plotregion colors always white (gs16)
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
			/// Graphregion colors always white (gs16)
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			/// Shape of graph Y-axis = 7 (larger values for Y make y-axis longer relative to x-axis
			ysize(7)

			xlab(1965 "1965-70" 1975 "1975-80" 1985 "1985-90" 1995 "1995-00" 2005 "2005-10", labs(medium) nogrid angle(45))
			xtitle("Year", margin(t=3) size(medlarge))
			xmtick(1965(5)2010)

			ylab(0(20)80, labs(medium) nogrid glc(gs14) angle(0) format(%9.0f))
			ytitle("STI disparity measure", margin(r=3) size(medlarge))
			ytick(0(10)80) ymtick(0(5)80)

			legend(size(medium) position(12) bm(t=1 b=0 l=0 r=0) colf cols(1)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) order(3 1 2)
			lab(1 "Central America")
			lab(2 "Southern America")
			lab(3 "Caribbean")
			)
            name(figure6)
			;
#delimit cr


**  7 - Format the graph LINES
**          lwidth()
**          lcolor()
**          msize()
**          mcolor()
**          Sizes generally - get greater control by moving from Stata standards (vthin, thin, medium etc)
**          To sizes determined as % of full graphic size (0.5, 1, 2, 3, 4, etc)
**
**          Get RGB color scheme from colorbrewer.org
#delimit ;
	gr twoway
		  /// lw=line width, msize=symbol size, mc=symbol colour, lc=line color
		  /// Colours use RGB system
		  (connect _le year if measure==3 & type==16, lp("-") lw(0.5) msize(1.5) mc("116 196 118") lc("116 196 118"))
		  (connect _le year if measure==3 & type==17, lp("-") lw(0.5) msize(1.5) mc("186 228 179") lc("186 228 179"))
		  (connect _le year if measure==3 & type==15, lp("l") lw(0.5) msize(1.5) mc("0 109 44") lc("0 109 44"))
		  ,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ysize(7)

			xlab(1965 "1965-70" 1975 "1975-80" 1985 "1985-90" 1995 "1995-00" 2005 "2005-10", labs(3) nogrid angle(45))
			xtitle("Year", margin(t=3) size(3.5))
			xmtick(1965(5)2010)

			ylab(0(20)80, labs(3) nogrid glc(gs14) angle(0) format(%9.0f))
			ytitle("STI disparity measure", margin(r=3) size(3.5))
			ytick(0(10)80) ymtick(0(5)80)

			legend(size(3) position(12) bm(t=1 b=0 l=0 r=0) colf cols(1)
			region(fcolor(gs16) lw(0.1) margin(l=2 r=2 t=2 b=2))
            order(3 1 2)
			lab(1 "Central America")
			lab(2 "Southern America")
			lab(3 "Caribbean")
            )
            name(figure7)
            ;
#delimit cr
