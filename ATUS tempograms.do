* Author: Kamila Kolpashnikova (kamila.kolpashnikova@sociology.ox.ac.uk)
* Date: August 2020
* for this demonstration
* I use the American Time Use Survey 2003-2018
* publicly available for downloading from BLS website:
* https://www.bls.gov/tus/datafiles-0318.htm
* I use two files from ATUS:
* atusact0318
* https://www.bls.gov/tus/special.requests/atusact-0318.zip
* and 
* atussum0318
* https://www.bls.gov/tus/special.requests/atussum-0318.zip
* (for weekday and year information)
* before you use this code, compile .dta files using BLS compilers in the links 
* above and save both of them as .dta extension files


use "/Users/kamilakolpashnikova/OneDrive - Nexus365/Data files/ATUS 2018/atusact0318.dta", clear

*** 1. use a new variable called ID for tucsaseid 
gen ID = tucaseid

*** sort by ID and the diary activity number
sort ID tuactivity_n


*** 2. create the minutes when the activity starts (start) and finishes (stop) 
*** using duration variable and the sequence number of the activity

gen start= .

replace start = 0 if tuactivity_n==1

gen stop = .

replace stop = tuactdur24 if tuactivity_n==1

sum tuactivity_n

forvalues i = 1/`r(max)' {
	by ID: replace start = stop[_n-1] if start==.
	by ID: replace stop = start+tuactdur24 if stop==.
}


*** 3. combine activity codes into larger groups:

gen Activity = .
*1 - sleep
replace Activity = 1 if trtier2p==101
*2 - personal care
replace Activity =2 if trtier2p==102|trtier2p==103|trtier2p==105|trtier2p==199
*3 - sex
replace Activity =3 if trtier2p==104

*4 - housework
replace Activity = 4 if trtier1p==2

*5 - child care
replace Activity = 5 if trtier2p==301 | trtier2p==302 | trtier2p==303 ///
	|trtier2p==401|trtier2p==402|trtier2p==403

*6 - adult care
replace Activity = 6 if trtier2p==304 | trtier2p==305 | trtier2p==399 ///
	|trtier2p==404|trtier2p==405|trtier2p==499

*7 - work
replace Activity = 7 if trtier1p==5

*8 - education
replace Activity = 8  if trtier1p==6

*9 - shopping
replace Activity = 9  if trtier1p==7

*10 - services
replace Activity = 10  if trtier1p==8|trtier1p==9|trtier1p==10

*11 - eating
replace Activity = 11  if trtier1p==11

*12 - leisure
replace Activity = 12  if (trtier1p==12|trtier1p==13|trtier1p==14|trtier1p==15 ///
	|trtier1p==16) & (trcodep!=120303 |trcodep!=120304)

*13 - travel
replace Activity = 13  if trtier1p==18

*14 - other
replace Activity = 14  if trtier1p==50

*15 - TV
replace Activity =15 if trcodep==120303 |trcodep==120304


*** 4. keep only the variables that will be needed for the next steps
keep tucaseid ID tuactivity_n Activity start tuactdur24 


*** 5. create the number of observations 1440 for each ID 
*** by expanding the duration variable 
*** the resulting number of observarions should be 289,657,440‬

expand tuactdur24

*** 6. create the minutes identifier by ID
sort ID tuactivity_n start
by ID: gen time = _n


*** 7. keep only ID, time, and activity variables

keep ID time Activity


********************************************************************************
***       ##      ##    ###    ########  ##    ## #### ##    ##  ######      ***   
***       ##  ##  ##   ## ##   ##     ## ###   ##  ##  ###   ## ##    ##     ***
***       ##  ##  ##  ##   ##  ##     ## ####  ##  ##  ####  ## ##           ***
***       ##  ##  ## ##     ## ########  ## ## ##  ##  ## ## ## ##   ####    ***
***       ##  ##  ## ######### ##   ##   ##  ####  ##  ##  #### ##    ##     ***
***       ##  ##  ## ##     ## ##    ##  ##   ###  ##  ##   ### ##    ##     ***
***        ###  ###  ##     ## ##     ## ##    ## #### ##    ##  ######      ***
********************************************************************************  
 
*** 8. reshape wide and save
*** WARNING: the line below will take a very long time, up to an entire day, depending on the laptop

reshape wide Activity, i(ID) j(time)

*** the reshaping will take a very long time 
*** it took on Windows laptop (Intel Core i5, 16GB RAM) - 15 hours,
*** on MacBook Pro (8-Core Intel Core i9, 64GB DDR4) - 6 hours

save "/Users/kamilakolpashnikova/OneDrive - Nexus365/Data files/ATUS 2018/ATUS 0318 sequences.dta", replace


**********************************************************************************************
******** use only this part to make tempograms
**********************************************************************************************

use "/Users/kamilakolpashnikova/OneDrive - Nexus365/Data files/ATUS 2018/ATUS 0318 sequences.dta", clear

lab def Activity 1 "Sleep" ///
	2 "Personal Care" ///
	3 "Sex" ///
	4 "Housework" ///
	5 "Child Care" ///
	6 "Adult Care" ///
	7 "Work" ///
	8 "Education" ///
	9 "Shopping" ///
	10 "Services" ///
	11 "Eating" ///
	12 "Leisure" ///
	13 "Travel" ///
	14 "Other" ///
	15 "TV"
	
forval i = 1/1440{
lab val Activity`i' Activity
}

