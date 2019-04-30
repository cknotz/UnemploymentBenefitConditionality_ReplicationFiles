***********************************************************
* The Unemployment Benefit Conditions & Sanctions Dataset *
***********************************************************

* Data Preparation File
***********************

* Author: Carlo Knotz


* The following lines are commented out as it is assumed that this script is
*	run automatically via the `condsanc_compilation_18.do' script; if not
*	please uncomment:

* version 13.1
* use "https://www.dropbox.com/s/gtyi99jjalhw5it/condsanc_18_raw.dta?dl=1", clear


/* Running this DoFile makes some adjustments to the raw dataset and inter-
	polates a few missing years. The adjustments and interpolations are, as
	usually, based on assumptions. Rather than making these assumptions for
	other users of this dataset, the authors wish to give other users the
	possiblity to select which adjustments they want to make and which not. This
	file also serves to increase transparency as all adjustments are documented
	and commented. Users wishing to test the implications of these assumptions
	or the stability of their own or others' results can easily do this using
	this file.
	
	The changes made are the following:
	
	a) The qualitative data on sanctions in Australia is more detailed than
		what is contained in the raw dataset. The raw dataset includes the 
		provisions as specified in the version of the Social Security Act. The
		Act only specified the maximum duration of non-payment periods at that
		time. We were able to obtain a policy manual issued and used by the
		Commonwealth Employment Service (CES) in 1976, which was valid until
		1979 (when it was replaced by a new manual and an additional Circular).
		The manual specified a graduated sanctioning schedule with post-
		ponement periods between 2 weeks (first infraction) and 6 weeks
		(third and subsequent infractions). A second manual, this time issued by
		the Department of Social Services and valid between 1983 and 1986, also
		specified a graduated sanctioning schedule. These provisions are not 
		coded in the raw dataset, but can be put it using this DoFile.
		
		Note: this creates two breaks where Australia changes from a graduated
		to a simple santioning rule, and back (1976-1979 & 1983-1986). 
		Users are advised to consider whether this is desirable for their 
		analyses.
		
		Reseachers wishing to compare the `sophistication' of sanctioning
		provisions in legal codes might wish to turn this adjustment off to
		avoid comparing (more detailed) regulations/manuals in Australia with 
		usually less detailed laws in other countries. Researchers interested 
		in the effects of sanctions or in the Australian case as such might 
		want to turn the adjustment on to obtain the most detailed data 
		available.
		
		
	b) The data on the definition of suitable employment in New Zealand are
		partly missing. This is because this is and has always been defined in
		policy manuals rather than legislation. We were not able to obtain all
		policy manuals and amendments thereof.
		
		This file interpolates the variables on suitable employment for the
		years 1989-1992. 1989 is the last year in which a new UB policy manual
		was issued (`Unemployment and Training Benefit Manual'); 1992 was the 
		year in which the old Department of Social Welfare was completely
		restructed and the NZ Income Support Service was created. They issued
		a new manual in 1993, of which we have only the 1995 version.
		
		Interpolating the data means making the assumption that the provisions
		regarding suitable employment have not been changed between 1989 and
		1992. They did in fact not change between 1986 and 1989, so there are
		reasons to assume that they stayed the same. We leave this decision
		to the user.
		
		
	c) Some countries specify maximum as well as miminum non-payment periods.
		This concerns Australia, Belgium, Canada, France, [...]
		The differences between minimum and maximum period are often consider-
		able, and using either one alone can significantly affect the comparat-
		ive scoring of a country. The raw dataset includes only the maximum of
		all defined non-payment periods; this DoFile creates additional
		variables that contain the minimum duration of sanctioning periods where
		these are defined.
		
		The differences between maximum and minimum non-payment periods are
		often considerable. In Australia, the minimum is half or a third of
		the maximum period, the differences in Belgium are far more massive.
		Users are advised that using only the maximum might make these countries
		seem harsher than they (probably) were practised. Yet, users with a
		substantive interest in the harshness of overall sanctions might be able
		to ignore the minimum non-payment period.
		
	d) The definition of suitable employment is often more complex than the raw
	data suggest. Most importantly, some countries have at times differentiated
	between types of claimants or different periods of the unemployment spell.
	This concerns e.g. Belgium (permitted periods), Germany, Austria, the United
	Kingdom, Portugal (expected wage deemed suitable), [....]
	
	The code provided here accounts for this by creating extra variables that
	capture a) the minimum expected wage in relation to benefits/previous wages
	during all periods in the unemployment spell that are defined in a country,
	and b) the duration of each defined period. This allows to calculate the
	average earnings-reduction claimants have to accept during their unemploy-
	ment spell by weighting the minimum acceptable wage by the share of the 
	maximum duration (e.g. from the Scruggs et al. CWED dataset) during which
	a certain minimum is applied.
	
	Researchers interested only in the initial period of unemployment may not
	need to use this.
	
	e) Korea does only specify that moving can not or only under certain circum-
		stances be required. Deok Soon Hwang (reviewer for Korea) noted that
		this rule is not really enforced, i.e. claimants are generally not
		required to move. However, commuting requirements are not defined. 
		Venn (2012, 45) suggests that commuting can be required unless it would
		be too difficult. The variable ´comm' (requirement to commute: yes/no)
		is missing in the raw dataset.
		
		This file recodes the Korean data as commutes (of undefined duration)
		could always be required in Korea, i.e. - comm==1 -.
	
	*/

* AUSTRALIA: NON-PAYMENT PERIODS
********************************
	
* Including rules specified in manuals/guidelines - more accurate for some years, 
	* but introduces breaks
/*	
for var firsan secsan thirsan fursan volsan: replace X=0 if country=="Australia" & ///
	year>=1976 & year<1979
	
for var firsan_r secsan_r thirsan_r fursan_r volsan: replace X=1 if country=="Australia" & ///
	year>=1976 & year<1979
	
replace firsan_d=2 if country=="Australia" & year>=1976 & year<1979
	replace secsan_d=4 if country=="Australia" & year>=1976 & year<1979
	replace thirsan_d=6 if country=="Australia" & year>=1976 & year<1979
	replace fursan_d=6 if country=="Australia" & year>=1976 & year<1979
	replace volsan_d=2 if country=="Australia" & year>=1976 & year<1978
	
replace volsan_r=1 if country=="Australia" & year>=1979 & year>1983
	replace volsan=1 if country=="Australia" & year>=1979 & year>1983
	replace volsan_d=12 if country=="Australia" & year>=1979 & year>1983
* voluntary unemployment sanctioned with 12 weeks postponement
	* from 1979 onwards; from 1983, DSS manual
		
for var firsan secsan thirsan fursan volsan: replace X=0 if country=="Australia" & ///
	year>=1983 & year<1987
	
for var firsan_r secsan_r thirsan_r fursan_r volsan_r: replace X=1 if country=="Australia" & ///
	year>=1983 & year<1987
	
replace firsan_d=6 if country=="Australia" & year>=1983 & year<1987
	replace secsan_d=8 if country=="Australia" & year>=1983 & year<1987
	replace thirsan_d=10 if country=="Australia" & year>=1983 & year<1987
	replace fursan_d=12 if country=="Australia" & year>=1983 & year<1987
	replace volsan_d=6 if country=="Australia" & year>=1983 & year<1987
	replace actsan_d=6 if country=="Australia" & year>=1983 & year<1987
*/
	
* Interpolating data for the New Zealand time series
****************************************************

* There are older versions of the Unemployment Benefit Manual that has been
*	used between 1990 and 1999; we were only able to obtain the copy from the
*	years 1995/1996; NZL introduced a digital manual (the MAP system), which is
*	available to the public from 2004 onwards. The following code interpolates
*	the missing values -- the assumption is that the list of valid reasons did
*	not change between the versions of the UB Manual and the later MAP manual.
sort country year

for var phys skill family cond_l strike relig othwork temp hours: ///
	replace X=X[_n-1] if year>=1990 & year<=1994 & ///
		country=="New Zealand" // UB Manual
		
for var age cond_c: replace X=0 if year>=1990 & year<=1994 & ///
		country=="New Zealand" // UB Manual

for var phys skill age family cond_l cond_c strike relig othwork temp hours: ///
	replace X=X[_n-1] if year>=1997 & year<=2003 & ///
		country=="New Zealand" // MAP system


* Minimum sanctions 1979-84 & 1986-7
foreach k in firsan secsan volsan attsan { // also used below for other countries
	gen min_`k'=.
	gen min_`k'_r=.
	gen min_`k'_d=.
	}
	
