
/* =====================================================================================================

	- Paper: Measuring Human Capital Using Global Learning Data
	- Published: Nature
	- Authors: Noam Angrist, Simeon Djankov, Pinelopi K. Goldberg, Harry A. Patrinos
	- File: Pre-analysis do file to create mid and analysis data
	- Purpose: generate mid-data files from raw data for final analysis

	- Raw Data Inputs:
	--------------

	[ ] HLO_database.dta 			--  Harmonized Learning Outcomes (HLO) full metadata 
	[ ] inc_region.dta 		  	    --  Income and region categories
	[ ] LeeLee_v1.dta 		     	--  Lee and Lee (2016) enrollment data
	[ ] BL-200+.dta 		 	    --  Barro and Lee (2013) years of schooling data
	[ ] pwt90.dta 		   		    --  Penn World Tables GDP data
	[ ] GDP_2000+.dta 		  	    --  World Bank GDP data
	[ ] HDI_edindex_short.dta  	    --  UN Human Development Index - education component
	[ ] resource_rich.dta   		--  World Bank wealth of nations data on economies that are resource-dependent
	[ ] lincs_updated.dta   		--  Learning data for reading in primary school using IRT methods from the LINCS project
	[ ] worlddata2.dta				--  map stata file 1 from shape file
	[ ] worldcoor2.dta				--  map stata file 2 from shape file

	- Analysis Data Outputs:
	--------------

	[ ] hlo_disag.dta 			    -- Harmonized Learning Outcomes (HLO) data for analysis, including nationally representative data unless no other data is available
	[ ] enroll_learning.dta 		-- Combined schooling & learning data in 5-year buckets
	[ ] hlo_country.dta 		    -- Average learning by country from 2000 to 2017
	
	[ ] dev_account_analysis.dta    -- Development accounting file combining GDP, learning and schooling
	[ ] comparingmeasures.dta    	-- Comparing human capital measures combining GDP and multiple human capital measures (Barro-Lee, UN HDI, HLO)
	[ ] lincs_robustness.dta    	-- Comparing IRT and HLO learning data for robustness
	[ ] map.dta    					-- HLO average learning merged to produce a global map

=====================================================================================================**/

	*-----------------------
	* 1) General setup 
	*-----------------------
	
	clear matrix
	set mem 1000m
	set matsize 10000
	set more off
		
	*-----------------------
	* 2) Generate analysis file from full HLO metadata
	*-----------------------

	use "../raw data/HLO_database.dta", replace
	
	* drop non-nationally representative data for countries where nationally representative data exists 
	sort code subject level year
	drop if n_res == 0 & code[_n] == code[_n-1] & subject[_n] == subject[_n-1] & level[_n] == level[_n-1] & sourcetest[_n] != sourcetest[_n-1] // if nationally rep whole series keep or only data point, if new in series with disagg drop
		drop if n_res == 0 & code[_n] == code[_n-1] & subject[_n] == subject[_n-1] & level[_n] == level[_n-1] & sourcetest[_n] != sourcetest[_n-1] // if nationally rep whole series keep or only data point, if new in series with disagg drop
		drop if n_res == 0 & code[_n] == code[_n-1] & subject[_n] == subject[_n-1] & level[_n] == level[_n-1] & sourcetest[_n] != sourcetest[_n-1] // if nationally rep whole series keep or only data point, if new in series with disagg drop
	drop if code == "CHN" & n_res != 1
	
    save "../analysis data/hlo_disag.dta", replace
	
	*---------------------------
	* 3) HLO by country avg 2000-2017, all countries mid data (Figure 1)
	*---------------------------

	use "../analysis data/hlo_disag.dta", replace 
	
	 *avg learning estimates over the time period
	collapse hlo hlo_m hlo_f, by(code incomegroup)
	replace hlo = round(hlo, 1)
	replace hlo_f = round(hlo_f, 1)
	replace hlo_m = round(hlo_m, 1)
	
	save "../analysis data/hlo_country.dta", replace
	
	* merge hlo data with map data
	use "../analysis data/hlo_country.dta", replace
		merge 1:1 code using "../raw data/inc_region.dta"
		duplicates drop
		bys region: sum hlo
		drop _merge
		replace code="SDS" if code=="SSD" // consistent with map
		replace code="PSX" if code=="PSE" //
		replace code="KOS" if code=="XKX" //
		replace code="PYF" if code=="TUV" // Tuvalo merged to French Polynesia since not in map
		save "../mid data/map.dta", replace
		
	use worlddata2.dta, replace
		gen length = length(ADMIN)
		rename ADM0_A3 code
		merge m:m code using "../mid data/map.dta"
		drop _merge
	save "../analysis data/map.dta", replace
	
	*-----------------------
	* 4) Schooling and learning graphs mid data (Figure 2/3, Ext Figure 1-3)
	*-----------------------
	
	* keep data from 2000+ to align to learning data, and for the average student
	use "../raw data/LeeLee_v1.dta", replace
		keep if sex == "MF"
		keep if year >= 2000
		
	* merge in ids for easy merging later
	merge m:1 BLcode using "$path/BLCode-WBcode.dta"
	rename WBcode code
	drop if _merge != 3
	drop _merge
	
	* drop if less than 2 obs to ensure picking up trends over time with data availability
	bys code: gen n = _N
	drop if n <2 
	drop region_code n
		
	save "../mid data/LeeLee.dta", replace 

	* learning by region in 5-year buckets to merge with Barro-Lee
	use "../analysis data/hlo_disag.dta", replace
	
	* primary scores only
	keep if level == "pri" 
	
	* 5 year intervals nearest year to align to enrollment data
	gen period = 5 * round(year/5) 
	collapse hlo hlo_f hlo_m, by(code country period region) 
	
	*  drop if less than 2 obs to ensure picking up trends over time with data availability
	bys code: gen n = _N
	drop if n <2 
	
	sort code period
	rename period year
	drop region n
	
	save "../mid data/learning_region.dta", replace 

	*generate empty 5-year panel for merging of schooling & learning data
	use "../mid data/learning_region.dta", replace
	collapse hlo, by(code country)
	expand 4
	sort code
	bys code: gen n = _n
	gen year = 2000 if n == 1
	replace year = 2005 if n == 2
	replace year = 2010 if n == 3
	replace year = 2015 if n == 4
	drop hlo n
	save "../mid data/emptypanel.dta", replace

	** combined schooling and learning data in 5 year panels
	use "../mid data/emptypanel.dta", replace
		merge m:m code year using "../mid data/learning_region.dta"
		drop _merge
	merge 1:1 code year using "../mid data/LeeLee.dta"
		drop _merge
	merge m:m code using "../raw data/inc_region.dta"
		drop if _merge != 3
		duplicates drop
	
	gen both =1 if pri !=. & hlo !=.
	bys code: egen max = max(both)
		drop if max ==.
		sort code year
		keep code country year hlo pri region
		sort country year
	
	collapse pri hlo, by(code country year region) 
	encode code, gen(code_num)
	encode region, gen(region_num)
	save "../analysis data/enroll_learning.dta", replace // 72 countries

	*-----------------------------
	* 4) Development Accounting Data mid data (Table 1 and Extended Table 2)
	*-----------------------------

	* Penn World Tables GDP data from 2000 onwards
	use "../raw data/pwt90.dta", clear // ** real output per worker at current PPPs 
		keep country countrycode year cgdpo emp hc 
		gen cgdpo_per_cap = cgdpo/emp
		keep if year >= 2000
		collapse cgdpo_per_cap hc, by(countrycode country)
		rename countrycode code
		
	* Barro-Lee educational attainment data from 2000 onwards
	merge m:m code using "../raw data/BL-2000+.dta"
		drop _merge
		rename BL_edu_avg_2000_2010 BL
		
	* HLO learning data on average from 2000 onwards
	merge m:m code using "../analysis data/hlo_country.dta"
		drop _merge
		drop if cgdpo == .
		keep if BL != . & hlo !=.
		
	* World Bank GDP data from 2000 onwards
	merge m:m code using "../raw data/GDP_2000+.dta"
		drop if _merge != 3
		drop _merge
	
	collapse cgdpo_per_cap hc BL BL_edu_2000 hlo annual_growth_rate cgdpe_per_cap gdp_per_cap_2000 log_gdp_per_cap_2000, by(incomegroup region_code country country code)
	save "../analysis data/dev_account_analysis.dta", replace 

	*-----------------------------
	* 5) Comparing human capital measures mid data (Table 2)
	*----------------------------- 

	* World Bank GDP data from 2000 onwards
	use "../raw data/GDP_2000+.dta", replace
		merge m:m code using "../raw data/BL-2000+.dta"
		drop _merge
	* HLO learning data on average from 2000 onwards
	merge m:m code using "../analysis data/hlo_country.dta"
		keep if _merge == 3
		drop _merge
	* WB income and region categories
	merge m:m code using "../raw data/inc_region.dta"
		drop _merge
		duplicates drop
	* wealth of nations data on how resource rich a country is
	merge m:m code using "../raw data/resource_rich.dta"
		drop _merge
	* United Nations Human Development Index (HDI) - education component
	merge m:m country using "../raw data/HDI_edindex_short.dta"
		keep if _merge == 3
		drop _merge
		keep if annual_growth_rate !=. & BL_edu_avg_2000_2010 != . & hlo != .
	collapse hc hlo BL_edu_avg_2000_2010 BL_edu_2000 avg_resource_2010_2015 annual_growth_rate gdp_per_cap_2000 y2000, by(code)
	
	* following the growth and human capital comparisons literature keep countries that are not overly dependent on natural resources 
	drop if avg_resource_2010_2015 > 15 
	
	save "../analysis data/comparingmeasures.dta",replace
		
	*-----------------------
	* LINCS Robustness (Extended Data Figure 4)
	*-------------------------

	* IRT learning data from the LINCS project from 2000 onwards, primary reading data, averaged from 2000-2010
	use "../raw data/lincs_updated.dta", replace
		rename cntabb code
		keep if year >= 2000
		collapse L_SCORE, by(code)
		rename L_SCORE L_SCORE_2000
		replace code = "ROM" if code == "MDA"
	save "../mid data/lincs_2000.dta", replace // average 2000-2010, pri reading

	* HLO learning data from 2000 onwards, primary reading data, averaged from 2000-2010
	use "../analysis data/hlo_disag.dta", replace
		keep if year >= 2000 & year <= 2010
		keep if subject == "reading"
		keep if level == "pri"
		collapse hlo, by(code)
	save "../mid data/hlo_pri_read.dta", replace // average 2000-2010, pri reading

	* Merge IT and HLO learning data over same time period and subject
	use "../mid data/hlo_pri_read.dta", replace
		merge m:m code using "../mid data/lincs_2000.dta"
		keep if _merge == 3 
		drop _merge
	save "../analysis data/lincs_robustness.dta", replace
	clear


