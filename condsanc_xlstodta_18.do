
***********************************************************
* The Unemployment Benefit Conditions & Sanctions Dataset *
***********************************************************

* This DoFile turns the Excel-spreadsheets containing the `raw' data into a Stata (.dta) file
*********************************************************************************************
	
* Author: Carlo Knotz 

* Starting with Australia as the first country:
import excel using "https://www.dropbox.com/s/ycem4etqoaleyic/Conditions_Sanctions_coded_Jul18.xlsx?dl=1", ///
	sheet("Australia") first clear
	save condsanc_18.dta, replace


	 
foreach k in Austria Finland Germany Korea UK Ireland NZL Spain Sweden Greece Portugal ///
	Canada Denmark Switzerland Norway Netherlands Belgium Japan Italy France {
	import excel using "https://www.dropbox.com/s/ycem4etqoaleyic/Conditions_Sanctions_coded_Jul18.xlsx?dl=1", ///
	sheet("`k'") first clear
	save condsanc_`k'_18.dta, replace
	} // this loop creates sub-datasets for each country
	
foreach k in Austria Finland Germany Korea UK Ireland NZL Spain Sweden Greece Portugal ///
	Canada Denmark Switzerland Norway Netherlands Belgium Japan Italy France  {
	use condsanc_18.dta, clear
	append using condsanc_`k'_18.dta,
	save condsanc_18.dta, replace
	erase condsanc_`k'_18.dta
	} // this loop pools all sub-datasets into one single dataset and erases the 
	  // previously created sub-datasets one at a time	
	
* Summary table:
sutex  occ occ_dp move comm comm_t phys skill age family mwage uwage pwage pwage_r  ///
	bwage bwage_r hours temp cond_l cond_c strike relig othwork iap attend proof freq ///
	firsan firsan_d firsan_r secsan secsan_d secsan_r thirsan thirsan_d thirsan_r ///
	volsan volsan_d volsan_r attsan attsan_d attsan_r actsan actsan_d actsan_r, ///
	file(condsanc_sum18) replace long title(Summary Statistics) minmax dig(2)
	
* Labelling variables:
label var occ "Occupational mobility"
	label var occ_dp "Permitted period"
	label var move "Requirement to move"
	label var comm "Requirement to commute"
	label var comm_t "Max. daily commuting time (hrs.)"
	label var phys "Physical & mental capabilities"
	label var skill "Skills"
	label var age "Age"
	label var family "Familial/caring responsibilities"
	label var mwage "Minimum wage"
	label var uwage "Usual wage in profession"
	label var pwage "Wage must be correspond to previous wage"
	label var pwage_r "Minimum ratio of previous to expected wage"
	label var bwage "Wage must correspond to benefit"
	label var bwage_r "Minimum ratio of benefit to expected wage"
	label var hours "Job must not be part-time"
	label var temp "Job must not be temporary"
	label var cond_c "Conditions must conform to collective agreement"
	label var cond_l "Conditions must conform to legal standards"
	label var strike "Vacancy must not be due to strike/lockout"
	label var relig "Job cannot contradict claimant's moral/ethical/religious convictions"
	label var othwork "Other available employment allows to refuse offers"
	label var iap "Individual Action Plan/Integration Contract"
		label define iaplp 0 "Not used" 1 "Voluntary/only spec. groups" 2 "Mandatory for all claimants"
		label values iap iaplb
	label var attend "Claimants have to attend"
	label var proof "Claimants have to provide evidence of job-search activities"
	label var freq "Frequency of job-search reports"
	label var firsan "Loss of eligibility - first refusal"
	label var secsan "Loss of eligibility - second refusal"
	label var thirsan "Loss of eligibility - third refusal"
	label var fursan "Loss of eligibility - further refusals"
	label var volsan "Loss of eligibility - vol. unemployment"
	label var attsan "Loss of eligibility - failure to attend"
	label var actsan "Loss of eligibility - failure to provide evidence"
	label var firsan_d "Period of non-payment - first refusal"
	label var secsan_d "Period of non-payment - second refusal"
	label var thirsan_d "Period of non-payment - third refusal"
	label var fursan_d "Period of non-payment - further refusals"
	label var volsan_d "Period of non-payment - vol. unemployment"
	label var attsan_d "Period of non-payment - failure to attend"
	label var actsan_d "Period of non-payment - failure to provide evidence"
	label var firsan_r "Reduction of benefit - first refusal"
	label var secsan_r "Reduction of benefit - second refusal"
	label var thirsan_r "Reduction of benefit - third refusal"
	label var fursan_r "Reduction of benefit - further refusals"
	label var volsan_r "Reduction of benefit - vol. unemployment"
	label var attsan_r "Reduction of benefit - failure to attend"
	label var actsan_r "Reduction of benefit - failure to provide evidence"
	label data "The Unemployment Benefit Sanctions & Conditions Dataset (v. Apr2019)"
	

* Sorting and time-series-setting data
sort country year
	encode country, gen(cntry)
	drop year2 // only used to enter data into Excel
	xtset cntry year
	save condsanc_18_raw.dta, replace
	saveold condsanc_18R_raw.dta, replace
	erase condsanc_18.dta