foreach k in firsan volsan {
	
	replace min_`k'=0 if country=="Australia" & ((year>=1979 & year<1984) ///
		| year==1986)
	replace min_`k'_r=1 if country=="Australia" & ((year>=1979 & year<1984) ///
		| year==1986)
	replace min_`k'_d=6 if country=="Australia" & year>=1979 & year<1984
	replace min_`k'_d=2 if country=="Australia" & year==1986
}
	gen min_actsan=.
	gen min_actsan_r=.
	gen min_actsan_d=.
		replace min_actsan=0 if country=="Australia" & year==1986
		replace min_actsan_r=1 if country=="Australia" & year==1986
		replace min_actsan_d=2 if country=="Australia" & year==1986

/* Graduated sanctions depending on UE duration (1994-1997); this part generates
	additional variables capturing the duration of postponement periods and
	the duration of unemployment at which such periods would be applied;
	concerns only non-administrative `breaches' and subsequent periods (first
	period already included).
	During the first year, the first infraction would result in a non-payment
	period of 2 weeks, then 4 weeks in the second year, and 6 in the third.
	Each additional infraction within an overall period of 3 years 
	- regardless of the duration of unemployment - would result in the previous 
	non-payment period plus 6 weeks. */
	
* Generating variables
foreach k in firsan secsan thirsan volsan {
	gen `k'_per2=.
	gen `k'_per3=.
	
	gen `k'_r_per2=.
	gen `k'_r_per3=.
	
	gen `k'_d_per2=.
	gen `k'_d_per3=.
	
	replace `k'_per2=`k' if country=="Australia" & year>=1994 & year<1997
	replace `k'_per3=`k' if country=="Australia" & year>=1994 & year<1997
	replace `k'_r_per2=`k'_r if country=="Australia" & year>=1994 & year<1997
	replace `k'_r_per3=`k'_r if country=="Australia" & year>=1994 & year<1997
}
* Duration of periods
	gen aus_per1="First year" if country=="Australia" & year>=1994 & year<1997
		// first year of unemployment
	gen aus_per2="Second year" if country=="Australia" & year>=1994 & year<1997
		// second year of unemployment
	gen aus_per3="Third year" if country=="Australia" & year>=1994 & ///
		year<1997
		// Third year of unemployment
		
