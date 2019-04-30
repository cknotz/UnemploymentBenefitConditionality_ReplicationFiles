

***********************************************************
* The Unemployment Benefit Conditions & Sanctions Dataset *
***********************************************************

* Author: Carlo Knotz

version 13.1

* These DoFiles do some necessary `data mangling'
*************************************************

do "https://www.dropbox.com/s/2b54skqdic12iwb/condsanc_xlstodta_18.do?dl=1" // reading Excel-spreadsheets into Stata

do "https://www.dropbox.com/s/nmdt6s17k44oipa/cond_dataprep_18.do?dl=1" // accounting for several complexities in benefit conditions & sanctions in various countries


* This Dofile generates the aggregate indicators on benefit conditionality
**************************************************************************
	
* Merging with CWED2 (Scruggs, Jahn, Kuitto)
sort country year
	merge 1:1 country year using "https://www.dropbox.com/s/bruf936x198hn05/cwed2-2014.dta?dl=1", ///
		keepusing(country year ue* us100 uc100 countryabbrev)
	drop if cntry==.
	* temporary, until dataset is complete
	drop if country=="United States" | country=="Taiwan" 
	drop if country=="Bulgaria" | country=="Czech Republic" | country=="Estonia" | country=="Hungary" ///
		| country=="Latvia" | country=="Lithuania" | country=="Poland" | country=="Romania" ///
		| country=="Slovakia" | country=="Slovenia"
	drop if country=="Korea" & year<1996
	drop _merge
	
drop if year>2012 | year<1980
sort country year
	xtset cntry year
	xtdescribe
	
*  Using forward values of CWED data
foreach k in uedur us100 uc100 uecov uequal { //
	gen f_`k'=F.`k'
	drop `k'
	rename f_`k' `k'
	}
	gen avuerr=((us100+uc100)/2)*100
	
*************
* Conditions:
*************

* Occupational protection
*************************
label define occ 0 "No right to refuse" 1 "Permitted period" ///
	2 "Unlimited protection"
	label values occ occ
	