save "/Users/kamilakolpashnikova/OneDrive - Nexus365/Data files/ATUS 2018/ATUS 0318 sequences.dta", replace


use "/Users/kamilakolpashnikova/OneDrive - Nexus365/Data files/ATUS 2018/atussum_0318.dta", clear

gen Year = tuyear
gen ID = tucaseid

gen Weekday = tudiaryday-1
recode Weekday (0=7) 

keep tucaseid ID Year Weekday

save "/Users/kamilakolpashnikova/OneDrive - Nexus365/Data files/ATUS 2018/ATUS 0318 years.dta", replace

use "/Users/kamilakolpashnikova/OneDrive - Nexus365/Data files/ATUS 2018/ATUS 0318 years.dta", clear

merge 1:1 ID using "/Users/kamilakolpashnikova/OneDrive - Nexus365/Data files/ATUS 2018/ATUS 0318 sequences.dta", update

drop _merge

recode Weekday (1/5=0)(6/7=1), gen(Weekend)

save "/Users/kamilakolpashnikova/OneDrive - Nexus365/Data files/ATUS 2018/ATUS 0318 sequences and vars.dta", replace




clear
cd "/Users/kamilakolpashnikova/Documents"
save temp, replace emptyok 


forvalues i = 1(1)1440 {
  use "/Users/kamilakolpashnikova/OneDrive - Nexus365/Data files/ATUS 2018/ATUS 0318 sequences and vars.dta", clear
  cd "/Users/kamilakolpashnikova/Documents"
  quietly tab Activity`i', matcell(a)
  svmat double a
  keep a1
  keep in 1/15
  rename a1 a
  append using temp
  save temp, replace
 }

use temp, clear
recode a (.=0)



************************************************************************
*** working with the resulting table
************************************************************************
ssc install seq
seq b, f(1) t(15)
seq x1, f(1440) t(1) b(15)

order b x1 a
 
reshape wide a, i(x1) j(b)

****sxpose, clear force

****destring _var*, replace

**** export delimited using "/Users/kamilakolpashnikova/OneDrive - Nexus365/Data files/ATUS 2018/dataInCsvATUS.csv", novarnames replace

**** from here you transform them into json or ttus

**** dealing with labels



forval i = 0(1)23 {
	local a = `i'*60+1
	label def tod `a' "`i':00", modify
}

forval i = 0(1)23 {
	local a = `i'*60+11
	label def tod `a' "`i':10", modify
}

forval i = 0(1)23 {
	local a = `i'*60+21
	label def tod `a' "`i':20", modify
}

forval i = 0(1)23 {
	local a = `i'*60+31
	label def tod `a' "`i':30", modify
}

forval i = 0(1)23 {
	local a = `i'*60+41
	label def tod `a' "`i':40", modify
}

forval i = 0(1)23 {
	local a = `i'*60+51
	label def tod `a' "`i':50", modify
}

label val x1 tod 


*********************************************************************
*** creating combined activities for area plot
*********************************************************************


gen sleep = a1
gen personal_care = sleep+a2
gen sex = personal_care + a3
gen eating = sex + a11
gen work = eating + a7
gen education = work + a8
gen housework = education + a4 
gen child_care = housework + a5
gen elder_care = child_care + a6