* Additional non-payment periods	
replace firsan_d_per2=4 if country=="Australia" & year>=1994 & year<1997
	replace firsan_d_per3=6 if country=="Australia" & year>=1994 & year<1997
	replace secsan_d_per2=10 if country=="Australia" & year>=1994 & year<1997
	replace secsan_d_per3=12 if country=="Australia" & year>=1994 & year<1997
	replace thirsan_d_per2=16 if country=="Australia" & year>=1994 & year<1997
	replace thirsan_d_per3=18 if country=="Australia" & year>=1994 & year<1997
	replace volsan_d_per2=10 if country=="Australia" & year>=1994 & year<1997
	replace volsan_d_per3=12 if country=="Australia" & year>=1994 & year<1997


* BELGIUM: PERMITTED PERIOD, DISPO-PROCEDURE, AND MINIMUM NONPAYMENT PERIODS
****************************************************************************

* Permitted period between 1964 and 1991 differentiated between and within
	* workers and employees; raw data only includes rule for `qualified workers'
	
gen occ_be_spec=.
	gen occ_be_wca=.
	gen occ_be_wcb=.
	gen occ_be_wcc=.
	
label var occ_be_spec "Permitted period specialized workers (BE)"
	label var occ_be_wca "Permitted period med./superior white collar (BE)"
	label var occ_be_wcb "Permitted period subpar white collar (BE)"
	label var occ_be_wcc "Permitted period manual/intellect. white collar (BE)"

replace occ_be_spec=4 if country=="Belgium" & year>=1964 & year<1991		
	replace occ_be_wca=26 if country=="Belgium" & year>=1964 & year<1991
	replace occ_be_wcb=12 if country=="Belgium" & year>=1964 & year<1991
	replace occ_be_wcc=0 if country=="Belgium" & year>=1964 & year<1991
	
* Job-search reporting requirements in BE (DISPO procedure)

gen freq_spec=.
	replace freq_spec=64 if country=="Belgium" & year>=2004 & year<2013
	* first interview after 21 months (84 weeks), recorded by -freq- variable;
	* second follow-up interview (if not insufficient job-search) after 16 months,
	* i.e. 64 weeks (recorded by freq_spec)
	
	
* Minimum sanctions
for var min_firsan min_secsan min_volsan: ///
	replace X=0 if country=="Belgium" & year>=1963 & year<2014
	replace min_attsan=0 if country=="Belgium" & year>=1992 & year<2014
	
for var min_firsan_r min_secsan_r min_volsan_r: ///
	replace X=1 if country=="Belgium" & year>=1963 & year<2014
	replace min_attsan_r=1 if country=="Belgium" & year>=1992 & year<2014
	
replace min_firsan_d=4 if country=="Belgium" & year>=1963 & year<1992
	replace min_firsan_d=8 if country=="Belgium" & year>=1992 & year<2000
	replace min_firsan_d=4 if country=="Belgium" & year>=2000 & year<2014
	
replace min_secsan_d=13 if country=="Belgium" & year>=1963 & year<1992
	replace min_secsan_d=26 if country=="Belgium" & year>=1992 & year<2000
	replace min_secsan_d=8 if country=="Belgium" & year>=2000 & year<2014
	
replace min_volsan_d=4 if country=="Belgium" & year>=1963 & year<1992
	replace min_volsan_d=13 if country=="Belgium" & year>=1992 & year<2000
	replace min_volsan_d=4 if country=="Belgium" & year>=2000 & year<2014
	* voluntary unemployment 1992: minimum 8 weeks or 26 weeks?
	
replace min_attsan_r=1 if country=="Belgium" & year>=1992 & year<2014
	replace min_attsan_d=13 if country=="Belgium" & year>=1992 & year<2000
	replace min_attsan_d=4 if country=="Belgium" & year>=2000 & year<2014
	
* Sanctions for failure to comply with DISPO procedure (reports of job-search
	* activities) in Belgium; first failure will not be punished, but second will
	* the following lines include this into the dataset.
	
gen secactsan=.
	gen secactsan_d=.
	gen secactsan_r=.
	replace secactsan=0 if country =="Belgium" & year>=2004 & year<2013
	replace secactsan_d=16 if country =="Belgium" & year>=2004 & year<2013
	replace secactsan_r=1 if country =="Belgium" & year>=2004 & year<2013
	

* CANADA: NON-PAYMENT PERIODS POST-1990
***************************************
replace min_firsan=0 if country=="Canada" & year>=1990 & year<2013
	replace min_firsan_r=1 if country=="Canada" & year>=1990 & year<2013
	
	replace min_volsan=0 if country=="Canada" & year>=1990 & year<1993
	replace min_volsan_r=1 if country=="Canada" & year>=1990 & year<1993
	// Minimum non-payment period in those two cases was/is 7 weeks
	
	replace min_firsan_d=7 if country=="Canada" & year>=1990 & year<2013
	replace min_volsan_d=7 if country=="Canada" & year>=1990 & year<1993
	

* FRANCE: NON-PAYMENT PERIODS
*****************************

replace min_firsan=0 if country=="France" & year>=1992 & year<2005
	replace min_firsan_d=8 if country=="France" & year>=1992 & year<2005
	replace min_firsan_r=1 if country=="France" & year>=1992 & year<2005
	
replace min_attsan=0 if country=="France" & year>=1992 & year<2005
	replace min_attsan_d=8 if country=="France" & year>=1992 & year<2005
	replace min_attsan_r=1 if country=="France" & year>=1992 & year<2005

gen min_thirsan=.
	gen min_thirsan_d=.
	gen min_thirsan_r=.
	replace min_thirsan=0 if country=="France" & year>=2008 & year<2012
	replace min_thirsan_r=1 if country=="France" & year>=2008 & year<2012
	replace min_thirsan_d=26 if country=="France" & year>=2008 & year<2012
	// non-payment for 6 months (26 weeks) or full disqualification for third
	// refusal of employment
	

replace min_secsan=0 if country=="France" & year>=2005 & year<2008
	replace min_secsan_r=.5 if country=="France" & year>=2005 & year<2008
	replace min_secsan_d=8 if country=="France" & year>=2005 & year<2008
	gen min_secsan_d_fr=.
	replace min_secsan_d_fr=26 if country=="France" & year>=2005 & year<2008
	// reduction of payments for between 2 and 6 months (8-26 weeks) by 50% or
	// full disqualification for second refusal
		
replace min_actsan=0 if country=="France" & year>=1992 & year<2005
	replace min_actsan_d=8 if country=="France" & year>=1992 & year<2005
	replace min_actsan_r=1 if country=="France" & year>=1992 & year<2005
	
replace min_actsan=0 if country=="France" & year>=2008 & year<2012
	replace min_actsan_d=8 if country=="France" & year>=2008 & year<2012
	replace min_actsan_r=.2 if country=="France" & year>=2008 & year<2012
	

* JAPAN: MINIMUM NON-PAYMENT PERIODS VOLUNTARY UNEMPLOYMENT
***********************************************************
replace min_volsan_d=4 if country=="Japan"
	replace min_volsan_r=1 if country=="Japan"
	replace min_volsan=0 if country=="Japan"
	
	
* UNITED KINGDOM: MINIMUM NON-PAYMENT PERIODS UNDER JOB-SEEKER'S Act (1995)
***************************************************************************

foreach k in fir vol act {
replace min_`k'san=0 if country=="United Kingdom" & year>=1995 & year<2012
	replace min_`k'san_r=1 if country=="United Kingdom" & year>=1995 & year<2012
	replace min_`k'san_d=1 if country=="United Kingdom" & year>=1995 & year<2012
	// Minimum sanction of 1 week for all infractions introduced by 1995 JSA
	}
	replace min_attsan=0 if country=="United Kingdom" & year>=1995 & year<2012
	replace min_attsan_d=1 if country=="United Kingdom" & year>=1995 & year<2010
	replace min_attsan_r=1 if country=="United Kingdom" & year>=1995 & year<2010