* `Average' occupational protection (concerns UK and BE)
gen occ_dp_adj=occ_dp
	replace occ_dp_adj=.a if country=="Belgium" & year>=1980 & year<=1990
	replace occ_dp_adj=.a if country=="United Kingdom" & year>=1995 & year<2013

gen adj=.
	replace adj=(occ_dp+occ_be_spec+occ_be_wca+occ_be_wcb+occ_be_wcc)/5 if ///
		country=="Belgium" & occ_dp_adj==.a
	replace adj=(occ_dp+occ_dp_min)/2 if country=="United Kingdom" & ///
		occ_dp_adj==.a

	replace occ_dp_adj=adj if occ_dp_adj==.a
		drop adj
		
		
sort cntry year		
xtset cntry year
	gen occ_perm=.
	by cntry: replace occ_perm=D.occ_dp_adj if occ_dp_adj[_n-1]!=occ_dp_adj & occ_dp_adj[_n-1]!=. & occ==1 & occ[_n-1]==1
	su occ_perm
	
* Checks
su occ_dp if year==1980 & occ_dp!=0 // 10 weeks
su occ_dp if year==2010 & occ_dp!=0 // 10 weeks
sort cntry year
	xtset cntry year
	su D.occ_dp if occ_dp_adj[_n-1]!=occ_dp_adj & occ_dp_adj[_n-1]!=. & occ==1 & occ[_n-1]==1
	su D.occ if occ[_n-1]!=occ, det
	bysort cntry: gen d_occ=D.occ
	bysort cntry: gen l_occ=L.occ
	ta l_occ d_occ if d_occ!=0 & L.occ!=. //
	*****************************************************
	
	
	
	

* Wage protection
*****************

* Account for special rules in various countries (stepwise decrease in protection)
gen pwage_r_spec=. // special cases
	
* Permitted period regarding wages in the UK (post-1989)
replace pwage_r_spec=((pwage_per1*pwage_r)+(pwage_per2*pwage_per2_r))/uedur ///
	if country=="United Kingdom" & year>=1989
	replace pwage_r_spec=1 if country=="United Kingdom" & year==1995
	// change in wage protection & simultaneous cut in maximum duration of benefits
	// with JSA induces artificial increase in wage protection; set to value as
	// resulting from the JSA regulations (S.I. 206/1996), assuming that they were
	// anticipated when the JSA was passed
list country year pwage_r pwage_per1 uedur pwage_per2 pwage_per2_r ///
	pwage_r_spec if country=="United Kingdom" & year>=1989

* Permitted period regarding wages in Germany (post-1979)
replace pwage_r_spec=bwage_r*((us100+uc100)/2) if country=="Germany" & ///
	year>=1979 & year<1982 // future wage cannot be lower than benefit
							// unless previous wage was unusually high

replace pwage_r_spec=((pwage_per1*pwage_r)+((uedur-pwage_per1)*(bwage_r*((us100+uc100)/2))))/uedur ///
	if country=="Germany" & year>=1982 & year<1997
	
list country year pwage_r pwage_per1 uedur bwage_r us100 uc100 ///
	pwage_r_spec if country=="Germany" & year>=1982 & year<1997						

replace pwage_r_spec=((pwage_per1*pwage_r)+(pwage_per2*pwage_per2_r)+ ///
	(uedur-(pwage_per1+pwage_per2))*(bwage_r*((us100+uc100)/2)))/uedur ///
	if country=="Germany" & year>=1997 & year<2014

list country year pwage_r pwage_per1 uedur pwage_per2 pwage_per2_r bwage_r us100 uc100 ///
	pwage_r_spec if country=="Germany" & year>=1997
	

* Permitted period regarding wages in Austria (post-2004)
replace pwage_r_spec=((pwage_per1*pwage_r)+((uedur-pwage_per1)*pwage_per2_r))/uedur ///
	if country=="Austria" & year>=2004
	
list country year pwage_r pwage_per1 uedur pwage_per2_r ///
	pwage_r_spec if country=="Austria" & year>=2004


* Wage mobility in Portugal (post-2006; 110% of beneft for first 12 months, 
	* 100 % of benefit thereafter
replace pwage_r_spec=((bwage_per1*(bwage_r*((us100+uc100)/2)))+((uedur-bwage_per1)* ///
	((us100+uc100)/2)))/uedur if country=="Portugal" & year>=2006

list country year bwage_per1 bwage_r us100 uc100 uedur pwage_r_spec ///
	if country=="Portugal" & year>=2006
	
* Wage mobility in Canada (post-2012) - not possible yet, duration data not available
replace pwage_r_spec=((pwage_per1*pwage_r)+((uedur-pwage_per1)*pwage_per2_r))/uedur ///
	if country=="Canada" & year==2012
	
list country year pwage_per1 pwage_r pwage_per2_r uedur pwage_r_spec ///
	if country=="Canada" & year==2012
	
* Wage mobility in the Netherlands (1992-2007): 100% of benefit for first 6 months
replace uedur=108 if country=="Netherlands" & (year==1995 | year==1996) // filling in a missing value,
	* van Gerven (2008, 340) finds that the reform of the maximum duration was introduced in 1994, and went 
	* into effect in 1995;

	* Choose coding: either relative to previous wage (vaguely defined, but defined) or relative
	* to benefit (clearly defined, but probably less generous than first requirement)
	replace pwage_r_spec=(bwage_per1*(bwage_r*((us100+uc100)/2)))/uedur if country=="Netherlands" ///
		& year>=1992 & year<=2007 // ((do not) use if (not) relative to benefit
		
	*replace pwage_r_spec=(pwage_per1/uedur)*pwage if country=="Netherlands" ///
	*	& year>=1992 & year<=2007 // (do not) use if (not) relative to wage
	* using both will, highly probably, not make sense
		
	list country year pwage_r_spec bwage_per1 bwage_r uedur if country=="Netherlands" ///
		& year>=1992 & year<=2007
		
* Wage mobility in France post-2008:  after 3 months, 95% of the previous salary, ///
	// after 6 months 85 percent, after 1 year level of unemployment benefit
replace pwage_r_spec=((pwage_per1*pwage_r) + (pwage_per2_r*pwage_per2) + ///
	(pwage_per3*pwage_per3_r) + ///
	((uedur-(pwage_per3+pwage_per2+pwage_per1))*(bwage_r*((us100+uc100)/2))))/uedur ///
	if country=="France" & year>=2008
	list country year pwage* bwage* if country=="France" & year>=2008
	list country year pwage_r_spec avuerr uedur	if country=="France" & year>=2008
		
* Sweden
replace pwage_r_spec=((us100+uc100)/2)*bwage_r if country=="Sweden"

* Switzerland
replace pwage_r_spec=((us100+uc100)/2)*bwage_r if country=="Switzerland"

* Belgium
replace pwage_r_spec=((us100+uc100)/2)*bwage_r if country=="Belgium" & ///
			year>=1991
			
* Finland
replace pwage_r_spec=((us100+uc100)/2)*bwage_r if country=="Finland" & ///
			year>=1990 & year<=1992

* Italy
replace pwage_r_spec=((us100+uc100)/2)*bwage_r if country=="Italy" & ///
			year==2012 // note the missing CWED data
		
gen wagemob=.
	replace wagemob=pwage_r if pwage==1 & pwage_r_spec==.
	replace wagemob=((us100+uc100)/2)*bwage_r if pwage_r_spec==. ///
		& bwage==1 & pwage==0
	replace wagemob=pwage_r_spec if pwage_r_spec!=.

* Overview		
list country year pwage pwage_r bwage bwage_r if pwage==1 & bwage==1
		
* Filling in missings in New Zealand - minimum wage law always in place, other protections never
	replace mwage=1 if country=="New Zealand" & year>=1973
		replace uwage=0 if country=="New Zealand" & year>=1973
		replace bwage=0 if country=="New Zealand" & year>=1973
		replace pwage=0 if country=="New Zealand" & year>=1973

	
* Other reasons
***************

* Overall number of reasons
egen n_reas=rowtotal(phys skill age family cond_l cond_c strike relig othwork), missing

* Job-search requirements; IAPs
*******************************

* -> see below

***********
* Sanctions
***********

* Voluntary unemployment
************************

* Effective sanctioning period
******************************
gen eff_volsan=.
	replace eff_volsan=volsan_d*volsan_r if volsan==0
	
	* special rules in AUS (disq. periods depend on duration of unemployment spell)
	replace eff_volsan=(volsan_d + volsan_d_per2 + volsan_d_per3)/3 if ///
			country=="Australia" & year>=1994 & year<1997
	
	* Minimum period
gen eff_minvolsan=.
	replace eff_minvolsan=min_volsan_d*min_volsan_r if min_volsan==0
	
list country year eff_minvolsan min_volsan_d volsan_d if min_volsan==0


* Refusals of employment
************************

* Effective disqualification periods (period times share of benefit that is withheld;
	* this will only make a difference where the share withheld is not equal to 1)
foreach k in firsan secsan thirsan fursan {
	gen eff`k'=`k'_d*`k'_r if `k'==0
	}