gen shopping = elder_care + a9
gen services = shopping + a10
gen leisure = services + a12
gen TV = leisure + a15
gen travel = TV + a13
gen other = travel + a14

	
graph twoway (area other travel ///
	TV leisure services shopping education ///
	work  elder_care child_care housework eating sex personal_care ///
	sleep x1), ///
	xlabel(1 "04:00 am" 250 "6:00 am" 370 "9:00 am" ///
	490 "12:00 pm" 670 "15:00 pm" 850 "18:00 pm" ///
	970 "20:00 pm" 1090 "22:00 pm", angle(90)) ///
	ylabel("") ///
	title(An Average Day of an American) ///
	ytitle () ///
	xtitle (time of the day) ///
	legend() scheme(economist)
	

graph twoway (area a1 x1, color(eltgreen) lcolor(black)), ///
	xlabel(1 "04:00 am" 250 "6:00 am" 370 "9:00 am" ///
	490 "12:00 pm" 670 "15:00 pm" 850 "18:00 pm" ///
	970 "20:00 pm" 1090 "22:00 pm" 1210 "00:00 am", angle(90)) ///
	ylabel(50288 "25%" 100576 "50%" 150863 "75%" 201151 "100%") ///
	title("American Sleeping Patterns") ///
	subtitle("ATUS'03-18") ///
	ytitle (% of population) ///
	xtitle (time of the day) ///
	legend() scheme(lean1)
	
	
graph twoway (area a6 x1, color(none) lcolor(black)) ///
	(area a5 x1, color(none) lcolor(black) lpattern(dash)), ///
	xlabel(1 "04:00 am" 250 "6:00 am" 370 "9:00 am" ///
	490 "12:00 pm" 670 "15:00 pm" 850 "18:00 pm" ///
	970 "20:00 pm" 1090 "22:00 pm" 1210 "00:00 am", angle(90)) ///
	ylabel(2000 "1%" 5000 "2.5%" 10000 "5%") ///
	title("Adultcare and Childcare in the US") ///
	ytitle (Proportion of Population) ///
	xtitle (time of the day) ///
	legend(label(1 "Adultcare") label(2 "Childcare")) scheme(lean2)
	
********************************************************************************
***** Tempograms using years information
********************************************************************************



clear
cd "/Users/kamilakolpashnikova/Documents"
save temp, replace emptyok 


forvalues i = 1(1)1440 {
  use "/Users/kamilakolpashnikova/OneDrive - Nexus365/Data files/ATUS 2018/ATUS 0318 sequences and vars.dta", clear
  cd "/Users/kamilakolpashnikova/Documents"
  quietly tab Activity`i' Year if Weekend==0, matcell(a)
  svmat double a
  keep a1-a16
  keep in 1/15
  append using temp
  save temp, replace
 }

use temp, clear
recode a* (.=0)



************************************************************************
*** working with the resulting table
************************************************************************
*ssc install seq
seq b, f(1) t(15)
seq x1, f(1440) t(1) b(15)

order b x1 a*

rename a1 year2003
rename a2 year2004
rename a3 year2005
rename a4 year2006
rename a5 year2007
rename a6 year2008
rename a7 year2009
rename a8 year2010
rename a9 year2011
rename a10 year2012
rename a11 year2013
rename a12 year2014
rename a13 year2015
rename a14 year2016
rename a15 year2017
rename a16 year2018

 
reshape wide year20**, i(x1) j(b)

**** dealing with labels



forval i = 0(1)23 {
	local a = `i'*60+1
	label def tod `a' "`i':00", modify
}

forval i = 0(1)23 {
	local a = `i'*60+11
	label def tod `a' "`i':10", modify
}

forval i = 0(1)23 {
	local a = `i'*60+21
	label def tod `a' "`i':20", modify
}

forval i = 0(1)23 {
	local a = `i'*60+31
	label def tod `a' "`i':30", modify
}

forval i = 0(1)23 {
	local a = `i'*60+41
	label def tod `a' "`i':40", modify
}

forval i = 0(1)23 {
	local a = `i'*60+51
	label def tod `a' "`i':50", modify
}

label val x1 tod 


*********************************************************************
*** creating combined activities for area plot
*********************************************************************