* STEPWISE WAGE MOBILITY REQUIREMENTS IN SOME COUNTRIES
*******************************************************

* Germany (1982-1996: relative to previous wage during first four months)
gen pwage_per1=.
	replace pwage_per1=16 if country=="Germany" & year>=1982 & year<1997
		// 16 weeks during which 80 percent of the previous
		// wage are the limit; thereafter: benefit level (unless previous wage
		// on the basis of which benefit is calculated was unusually high)
	

* Germany (1997-current: 80% of previous wage for first 3 months, 70% during
	* following three months, benefit level, i.e. 60% gross, thereafter)
replace pwage_per1=12 if country=="Germany" & year>=1997 & year<2014

gen pwage_per2=.
	replace pwage_per2=12 if country=="Germany" & year>=1997 & year<2014
gen pwage_per2_r=.
	replace pwage_per2_r=.7 if country=="Germany" & year>=1997 & year<2014
	// Remaining period not clearly defined in Germany since the maximum duration
	// of payments depends on a claimant's age and employment record
		
	
* Austria (post-2004: 80% of previous wage for first 120 days, 75% thereafter)
replace pwage_per1=17 if country=="Austria" & year>=2004 & year<2014
	// 120/7=17.1429
		replace pwage_per2_r=.75 if country=="Austria" & year>=2004 & year<2014
		// remaining period not clearly defined in Austria since maximum 
		// duration depends on age and duration of previous employment
		