* Effective disqualification periods, minimum sanctions
foreach k in min_firsan min_secsan min_thirsan {
	gen eff`k'=`k'_d*`k'_r  if `k'==0
	}

	
* Failure to conduct or report job searches
*******************************************

* Effective disqualification period (as before)
for var attsan actsan: gen effX=X_d*X_r
	for var min_attsan min_actsan: gen effX=X_d*X_r

	
	
*******************
* Overall indicator
*******************

******************* 
	
* CONDITIONS
sort cntry year

* Occupational protection:
gen mof_occ=.

ta occ_dp_adj if occ_dp_adj!=0 & year>1980

replace mof_occ=6 if occ==0 // no protection
	replace mof_occ=5 if occ==1 & occ_dp_adj<=10 & occ_dp_adj>0 // up to 9 weeks in effect
	replace mof_occ=4 if occ==1 & occ_dp_adj>10 ///
		& occ_dp_adj<=20 // up to 6 months
	replace mof_occ=3 if occ==1 & occ_dp_adj>20 & occ_dp_adj<=36 // up to 36 weeks
	replace mof_occ=2 if occ==1 & occ_dp_adj>36  // more than 36 weeks
	replace mof_occ=1 if occ==1 & occ_dp_adj==. // `reasonable time'
	replace mof_occ=0 if occ==2 // unlimited protection
	ta mof_occ if year>=1980

	
	list cntry year if mof_occ==. & year>=1980
		// only actual missings
	
* Wage protection
gen mof_wage=.
	su wagemob if year>=1980, det
	*hist wagemob if year>=1980

replace mof_wage=6 if mwage==0 & uwage==0 & pwage==0 & bwage==0
	// no wage protection
	replace mof_wage=5 if (mwage==1 | uwage==1) & pwage==0 & bwage==0
	replace mof_wage=4 if mwage==1 & uwage==1
	replace mof_wage=3 if wagemob<.5 & wagemob!=.
	replace mof_wage=2 if wagemob<.8 & wagemob>=.5  
	replace mof_wage=1 if uwage==1 & occ==2
	replace mof_wage=0 if (wagemob>=.8 & wagemob!=.)
	ta mof_wage if year>=1980
	list country year if mof_wage==. & year>=1980 & year<=2010
		// genuine missings
	tabstat mof_wage, by(cntry)
	
* Other reasons:
gen mof_oth_cnt=phys+skill+age+family+hours+temp+cond_l+cond_c+ ///
	strike+relig+othwork
	
gen mof_oth=.
	replace mof_oth=6 if mof_oth_cnt==0
	replace mof_oth=5 if mof_oth_cnt>0 & mof_oth_cnt<=2
	replace mof_oth=4 if mof_oth_cnt>2 & mof_oth_cnt<=4
	replace mof_oth=3 if mof_oth_cnt>4 & mof_oth_cnt<=6
	replace mof_oth=2 if mof_oth_cnt>6 & mof_oth_cnt<=8
	replace mof_oth=1 if mof_oth_cnt>8 & mof_oth_cnt<=10
	replace mof_oth=0 if mof_oth_cnt>10
	
* gr tw line mof_oth_cnt year, by(country)
	
	
* Job-search requirements
ta freq if year>=1980 

	//replace mof_jsr=1 if proof==1 & freq==999 // undefined intervals
	// replace mof_jsr=5 if proof==1 & freq<4  // less than one month

gen mof_jsr=.
	replace mof_jsr=0 if proof==0 | (attend==1 & proof==.)
	replace mof_jsr=1 if proof==1 & freq>26 & freq<=999 // more than 6 months or undefined intervals
	replace mof_jsr=2 if proof==1 & freq<=26 & freq>12 // between 6 and 3 months
	replace mof_jsr=3 if proof==1 & freq<=12 & freq>=4 // between  3 and 1 month
	replace mof_jsr=4 if proof==1 & freq<4 // less than one month
	replace mof_jsr=mof_jsr+iap if mof_jsr!=. & iap!=. // additional points for IAP (1 or 2)
	ta mof_jsr if year>=1980
	list cntry year if mof_jsr==. & year>=1980

* SANCTIONS

* Voluntary unemployment 
ta eff_volsan if year>=1980

gen mof_vol=.
	replace mof_vol=0 if (volsan==0 & eff_volsan==0) | volsan==999
	replace mof_vol=1 if (volsan==0 & eff_volsan<5 & eff_volsan>0) 
		// in effect, smaller 5
	replace mof_vol=2 if volsan==0 & eff_volsan>=5 & eff_volsan<9
	replace mof_vol=3 if volsan==0 & eff_volsan>=9 & eff_volsan<12
	replace mof_vol=4 if volsan==0 & eff_volsan>=12 & eff_volsan<26
	replace mof_vol=5 if volsan==0 & eff_volsan>=26
	replace mof_vol=6 if volsan==1
	ta mof_vol if year>=1980
	list cntry year if mof_vol==. & year>=1980
	// only actual missings
	
* First refusal
ta efffirsan if year>=1980
	ta firsan if year>=1980
	
gen mof_ref=.
	replace mof_ref=0 if firsan==0 & efffirsan==0 
	replace mof_ref=1 if firsan==999 //  until compliance
	replace mof_ref=2 if firsan==0 & efffirsan<=4 & efffirsan>0
	replace mof_ref=3 if firsan==0 & efffirsan>4 & efffirsan<=9
	replace mof_ref=4 if firsan==0 & efffirsan>9 & efffirsan<=13
	replace mof_ref=5 if firsan==0 & efffirsan>13
	replace mof_ref=6 if firsan==1
	ta mof_ref if year>=1980
	list cntry year if mof_ref==. & year>=1980
	
* Repeated refusals
for var effsecsan effthirsan efffursan: gen Xdiff=X-efffirsan
	egen addsan=rowtotal(effsecsan effthirsan efffursan), missing
	ta addsan if year>1980 & secsan!=. | fursan!=.
	gen addsan_d = addsan-efffirsan
	ta addsan_d if year>1980 & ((secsan!=. & secsan!=1) | ///
		(fursan!=1 & fursan!=.))
	// negative values: no additional sanctions defined, hence 0-first sanction
	
gen mof_rep=.
	replace mof_rep=0 if addsan_d<0 & ((secsan!=. & secsan!=1) | ///
		(fursan!=1 & fursan!=.))
	// at least a second or a `further' sanction has to be defined
	// in some cases, the sanction for repeated refusals was, paradoxically, lower
	// than for the first refusal
	replace mof_rep=1 if (secsan==. & thirsan==. & fursan==.) | (addsan_d==0 & ((secsan!=. & secsan!=1) | ///
		(fursan!=1 & fursan!=.)))
	replace mof_rep=2 if (addsan_d>0 & addsan_d<=2 & ((secsan!=. & secsan!=1) | ///
		(fursan!=1 & fursan!=.))) | (secsan==999 | fursan==999)
		// small increase in strictness or temporary loss of eligibility
	replace mof_rep=3 if addsan_d>2 & addsan_d<10 & ((secsan!=. & secsan!=1) | ///
		(fursan!=1 & fursan!=.))
	replace mof_rep=4 if addsan_d>=10 & addsan_d<18 & ((secsan!=. & secsan!=1) | ///
		(fursan!=1 & fursan!=.))
		// there is a jump between 17.56 (73% quantile) and 18 (81% quant.))
	replace mof_rep=5 if addsan_d>=18 & addsan_d<=169 & ((secsan!=. & secsan!=1) | ///
		(fursan!=1 & fursan!=.))
	replace mof_rep=6 if secsan==1 | thirsan==1 | fursan==1
	replace mof_rep=6 if mof_ref==6 // otherwise countries that disqualify claimants
	// for the first refusal will receive very lenient scores; this is in line with
	// the Venn-scoring procedure
	ta mof_rep if year>=1980
	
	
* Failures to report job-search activities
ta effactsan if year>=1980
	ta actsan if year>=1980

gen mof_fail=.
	replace mof_fail=0 if actsan==. | (effactsan==0)
	replace mof_fail=1 if actsan==999
	replace mof_fail=2 if effactsan>0 & effactsan<4
	replace mof_fail=3 if effactsan>=4 & effactsan<=6
	replace mof_fail=4 if effactsan>6 & effactsan<=8 // in effect, only 8
	replace mof_fail=5 if effactsan>8 & effactsan!=.
	replace mof_fail=6 if actsan==1
	ta mof_fail if year>=1980
	list country year if mof_fail==. & year>=1980

********************
* Overall indicator:
********************

gen mof_cond=mof_occ+mof_wage+mof_oth+mof_jsr
	gen mof_san=mof_vol+mof_ref+mof_rep+mof_fail
	gen mof_suit=mof_occ+mof_wage+mof_oth
	
gen mof_indicator=sqrt(mof_cond*mof_san)/sqrt((6*4)*(6*4))
	
gen mof_conditions=mof_cond/24
	gen mof_sanctions=mof_san/24
	
* This replicates Figure 5 in Knotz (2018, JICSP)
bysort year: egen av_mof=mean(mof_indicator)
	bysort year: egen av_mofcond=mean(mof_conditions)
		label var av_mofcond "Strictness of conditions"
	bysort year: egen av_mofsan=mean(mof_sanctions)
		label var av_mofsan "Strictness of sanctions"
		
gr tw (line av_mofcond year if year>=1980, lp(shortdash) lw(medthick) lc(black) sort) ///
	(line av_mofsan year if year>=1980, lp(dash) lw(medthick) lc(black) sort) ///
	(line av_mof year if year>=1980, lp(solid) sort lw(medthick) lc(black)), ///
	xtitle("Year") ytitle("Strictness score") ///
	plotregion(lcol(black)) legend(colfirst r(1) ring(0) position(2) ///
	symxsize(*.4) size(medsmall) region(lc(black)) ///
	order(2 "Strictness of sanctions" 3 "Overall conditionality" 1 "Strictness of conditions")) ///
	ylabel(.4(.1).6) xsize(6)
	drop av_mof av_mofcond av_mofsan


sort country year
	compress
	save condsanc_compiled_18.dta, replace
	erase condsanc_pre-compiled_18.dta
	

* Export indicator sub-data	
ren mof_sanctions sanctions
	ren mof_conditions conditions
	ren mof_indicator conditionality
	ren mof_occ occup
	ren mof_wage wage
	ren mof_oth oth
	ren mof_jsr jsr
	ren mof_vol vol
	ren mof_ref ref
	ren mof_rep rep
	ren mof_fail fail
	
	
label var sanctions "Strictness of benefit sanctions"
	label var conditions "Strictness of benefit conditions"
	label var conditionality "Overall benefit conditionality"
	label var occup "Occupational protection"
	label var wage "Wage protection"
	label var oth "Other reasons"
	label var jsr "Job-search reporting requirements"
	label var vol "Sanctions for voluntary unemployment"
	label var ref "Sanctions for initial refusals"
	label var rep "Sanctions for repeated refusals"
	label var fail "Sanctions for failures to report"
	
* removing clutter; please see this script and the two linked at the top to
*	see what these variables are and what they do
keep country year sanctions conditions conditionality occup wage oth ///
	jsr vol ref rep fail year country occ occ_dp move comm comm_t phys ///
	skill age family mwage uwage pwage pwage_r bwage bwage_r hours temp ///
	cond_l cond_c strike relig othwork iap attend freq proof firsan ///
	firsan_d firsan_r secsan secsan_d secsan_r thirsan thirsan_d thirsan_r ///
	fursan fursan_d fursan_r volsan volsan_d volsan_r attsan attsan_d ///
	attsan_r actsan actsan_d actsan_r cntry

sort country year
	compress

	
save conditionality.dta, replace
	export delimited using conditionality.csv, replace
