
/* =====================================================================================================

	- Paper: Measuring Human Capital Using Global Learning Data
	- Published: Nature
	- Authors: Noam Angrist, Simeon Djankov, Pinelopi K. Goldberg, Harry A. Patrinos
	- File: Analysis do file to create tables, figures, and conduct analysis

=====================================================================================================**/

	*-----------------------
	* 1) General setup 
	*-----------------------
	
	* set local directory to raw data node of the repository files
	cd "{enter directory here}/raw data"

	clear matrix
	set mem 1000m
	set matsize 10000
	set more off
	
	* run file to generate mid and analysis data from raw data
	do "../do files/MHC pre-analysis data.do"
	
	*-------------------
	* Main text
	*-------------------

	* Figure 1 -- Average Learning (2000-2017)
	*----------

	use "../analysis data/map.dta", replace
	spmap hlo using "../raw data/worldcoor2.dta" if ADMIN!="Antarctica", id(id) fcolor(Blues2) legstyle(2) clnumber(5) legend(symy(*1.5) symx(*1.5) size(*1.5) position(3) ring(.5)) legorder(lohi) 
	graph export "../output/Fig1.eps", replace
			
	* Figure 2a and 2b: Enrollment vs Learning by region, conditional on country-fixed effects
	*----------

    use "../analysis data/enroll_learning.dta",replace 
	
	preserve
	** country-fixed effects by region
	tsset code_num year
	levelsof region_num, local(region)
	foreach region in `region' {
	areg pri year if region_num == `region', absorb(code_num)
	predict pri_`region' if region_num == `region', xb
	}
	egen pri2 = rowmean(pri_*)
	collapse pri pri2, by(region year)
    keep if year <= 2010
	replace pri2 = round(pri2,.1)

	// 2a - Enrollment
	#delimit ;
	graph twoway 
        lfit pri2 year if region == "North America", lwidth(.5) ||
		lfit pri2 year if region == "East Asia & Pacific", lwidth(.5) ||
		lfit pri2 year if region == "Europe & Central Asia", lwidth(.5)||
		lfit pri2 year if region == "Latin America & Caribbean", lpattern(dash)  lwidth(.5) ||
		lfit pri2 year if region == "Middle East & North Africa", lwidth(.5)  ||
		lfit pri2 year if region == "Sub-Saharan Africa", lpattern(dash)  lwidth(.5) ||
		scatter pri2 year if region == "North America" & year == 2000, mlabel(pri2) msymbol(p) mcolor(black) mlabpos(12) || 
		scatter pri2 year if region == "East Asia & Pacific" & year == 2000, mlabel(pri2) msymbol(p) mcolor(gray) mlabpos(6) ||
		scatter pri2 year if region == "Europe & Central Asia" & year == 2000, msymbol(p) ||
		scatter pri2 year if region == "Latin America & Caribbean" & year == 2000, msymbol(p) ||
		scatter pri2 year if region == "Middle East & North Africa" & year == 2000, mlabel(pri2) msymbol(p) mcolor(pink*.8) mlabpos(12) ||
		scatter pri2 year if region == "Sub-Saharan Africa" & year == 2000, mlabel(pri2) msymbol(p) mcolor(orange) mlabpos(6) ||
		scatter pri2 year if region == "North America" & year == 2010 , msymbol(p) mlabel(pri2) mcolor(black) mlabpos(12) || 
		scatter pri2 year if region == "East Asia & Pacific" & year == 2010, msymbol(p) mlabel(pri2) msymbol(p) mcolor(gray) mlabpos(6) ||
		scatter pri2 year if region == "Europe & Central Asia" & year == 2010,  msymbol(p)||
		scatter pri2 year if region == "Latin America & Caribbean" & year == 2010,  msymbol(p)||
		scatter pri2 year if region == "Middle East & North Africa" & year == 2010, mlabel(pri2) msymbol(p) mcolor(pink*.8) mlabpos(3) ||
		scatter pri2 year if region == "Sub-Saharan Africa" & year == 2010, mlabel(pri2) msymbol(p) mcolor(orange) mlabpos(12) ||
	,legend( order(1 "North America"  2 "East Asia and Pacific" 3 "Europe & Central Asia"  4 "LAC"  5 "MENA" 6 "SSA") bmargin(medium) region(fcolor(gs15%50))) 
	ytitle("Primary Enrollment Rate")
	xscale(r(2000(5)2010))
    xlabel(2000(5)2010)
    yscale(r(75(5)100))
    ylabel(75(5)100)
    xtitle("Year") 
	legend(off)
	name(figure2a, replace)
	;
	#delimit cr
	
	// 2b - Learning
	
	restore
	
	** country-fixed effects by region
	tsset code_num year
	levelsof region_num, local(region)
	foreach region in `region' {
	areg hlo year i.code_num if region_num == `region', absorb(code_num)
	predict hlo_`region' if region_num == `region', xb
	}
	egen hlo2 = rowmean(hlo_*)
	collapse hlo2 hlo, by(region year)
	replace hlo2 = round(hlo2, .1)
	
	#delimit ;
	graph twoway 
        lfit hlo2 year if region == "North America", lwidth(.5) ||
		lfit hlo2 year if region == "East Asia & Pacific", lwidth(.5) ||
		lfit hlo2 year if region == "Europe & Central Asia", lwidth(.5)||
		lfit hlo2 year if region == "Latin America & Caribbean", lpattern(dash) lwidth(.5) ||
		lfit hlo2 year if region == "Middle East & North Africa", lwidth(.5)  ||
		lfit hlo2 year if region == "Sub-Saharan Africa", lwidth(.5) lpattern(dash) ||
		scatter hlo2 year if region == "North America" & year == 2000, mlabel(hlo2) msymbol(p) mcolor(black) mlabpos(12) || 
		scatter hlo2 year if region == "East Asia & Pacific" & year == 2000, mlabel(hlo2) msymbol(p) mcolor(gray) mlabpos(6) ||
		scatter hlo2 year if region == "Europe & Central Asia" & year == 2000, mlabel(hlo2) msymbol(p) mcolor(blue*.8) mlabpos(9) ||
		scatter hlo2 year if region == "Latin America & Caribbean" & year == 2000, mlabel(hlo2) msymbol(p) mcolor(green) mlabpos(12) ||
		scatter hlo2 year if region == "Middle East & North Africa" & year == 2000, mlabel(hlo2) msymbol(p) mcolor(pink*.8) mlabpos(12) ||
		scatter hlo2 year if region == "Sub-Saharan Africa" & year == 2000, mlabel(hlo2) msymbol(p) mcolor(orange) mlabpos(6) ||
		scatter hlo2 year if region == "North America" & year == 2015, mlabel(hlo2) msymbol(p) mcolor(black) mlabpos(12) || 
		scatter hlo2 year if region == "East Asia & Pacific" & year == 2015, mlabel(hlo2) msymbol(p) mcolor(gray) mlabpos(3) ||
		scatter hlo2 year if region == "Europe & Central Asia" & year == 2015, mlabel(hlo2) msymbol(p) mcolor(blue*.8) mlabpos(6) ||
		scatter hlo2 year if region == "Latin America & Caribbean" & year == 2015, mlabel(hlo2) msymbol(p) mcolor(green) mlabpos(12) ||
		scatter hlo2 year if region == "Middle East & North Africa" & year == 2015, mlabel(hlo2) msymbol(p) mcolor(pink*.8) mlabpos(12) ||
		scatter hlo2 year if region == "Sub-Saharan Africa" & year == 2015, mlabel(hlo2) msymbol(p) mcolor(orange) mlabpos(6) ||
	,legend(order(1 "North America"  2 "East Asia and Pacific" 3 "Europe & Central Asia"  4 "LAC"  5 "MENA" 6 "SSA") bmargin(medium) pos(6) row(2) region(fcolor(gs15%50))) 
	ytitle("Learning in Primary School")   
    xtitle("Year")   
    yscale(r(200(100)700))
    ylabel(200(100)700)
	name(figure2b, replace)
	;

	#delimit cr

	// combined
	grc1leg figure2a figure2b, legendfrom(figure2b) 
	graph export "../output/Fig2.eps", replace

	*-----------------------------------------------------
	*-----------------------------------------------------
	
	* Table 1 and Extended Data Table 2 -- Development Accounting
	*----------

	eststo clear
	use "../analysis data/dev_account_analysis.dta",replace

		egen xtile = xtile(gdp_per_cap_2000), n(4)
		gen ln_gdp = log(cgdpo_per_cap) 
		gen ln_hc = log(hc) 

		sum hlo
		local sd: di %4.3f `r(sd)'
		replace hlo = hlo/`sd' // put in terms of standard deviations

		// values of w (return to learning): 0, .15, .2, .25, values of r (return to schooling): .1
		gen D_0 = exp(BL*.1)
		gen D_15 = exp(BL*.1+hlo*.15)
		gen D_20 = exp(BL*.1+hlo*.2)
		gen D_25 = exp(BL*.1+hlo*.25)

		egen den = sd(ln_gdp) 
		bys incomegroup: egen den_income = sd(ln_gdp) 
		bys region_code: egen den_reg = sd(ln_gdp) 

	eststo clear
	foreach var in D_0 D_15 D_20 D_25 {
				
        gen ln_`var' = log(`var') 
		egen num_`var' = sd(ln_`var') 
        bys incomegroup: egen num_income_`var' = sd(ln_`var') 
        bys region_code: egen num_reg_`var' = sd(ln_`var') 

		egen x90_`var' = pctile(`var') if ~missing(`var') & ~missing(cgdpo_per_cap), p(90) 
		egen x10_`var' = pctile(`var') if ~missing(`var') & ~missing(cgdpo_per_cap), p(10) 
		egen y90_`var' = pctile(cgdpo_per_cap) if ~missing(`var') & ~missing(cgdpo_per_cap), p(90)
		egen y10_`var' = pctile(cgdpo_per_cap) if ~missing(`var') & ~missing(cgdpo_per_cap), p(10) 
        
		gen stat1_`var' = (x90_`var'/x10_`var')
		gen stat2_`var' = (x90_`var'/x10_`var')/(y90_`var'/y10_`var')
        gen stat3_`var' = num_`var'^2/den^2
		gen stat4_`var' = (ln(x90_`var') -ln(x10_`var'))/(ln(y90_`var')-ln(y10_`var'))
       
	   	eststo stat_`var': estpost sum stat*_`var'

        bys incomegroup: gen stat_inc_`var' = num_income_`var'^2/den_income^2
        bys region_code: gen stat_reg_`var' = num_reg_`var'^2/den_reg^2

        eststo inc_`var': estpost tabstat stat_inc_`var', by(incomegroup) stat(mean) nototal
        eststo reg_`var': estpost tabstat stat_reg_`var', by(region_code) stat(mean) nototal
		
		lab var stat1_`var' "h90/h10"
		lab var stat2_`var' "h90/h10 / y90/y10"
		lab var stat3_`var' "var(log(h)/var(log(y)"
		lab var stat4_`var' "ln(h90)-ln(h10) / ln(y90)-ln(y10)"
		}

	** Table 1
	esttab stat* using "../output/Table1.csv", cells("mean(fmt(2))") label replace noobs collabels(, none) mtitles("w=0" "w=.15" "w=.2" "w=.25") nonumbers

	** Extended Data Table 2
	esttab inc* using "../output/ExtData_Table2.csv", cells("mean(fmt(2))") label nodepvar replace noobs collabels(, none) mtitles("w=0" "w=.15" "w=.2" "w=.25")
	esttab reg* using "../output/ExtData_Table2.csv", cells("mean(fmt(2))") label nodepvar append noobs collabels(, none) nomtitles nonumbers varlabels(1 "Advanced Economies" 2 "East Asia and the Pacific" 3 "Europe and Central Asia" 4 "Latin America and the Caribbean" 5 "Middle East and North Africa" 6 "South Asia" 7 "Sub-Saharan Africa" )

	* Table 2 - comparing measures of human capital and economic growth
	* ------------- 

	eststo clear
	use "../analysis data/comparingmeasures.dta",replace
	
	replace annual_growth_rate = annual_growth_rate/100 
	gen log_hlo = log(hlo)
	gen log_BL = log(BL_edu_avg_2000_2010)
	gen log_hc = log(hc)
	gen log_hdi = log(y2000)

	lab var log_hlo "Human Capital - Harmonized Learning Outcomes"
	lab var log_hc "Human Capital - Penn World Tables"
	lab var log_BL "Human Capital - Schooling from Barro-Lee"
	lab var log_hdi "Human Capital - Human Development Index"
	lab var annual_growth_rate "Growth"

	foreach growth in annual_growth_rate {
    eststo HLO: reg `growth' log_hlo gdp_per_cap_2000
	eststo PWT: reg `growth' log_hc gdp_per_cap_2000
   	eststo Schooling: reg `growth' log_BL gdp_per_cap_2000
    eststo HDI: reg `growth' log_hdi gdp_per_cap_2000
    eststo HLO_pwt:  reg `growth' log_hlo log_hc gdp_per_cap_2000
	eststo HLO_BL: reg `growth' log_hlo log_BL gdp_per_cap_2000
    eststo HLO_HDI: reg `growth' log_hlo log_hdi gdp_per_cap_2000
    eststo all: reg `growth' log_hlo log_hc log_BL log_hdi gdp_per_cap_2000
	}
	esttab using "../output/Table2.csv", drop(gdp_per_cap_2000 _cons) stats(N r2, fmt(0 3) labels("Observations" "R-Squared")) collabels(, none) cells(b(fmt(3)) se(par fmt(3)) p(par([ ]) fmt(3))) lines se depvar nocons noobs fragment label noomit nobaselevels replace starlevels( * 0.10 ** 0.05 *** 0.010)

	*-------------------------
	* Extended Data 
	*-------------------------

	* Extended Data Table 1 - Country-year observations by disaggregation and region in full metadata
	*-------------------------
	
	use "../raw data/HLO_database.dta", replace
 
    keep hlo* code year sourcetest n_res subject region level

	egen Total = total(!missing(hlo)), by(region)
	egen Female = total(!missing(hlo_f)), by(region)
	egen Male = total(!missing(hlo_m)), by(region)
	egen Math = total(!missing(hlo) & subject == "math"), by(region)
	egen Reading = total(!missing(hlo) & subject == "reading"), by(region)
	egen Science = total(!missing(hlo) & subject == "science"), by(region)
	egen Primary = total(!missing(hlo) & level == "pri"), by(region)
	egen Secondary = total(!missing(hlo) & level == "sec"), by(region)
	lab var Female "By Gender"
	
	eststo clear
	local vars Total Female Math Reading Science Primary Secondary
	bys region: eststo: estpost summarize `vars'
	esttab using "../output/ExtData_Table1.csv", collabels(, none) cells("mean(fmt(a3))") label nodepvar replace noobs

	
	* Extended Data Figure 1 - Years of Schooling vs Learning in the Cross-Section
	*-------------------------
	
	use "../raw data/hci_otherdata.dta", replace
		rename wbcode code
		merge m:m code using "../analysis data/hlo_disag.dta"
		keep if level == "pri"
		
		* average primary learning and schooling from 2000 onwards
		collapse expectedyearsofschool hlo, by(code country level)
		replace country = "Vietnam" if country == "Viet Nam"
		replace country = "Tanzania" if country == "Tanzania, United Republic of"
		
		corr hlo expectedyearsofschool if expectedyearsofschool <10 
		corr hlo expectedyearsofschool if expectedyearsofschool >=10 

		gen hlo_r = round(hlo,.1)
		gen expectedyearsofschool_r = round(expectedyearsofschool,.1)
		gen hlo_s = string(hlo_r)
		gen expectedyearsofschool_s = string(expectedyearsofschool_r)
		gen label = country+" ("+expectedyearsofschool_s+","+hlo_s+")"

		graph twoway fpfit hlo expectedyearsofschool, lpattern(dash) lcolor(*.5) || scatter hlo expectedyearsofschool, mcolor(navy*.25) || scatter hlo expectedyearsofschool if country == "Kenya" | country == "Ghana" | country == "Zambia" | country == "Spain" | country == "South Africa" | country == "South Africa" | country == "Philippines" | country == "Tanzania" | country == "Brazil" , mcolor(maroon) mlabel(label) ytitle("Primary Learning") xtitle("Expected Years of School") legend(off) xlabel(4(1)15)
		graph export "../output/ExtData_Fig1.eps", replace


	* Extended Data Figure 2 - Learning by year and region controlling for country-fixed effects and enrollment
	*-------------------------
	
	use "../analysis data/enroll_learning.dta",replace
	
	lab var hlo "Learning"
	lab var pri "Schooling"
	
	** regression: enrollment and learning
	replace pri = pri[_n-1] if code[_n] == code[_n-1] & pri == .
	reg hlo pri i.code_num if (code != "MOZ" & code != "BEN" & code != "CMR" & code != "NER") // exclude 4 outliers with enrollment gains outliers above the 95th percentile in enrolment changes, which can bias average cross-country trends

	** figure 2
	use "../analysis data/enroll_learning.dta",replace
	replace pri = pri[_n-1] if code[_n] == code[_n-1] & pri == .
	
	lab var hlo "Learning"
	lab var pri "Schooling"
	
	** country-fixed effects by region
	tsset code_num year
	levelsof region_num, local(region)
	foreach region in `region' {
	areg hlo year pri i.code_num if region_num == `region', absorb(code_num)
	predict hlo_`region' if region_num == `region', xb
	}
	egen hlo2 = rowmean(hlo_*)
	collapse hlo2 hlo, by(region year)
	replace hlo2 = round(hlo2,.1)
	

	#delimit ;
	graph twoway 
        lfit hlo2 year if region == "North America", lwidth(.5) ||
		lfit hlo2 year if region == "East Asia & Pacific", lwidth(.5) ||
		lfit hlo2 year if region == "Europe & Central Asia", lwidth(.5)||
		lfit hlo2 year if region == "Latin America & Caribbean", lpattern(dash) lwidth(.5) ||
		lfit hlo2 year if region == "Middle East & North Africa", lwidth(.5)  ||
		lfit hlo2 year if region == "Sub-Saharan Africa", lpattern(dash) lwidth(.5) ||
		scatter hlo2 year if region == "North America" & year == 2000, mlabel(hlo2) msymbol(p) mcolor(black) mlabpos(12) || 
		scatter hlo2 year if region == "East Asia & Pacific" & year == 2000, mlabel(hlo2) msymbol(p) mcolor(gray) mlabpos(6) ||
		scatter hlo2 year if region == "Europe & Central Asia" & year == 2000, mlabel(hlo2) msymbol(p) mcolor(blue*.8) mlabpos(6) ||
		scatter hlo2 year if region == "Latin America & Caribbean" & year == 2000, mlabel(hlo2) msymbol(p) mcolor(green) mlabpos(12) ||
		scatter hlo2 year if region == "Middle East & North Africa" & year == 2000, mlabel(hlo2) msymbol(p) mcolor(pink*.8) mlabpos(12) ||
		scatter hlo2 year if region == "Sub-Saharan Africa" & year == 2000, mlabel(hlo2) msymbol(p) mcolor(orange) mlabpos(6) ||
		scatter hlo2 year if region == "North America" & year == 2015, mlabel(hlo2) msymbol(p) mcolor(black) mlabpos(12) || 
		scatter hlo2 year if region == "East Asia & Pacific" & year == 2015, mlabel(hlo2) msymbol(p) mcolor(gray) mlabpos(2) ||
		scatter hlo2 year if region == "Europe & Central Asia" & year == 2015, mlabel(hlo2) msymbol(p) mcolor(blue*.8) mlabpos(6) ||
		scatter hlo2 year if region == "Latin America & Caribbean" & year == 2015, mlabel(hlo2) msymbol(p) mcolor(green) mlabpos(12) ||
		scatter hlo2 year if region == "Middle East & North Africa" & year == 2015, mlabel(hlo2) msymbol(p) mcolor(pink*.8) mlabpos(12) ||
		scatter hlo2 year if region == "Sub-Saharan Africa" & year == 2015, mlabel(hlo2) msymbol(p) mcolor(orange) mlabpos(6) ||
	,legend( order(1 "North America"  2 "East Asia and Pacific" 3 "Europe & Central Asia"  4 "LAC"  5 "MENA" 6 "SSA") bmargin(medium) region(fcolor(gs15%50))) 
    xtitle("Year")   
    yscale(r(200(100)700))
    ylabel(200(100)700)
    ytitle("")
	;
	graph export "../output/ExtData_Fig2.eps", replace;
	#delimit cr

	* Extended Figure 3 -- Example Countries comparing schooling and learning
	*-------------------
		
	use "../analysis data/enroll_learning.dta",replace
	collapse hlo pri, by(year code country)
	sort country year
	replace hlo = round(hlo, .1)

		#delimit ;
		graph twoway 
			lfit hlo year if country == "Mexico", lwidth(.5) ||
			lfit hlo year if country == "Colombia", lwidth(.5) ||
			lfit hlo year if country == "Brazil", lwidth(.5)||
			lfit hlo year if country == "Uganda", lpattern(dash) lwidth(.5) ||
			lfit hlo year if country == "Kuwait", lwidth(.5) ||
			scatter hlo year if country == "Mexico" & year == 2000, mlabel(hlo) msymbol(p) mlabpos(12) ||
			scatter hlo year if country == "Colombia" & year == 2000, mlabel(hlo) msymbol(p) mlabpos(12) ||
			scatter hlo year if country == "Brazil" & year == 2000, mlabel(hlo) msymbol(p)  mlabpos(12) ||
			scatter hlo year if country == "Uganda" & year == 2000, mlabel(hlo) msymbol(p)  mlabgap(2) mlabpos(6) ||
			scatter hlo year if country == "Kuwait" & year == 2000, mlabel(hlo) msymbol(p) mlabpos(6) ||
			scatter hlo year if country == "Mexico" & year == 2015, mlabel(hlo) msymbol(p) mlabpos(12) ||
			scatter hlo year if country == "Colombia" & year == 2015, mlabel(hlo) msymbol(p) mlabpos(1) ||
			scatter hlo year if country == "Brazil" & year == 2015, mlabel(hlo) msymbol(p)  mlabpos(3) ||
			scatter hlo year if country == "Uganda" & year == 2015, mlabel(hlo) msymbol(p) mlabpos(12) ||
			scatter hlo year if country == "Kuwait" & year == 2015, mlabel(hlo) msymbol(p)  mlabpos(6) ||
				,legend(order(1 "Mexico" 2 "Colombia" 3 "Brazil" 4 "Uganda" 5 "Kuwait") pos(4)) 
		ytitle("Learning in Primary School")   
		xtitle("Year")   
		yscale(r(200(100)600))
		ylabel(200(100)600)
		legend(off)
		name(extfig3a, replace)
		;
		
	#delimit ;
	graph twoway 
		lfit pri year if country == "Mexico", lwidth(.5) ||
		lfit pri year if country == "Colombia", lwidth(.5) ||
		lfit pri year if country == "Brazil", lwidth(.5) ||
		lfit pri year if country == "Uganda", lwidth(.5) ||
		lfit pri year if country == "Kuwait", lwidth(.5) ||
		scatter pri year if country == "Mexico" & year == 2000, mlabel(pri) msymbol(p) mlabgap(3)  mlabpos(6) ||
		scatter pri year if country == "Colombia" & year == 2000, mlabel(pri) msymbol(p) mlabpos(12) ||
		scatter pri year if country == "Mexico" & year == 2010, mlabel(pri) msymbol(p) mlabgap(1) mlabpos(6) ||
			,legend(order(1 "Mexico" 2 "Colombia" 3 "Brazil" 4 "Uganda" 5 "Kuwait") row(2) pos(6)) 
    ytitle("Primary Enrollment Rate")   
    xtitle("Year")
	    xlabel(2000(5)2010)
	yscale(r(50(5)100))
    ylabel(50(5)100)
	name(extfig3b, replace)
	;
	
	grc1leg extfig3b extfig3a, legendfrom(extfig3b);
	graph export "../output/ExtData_Fig3.eps", replace;
	#delimit cr

	* Extended Data Figure 4 -- Comparison of HLO and IRT robustness
	*----------------------
	
	use "../analysis data/lincs_robustness.dta", replace
	
	foreach var in hlo L_SCORE {
		replace `var' = round(`var',.01)
		}

	corr L_SCORE hlo
	local corr: di %4.3f r(rho)
	
	#delimit;
	graph twoway lfit L_SCORE hlo, lpattern(dash) xscale(r(350(50)550)) xlabel(350(50)550) ylabel(350(50)550) 
				|| scatter L_SCORE hlo,
		ytitle("IRT Score")
		xtitle("HLO Score")
		subtitle("Correlation `corr'", position(4) ring(0) margin(small) size(small) box fcolor(white))
		xscale(r(350(50)550))
		xlabel(350(50)550)
		ylabel(350(50)550 365)
		legend(off);
		graph export "../output/ExtData_Fig4.eps", replace;