* Portugal (post-2006: expected wage cannot be lower than 110% of current
	* benefit for first 12 months of unemployment)
gen bwage_per1=.
	replace bwage_per1=52 if country=="Portugal" & year>=2006 & year<2014
	
gen bwage_per2_r=.
	replace bwage_per2_r=1 if country=="Portugal" & year>=2006 & year<2014
	// as in Austria, the maximum duration of unemployment benefits depends on
	// the claimant's age and employment record, hence a universal length of a
	// second period cannot be determined

* United Kingdom (1989-1996: 100% of previous wage during 'permitted period' of
	* 13 weeks; 1996-current: 100% of previous wage during first 6 months)
replace pwage_per1=13 if country=="United Kingdom" & year>=1989 & year<1996
	replace pwage_per1=26 if country=="United Kingdom" & year>=1996 & year<2013
	
replace pwage_per2_r=0 if country=="United Kingdom" & year>=1989 & year<2013
	// no restriction with respect to salary after permitted periods
	replace pwage_per2=39 if country=="United Kingdom" & year>=1989 & year<1996
	// 52 weeks minus 13
	replace pwage_per2=0 if country=="United Kingdom" & year>=1996 & year<2013
	// duration of income-related JSA is only 26 weeks

* Canada (post-2012: occupational and wage mobility differentiated by claimant
	* groups: claimants are allowed to search for jobs within their own prof-
	* ession for 18, and a similar one for another 18 weeks (added together);
	* claimants who have been unemployed for more than a total of 60 weeks in at
	* least 3 benefit periods in the past 260 weeks are allowed to limit their
	* availability for 6 weeks; a third, residual, group is allowed to restrict
	* their availability for 8 weeks to their own occupation, to a similar one
	* for another 8 weeks, and are allowed no restrictions after those 16 weeks)
	* 
	* The `permitted period' is coded as 36 weeks as only the first group of
	* claimants is considered here (this group seems most comparable to the
	* average (production) worker ideal-type used in the SCIP and CWED datasets)
	*
	* There are different requriements to be flexible with regard to wages for
	* each of the groups, further differentiated by the period in the claimant's
	* unemployment spell. This file adds the additional steps for, as above,
	* the first claimant type.
	
replace pwage_per1=18 if country=="Canada" & year==2012
	replace pwage_per2_r=.8 if country=="Canada" & year==2012
	// as above, the maximum duration is not clearly defined. Claimants can
	// receive benefits for longer than the usual 45 weeks, depending on their
	// local unemployment rate and their employment record. This means, a third
	// period cannot be clearly defined.
	
* France post-2008: after 3 months, 95% of the previous salary, after 6 months
	// 85 percent, after 1 year level of unemployment benefit
replace pwage_per1=12 if country=="France" & year>=2008
	replace pwage_per2_r=.95 if country=="France" & year>=2008
	replace pwage_per2=12 if country=="France" & year>=2008
gen pwage_per3=.
	gen pwage_per3_r=.
	replace pwage_per3_r=.85
	replace pwage_per3=26 if country=="France" & year>=2008
	
* COMMUTING REQUIREMENTS IN KOREA:
**********************************
replace comm=1 if country=="Korea"


* GEOGRAPHICAL MOBILITY REQUIREMENTS IN FINLAND (1978-1984)
***********************************************************

replace move=1 if country=="Finland" & year>=1978 & year<1984
	replace comm=1 if country=="Finland" & year>=1978 & year<1984
	replace family=1 if country=="Finland" & year>=1978 & year<1984
	* The 1971 (v. 1978/1982) Labor Market Regulations, which regulated the 
	* provision of unemployment benefits prior to 1984, did not include any
	* provisions that would specify geographical mobility requirements.
	* This coding is based on the findings of the Hummel-Liljegren survey and
	* information from the country expert for Finland, Heikki Räisänen.
	* Claimants with dependants could be excempted from the (principal) requi-
	* riement to relocate.


* UNITED KINGDOM
****************

* MINIMUM PERMITTED PERIOD (1 WEEK) IN THE UK, 1995-PRESENT
* The UK Jobseekers Act (1995) introduced that the `permitted period' could
* 	range between 1 and 13 weeks (instead of 13 weeks as before). The raw
* 	dataset takes only the maximum into account; the following code adds a 
* 	separate variable for the minimum protected period.
gen occ_dp_min=.
	replace occ_dp_min=1 if country=="United Kingdom" & year>=1995 & year<2013