foreach i of numlist 2003(1)2018 {
 gen total_year`i' = year`i'1 + year`i'2 + year`i'3 +year`i'4 + year`i'5 + ///
 year`i'6 + year`i'7 + year`i'8 + year`i'9 + year`i'10 + year`i'11 + ///
 year`i'12 + year`i'13 + year`i'14 + year`i'15

}

foreach i of numlist 2003(1)2018 {
	 forval j = 1/15 {
	replace year`i'`j' = (year`i'`j'/total_year`i')*100
  }
}

	
	
graph twoway (area year20036 x1, color(none) lcolor(black)) ///
	(area year20046 x1, color(none) lcolor(gray)) ///
	(area year20056 x1, color(none) lcolor(gray)) ///
	(area year20066 x1, color(none) lcolor(gray)) ///
	(area year20076 x1, color(none) lcolor(gray)) ///
	(area year20086 x1, color(none) lcolor(gray)) ///
	(area year20096 x1, color(none) lcolor(gray)) ///
	(area year20106 x1, color(none) lcolor(gray)) ///
	(area year20116 x1, color(none) lcolor(gray)) ///
	(area year20126 x1, color(none) lcolor(gray)) ///
	(area year20136 x1, color(none) lcolor(gray)) ///
	(area year20146 x1, color(none) lcolor(gray)) ///
	(area year20156 x1, color(none) lcolor(gray)) ///
	(area year20166 x1, color(none) lcolor(gray)) ///
	(area year20176 x1, color(none) lcolor(gray)) ///
	(area year20186 x1, color(none) lcolor(red)) ///
	, ///
	xlabel(1 "04:00 am" 250 "6:00 am" 370 "9:00 am" ///
	490 "12:00 pm" 670 "15:00 pm" 850 "18:00 pm" ///
	970 "20:00 pm" 1090 "22:00 pm" 1210 "00:00 am", angle(90)) ///
	title("ATUS: Eldercare Time") ///
	ytitle (% of Population) ///
	xtitle (Time of the Day) ///
	legend(order(1 "2003" 2 "2004-2017" 16 "2018")) scheme(lean2)
	
	
/*

1 "Sleep" ///
	2 "Personal Care" ///
	3 "Sex" ///
	4 "Housework" ///
	5 "Child Care" ///
	6 "Adult Care" ///
	7 "Work" ///
	8 "Education" ///
	9 "Shopping" ///
	10 "Services" ///
	11 "Eating" ///
	12 "Leisure" ///
	13 "Travel" ///
	14 "Other" ///
	15 "TV"
*/
	
graph twoway ///
	(area year20044 x1, color(none) lcolor(gray) lpattern(dash)) ///
	(area year20054 x1, color(none) lcolor(gray) lpattern(dash)) ///
	(area year20064 x1, color(none) lcolor(gray) lpattern(dash)) ///
	(area year20074 x1, color(none) lcolor(gray) lpattern(dash)) ///
	(area year20084 x1, color(none) lcolor(gray) lpattern(dash)) ///
	(area year20094 x1, color(none) lcolor(gray) lpattern(dash)) ///
	(area year20104 x1, color(none) lcolor(gray) lpattern(dash)) ///
	(area year20114 x1, color(none) lcolor(gray) lpattern(dash)) ///
	(area year20124 x1, color(none) lcolor(gray) lpattern(dash)) ///
	(area year20134 x1, color(none) lcolor(gray) lpattern(dash)) ///
	(area year20144 x1, color(none) lcolor(gray) lpattern(dash)) ///
	(area year20154 x1, color(none) lcolor(gray) lpattern(dash)) ///
	(area year20164 x1, color(none) lcolor(gray) lpattern(dash)) ///
	(area year20174 x1, color(none) lcolor(gray) lpattern(dash)) ///
	(area year20034 x1, color(none) lcolor(black)) ///
	(area year20184 x1, color(none) lcolor(red)) ///
	, ///
	xlabel(1 "04:00 am" 250 "6:00 am" 370 "9:00 am" ///
	490 "12:00 pm" 670 "15:00 pm" 850 "18:00 pm" ///
	970 "20:00 pm" 1090 "22:00 pm" 1210 "00:00 am", angle(90)) ///
	yscale(r(0 21)) ///
	title("ATUS: Housework on Weekdays") ///
	ytitle (% of Population) ///
	xtitle (Time of the Day) ///
	legend(order(15 "2003" 2 "2004-2017" 16 "2018")) scheme(lean2)