* COMMUTING REQUIREMENTS IN THE UK, POST-2004 (up to 3 hrs/day after 13 weeks)?
gen comm_per1=13 if country=="United Kingdom" & year>=2004 & year<2013
	gen comm_per2=13 if country=="United Kingdom" & year>=2004 & year<2013
	gen comm_t_per2=3 if country=="United Kingdom" & year>=2004 & year<2013
	* remaining period is simply 26 weeks (maximum duration of Income-Based JSA)
	* - 13 weeks permitted period
	
* WAGE MOBILITY REQUIREMENTS IN THE NETHERLANDS (1992-2007)
* Claimants do not have to accept wages below their unempoyment benefit
	* or significantly below the previous wage for first 6 months
replace bwage_per1=26 if country=="Netherlands" & year>=1992 & year<=2007
	replace pwage_per1=26 if country=="Netherlands" & year>=1992 & year<=2007
	

* COMMUTING REQUIREMENTS NL, FR
*************************************

* Second period (after 6 months) in France: commuting requirement of 2hrs/day
	replace comm_per1=26 if country=="France" & year>=2008
	replace comm_t_per2=2 if country=="France" & year>=2008
	* remaining period (`comm_per2') is the maximum duration of payments minus 26 weeks

* Second period commuting requirements in NL (post-1996)
	replace comm_per1=26 if country=="Netherlands" & year>=1996
	replace comm_t_per2=3 if country=="Netherlands" & year>=1996
	* remaining period (`comm_per2') is the maximum duration of payments minus 26 weeks


* Identifying consequential missings (see codebook)
***************************************************

replace occ_dp=.a if occ==2
	replace pwage_r=.a if pwage==0
	replace bwage_r=.a if bwage==0
	replace comm_t=.a if comm==0

foreach k in fir sec thir vol { // Different periods of unemployment
	replace `k'san_d=.a if `k'san==1 | `k'san==999
	replace `k'san_d_per2=.a if `k'san_per2==1 | `k'san_per2==999
	replace `k'san_d_per3=.a if `k'san_per3==1 | `k'san_per3==999
	}

foreach k in fir sec thir vol att act { // Minimum sanctions
	replace min_`k'san_d=.a if min_`k'san==1 | min_`k'san==999
	}	
replace secactsan_d=.a if secactsan==1 | secactsan==999


* Export
********
	
save condsanc_pre-compiled_18.dta, replace
