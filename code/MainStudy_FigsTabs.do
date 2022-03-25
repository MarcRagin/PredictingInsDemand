********************************************************************************
*
* Coinsurance Demand Project, 2019
* Johannes Jaspersen, Marc Ragin, Justin Sydnor
* Code to create figures and summ stats/correlation tables
* 
********************************************************************************

* Start with cleaned wide dataset, which includes parameter estimates
use "$datapath/MainAllLong_merged.dta", clear

* Label variables
la var uc_gain 		"UC^{+}"
la var uc_loss 		"UC^{-}"
la var pw_gain 		"PW^{+}"
la var pw_loss 		"PW^{-}"
la var loss_av 		"LA"
la var cert_ef 		"CP"
la var uc_g_p 		"\gamma^{+}"
la var uc_l_p 		"\gamma^{-}"
la var pw_g_p 		"\beta^{+}"
la var pw_l_p 		"\beta^{-}"
la var la_p 	 	"\lambda"
la var la_index1	"\hat{\lambda}"
la var ce_p 		"\hat{\kappa}"	

* Demographics summary stats table
la var elicitwrong 		"Dummy for pref task instr wrong"
la var inswrong 		"Dummy for ins task instr wrong"
la var violate_fosd 	"Dummy for made $\ge 1$ FOSD choice"
la var numviolate_fosd 	"Num times violated FOSD"
la var fu_understand 	"Understanding score"
replace numviolate_fosd = . if violate_fosd == 0
eststo uw: 		estpost summarize age female us_dummy white black asian latino grq pmt violate_fosd numviolate_fosd elicitwrong inswrong fu_understand if mturk == 0 & ins_qid == 1
eststo mturk: 	estpost summarize age female us_dummy white black asian latino grq pmt violate_fosd numviolate_fosd elicitwrong inswrong fu_understand if mturk == 1 & ins_qid == 1
eststo all: 	estpost summarize age female us_dummy white black asian latino grq pmt violate_fosd numviolate_fosd elicitwrong inswrong fu_understand if ins_qid == 1
esttab using "$outpath/SummStatsDemog", cells("mean(fmt(2)) sd(fmt(2))") ///
	csv replace label star(* 0.1 ** 0.05 *** 0.01) ///
	mlabels(none) nodepvar nonum nolines noobs

* Education summary stats
levelsof education, local(levels) 
foreach l of local levels {
	gen educ`l' = 0
	replace educ`l' = 1 if education == `l'
}
la var educ1 "\hspace{5pt}Less than high school"
la var educ2 "\hspace{5pt}High school graduate"
la var educ3 "\hspace{5pt}Some college, no degree"
la var educ4 "\hspace{5pt}Associate's college degree"
la var educ5 "\hspace{5pt}Bachelor's college degree"
la var educ6 "\hspace{5pt}Master's degree"
la var educ8 "\hspace{5pt}Professional degree (JD, MD)"
la var educ7 "\hspace{5pt}Doctoral degree"
eststo clear
eststo uw: 		estpost summarize educ1-educ8 if mturk == 0 & ins_qid == 1
eststo mturk: 	estpost summarize educ1-educ8 if mturk == 1 & ins_qid == 1
eststo all: 	estpost summarize educ1-educ8 if ins_qid == 1
esttab using "$outpath/SummStatsEduc", cells("mean(fmt(2))") ///
	csv replace label star(* 0.1 ** 0.05 *** 0.01) ///
	mlabels(none) nodepvar nonum nolines noobs ///
	extracols(2 3 4)

* Income summary stats (note: only asked MTurk subjects about income)
levelsof income, local(levels)
foreach l of local levels {
	gen inc`l' = 0
	replace inc`l' = 1 if income == `l'
}
la var inc0 "\hspace{5pt}Less than 5,000"
la var inc5 "\hspace{5pt}5,000--9,999"
la var inc10 "\hspace{5pt}10,000--24,999"
la var inc25 "\hspace{5pt}25,000--49,999"
la var inc50 "\hspace{5pt}50,000--74,999"
la var inc75 "\hspace{5pt}75,000--99,999"
la var inc100 "\hspace{5pt}100,000--149,999"
la var inc150 "\hspace{5pt}150,000 or greater"
eststo clear
eststo uw: 		estpost summarize inc0-inc150 if mturk == 0 & ins_qid == 1
eststo mturk: 	estpost summarize inc0-inc150 if mturk == 1 & ins_qid == 1
eststo all: 	estpost summarize inc0-inc150 if ins_qid == 1
esttab using "$outpath/SummStatsIncome", cells("mean(fmt(2))") ///
	csv replace label star(* 0.1 ** 0.05 *** 0.01) ///
	mlabels(none) nodepvar nonum nolines noobs ///
	extracols(2 3 4)
drop educ1-educ8 inc0-inc150

* Nonparametric preference scale histograms
local size "ysize(1.5) xsize(2)"
local title "xtitle(`""') ytitle(`""')"
hist uc_gain, start(0) width(1) frac discrete xlab(0(4)32, labsize(vlarge)) ylab(, labsize(vlarge)) `size' `title' title(`"{fontface "Cambria Math": Utility curvature gains (UC{sup:+})}"', size(vhuge))
graph export "$outpath/HistUCG.png", replace
hist uc_loss, start(0) width(1) frac discrete xlab(0(4)32, labsize(vlarge)) ylab(, labsize(vlarge)) `size' `title' title(`"{fontface "Cambria Math": Utility curvature losses (UC{sup:{&minus}})}"', size(vhuge))
graph export "$outpath/HistUCL.png", replace
hist pw_gain, start(-16) width(1) frac discrete xlab(-16(4)16, labsize(vlarge)) ylab(, labsize(vlarge)) `size' `title' title(`"{fontface "Cambria Math": Prob. weighting gains (PW{sup:+})}"', size(vhuge))
graph export "$outpath/HistPWG.png", replace
hist pw_loss, start(-16) width(1) frac discrete xlab(-16(4)16, labsize(vlarge)) ylab(, labsize(vlarge)) `size' `title' title(`"{fontface "Cambria Math": Prob. weighting losses (PW{sup:{&minus}})}"', size(vhuge))
graph export "$outpath/HistPWL.png", replace
hist loss_av, start(0) width(1) frac discrete xlab(0(4)21, labsize(vlarge)) ylab(, labsize(vlarge)) `size' `title' title(`"{fontface "Cambria Math": Loss aversion (LA)}"', size(vhuge))
graph export "$outpath/HistLA.png", replace
hist cert_ef, start(-16) width(1) frac discrete xlab(-16(4)16, labsize(vlarge)) ylab(, labsize(vlarge)) `size' `title' title(`"{fontface "Cambria Math": Certainty preference (CP)}"', size(vhuge))
graph export "$outpath/HistCP.png", replace
graph close _all

* Parametric preference parameter histograms
local size "ysize(1.5) xsize(2)"
local title "xtitle(`""') ytitle(`""')"
hist uc_g_p, bin(25) frac xlab(, labsize(vlarge)) ylab(, labsize(vlarge)) `size' `title' title(`"{fontface "Cambria Math": Utility curvature gains ({&gamma}{superscript:+})}"', size(vhuge))
graph export "$outpath/HistUCG_P.png", replace
hist uc_l_p, bin(25) frac xlab(, labsize(vlarge)) ylab(, labsize(vlarge)) `size' `title' title(`"{fontface "Cambria Math": Utility curvature losses ({&gamma}{superscript:{&minus}})}"', size(vhuge))
graph export "$outpath/HistUCL_P.png", replace
hist pw_g_p, bin(25) frac xlab(, labsize(vlarge)) ylab(, labsize(vlarge)) `size' `title' title(`"{fontface "Cambria Math": Prob. weighting gains ({&beta}{superscript:+})}"', size(vhuge))
graph export "$outpath/HistPWG_P.png", replace
hist pw_l_p, bin(25) frac xlab(, labsize(vlarge)) ylab(, labsize(vlarge)) `size' `title' title(`"{fontface "Cambria Math": Prob. weighting losses ({&beta}{superscript:{&minus}})}"', size(vhuge))
graph export "$outpath/HistPWL_P.png", replace
hist la_index1 if la_index1 <= 11.11, bin(25) frac xlab(, labsize(vlarge)) ylab(, labsize(vlarge)) `size' `title' title(`"{fontface "Cambria Math":Loss aversion (`=ustrunescape("\u03BB\u0302")')}"', size(vhuge))
graph export "$outpath/HistLAindex1_P.png", replace
hist ce_p if ce_p >= -2 & ce_p <= 2, bin(25) frac xlab(, labsize(vlarge)) ylab(, labsize(vlarge)) `size' `title' title(`"{fontface "Cambria Math":Certainty preference (`=ustrunescape("\u03BA\u0302")')}"', size(vhuge))
graph export "$outpath/HistCP_P.png", replace
graph close _all

* Summary stats for preferences
* Nonparametric by location
eststo clear
estpost tabstat uc_gain pw_gain cert_ef uc_loss pw_loss loss_av if ins_qid == 1, ///
				by(mturk) s(mean p50) c(s)	
esttab . using "$outpath/SummStatsNP_byloc", ///
	csv replace fragment label  varlabels() ///
	cells((mean(label(Mean ) fmt(%9.2f)) p50(label(Median ) fmt(%9.2f)))) ///
	mlabels(none) nodepvar nonum nolines noobs unstack	
	
* Parametric by location
eststo clear
estpost tabstat uc_g_p pw_g_p ce_p uc_l_p pw_l_p la_index1 if ins_qid == 1, ///
				by(mturk) s(mean p50) c(s)	
esttab . using "$outpath/SummStatsP_byloc", ///
	csv replace fragment label  varlabels() ///
	cells((mean(label(Mean ) fmt(%9.2f)) p50(label(Median ) fmt(%9.2f)))) ///
	mlabels(none) nodepvar nonum nolines noobs unstack	


********************************************************************************
* Histograms of coinsurance choices								
********************************************************************************
gen coins100 = round(coins*100)
forvalues i = 1/12 {
	qui su ploss if ins_qid == `i'
	local p = `r(mean)'
	qui su lambda if ins_qid == `i'
	local q = `r(mean)'
	local q2 = round(`q'/100, 0.01)
	di `q2'
	cap drop coins_P`p'_L`q'
	egen coins_P`p'_L`q' = cut(coins100) if ins_qid == `i', at(0(10)110)
	qui tab coins_P`p'_L`q', sort matcell(freq)
	local freq = freq[1,1]/1730
	local freq = cond(round(`freq', 0.1) < `freq', round(`freq', 0.1)+0.1, round(`freq', 0.1))
	di `freq'
	//local step = cond(`freq'>=0.3, 0.1, 0.05)
	hist coins_P`p'_L`q', start(0) width(10) discrete frac ///
		xlab(0(20)100, tlw(thick) labsize(huge)) xmtick(10(20)90, tstyle(major) tlw(thick) nolab) title("") ///
		xtitle("Coverage level (%)", margin(small) size(vhuge)) ///
		ylab(0(0.1)`freq', labsize(huge)) ytitle("") ///
		title("p = `p'%, q = `q2'", size(vhuge)) ///
		name(coins`i', replace) ysize(2) xsize(4) plotregion(margin(l-2))
	graph export "$outpath/coins_P`p'_L`q'.png", name(coins`i') replace
	graph close	
}
cap drop coins_P*

********************************************************************************	
* Correlation tables
********************************************************************************	
use "$datapath/RegressionData", clear
* Create correlation matrices
local par1 "st_uc_gain st_pw_gain st_cert_ef st_uc_loss st_pw_loss st_loss_av"
local par2 "st_uc_g_p st_pw_g_p st_ce_p st_uc_l_p st_pw_l_p st_la_index1"
forvalues p = 1/2 {
	pwcorr `par`p'' if ins_qid == 1
	mat par`p'corr = r(C)
	local col = colsof(par`p'corr)
	local par`p'names: rownames par`p'corr
	local l2 ""
	foreach v in `par`p'names' {
		local l1: var lab `v'
		local l2 "`l2' `l1'"
	}
	di "`l2'"
	mat par`p'corrout = J(`col',`col',.)
	forvalues r = 1/`col' {
		forvalues c = 1/`col' {
			local input = cond(`r'>=`c', par`p'corr[`r',`c'], .)
			mat par`p'corrout[`r',`c'] = `input'
		}
	}
	mat rownames par`p'corrout = `par`p'names'
	mat list par`p'corrout, nohalf
	esttab m(par`p'corrout, fmt(%9.3fc)) using "$outpath/par`p'_Corr", ///
		csv replace fragment label  varlabels() compress nogaps ///
		nodep nocon nonum nolines
	sleep 3000
}

	esttab m(par1corrout, fmt(%9.3fc)) using "$outpath/par1_Corr", ///
		csv replace label compress nogaps nodep nocon nonum nolines ///
		collabels("UC_{std}^{+}" "PW_{std}^{+}" "CP_{std}" "UC_{std}^{-}" "PW_{std}^{-}" "LA_{std}")
		
	la var st_uc_g_p 	"Utility curvature gains"
	la var st_uc_l_p 	"Utility curvature losses"
	la var st_pw_g_p 	"Probability weighting gains"
	la var st_pw_l_p 	"Probability weighting losses"
	la var st_la_index1	"Loss aversion index"
	la var st_ce_p 		"Certainty preference"	
	esttab m(par2corrout, fmt(%9.3fc)) using "$outpath/par2_Corr", ///
		csv replace label compress nogaps nodep nocon nonum nolines ///
		collabels("\gamma_{std}^{+}" "\beta_{std}^{+}" "\hat{\kappa}_{std}" "\gamma_{std}^{-}" "\beta_{std}^{-}" "\hat{\lambda}_{std}")

********************************************************************************
* Demand curves
********************************************************************************
use "$datapath/MainAllLong_merged.dta", clear
* Make coinsurance a whole number
replace coins = coins*100

* Label variable values
tab ploss
la de p 5 "P = 5%" 10 "P = 10%" 20 "P = 20%" 40 "P = 40%" 70 "P = 70%"
la val ploss p

tab lambda
la de load 80 "Load = 0.80" 100 "Load = 1.00" 125 "Load = 1.25" 150 "Load = 1.50" 250 "Load = 2.50"
la val lambda load

tab ins_qid
tabstat coins, s(mean p50 min max sd n) by(ins_qid)
egen m_coins = mean(coins), by(ins_qid)
la var m_coins "Mean coverage choice"

gen plabel = ""
replace plabel = "p = 5%" if ploss == 5 & lambda == 150
replace plabel = "p = 10%" if ploss == 10 & lambda == 100
replace plabel = "p = 20%" if ploss == 20 & lambda == 125
replace plabel = "p = 40%" if ploss == 40
replace plabel = "p = 70%" if ploss == 70 & lambda == 80

egen tag = tag(ins_qid)

sort lambda
replace lambda = lambda / 100
format lambda %5.2f		

*** Observed insurance demand ***
tw 	(connected m_coins lambda if tag & ploss == 10, msymbol(O) mcolor(black) msize(medlarge) lcolor(black) lwidth(thick) lpattern(solid) mlabel(plabel) mlabposition(7) mlabsize(medium)) ///
	(connected m_coins lambda if tag & ploss == 20, msymbol(O) mcolor(gs8) msize(medlarge) lcolor(gs8) lwidth(thick) lpattern(solid) mlabel(plabel) mlabposition(12) mlabsize(medium)) ///
	(connected m_coins lambda if tag & ploss == 40, msymbol(O) mcolor(black) msize(medlarge) lcolor(black) lwidth(thick) lpattern(solid) mlabel(plabel) mlabposition(2) mlabsize(medium)) ///
	(connected m_coins lambda if tag & ploss == 70, msymbol(O) mcolor(black) msize(medlarge) lcolor(black) lwidth(thick) lpattern(solid) mlabel(plabel) mlabposition(7) mlabsize(medium)) ///
	(connected m_coins lambda if tag & ploss == 5, msymbol(O) mcolor(gs8) msize(medlarge) lcolor(gs8) lwidth(thick) lpattern(dashed) mlabel(plabel) mlabposition(6) mlabsize(medium)), ///
	/* title("Observed insurance demand", size(vlarge)) */ xtitle(, size(large)) ytitle(, size(large)) ///
	ylab(30(15)75, nogrid labsize(medlarge)) xlab(, nogrid labsize(medlarge)) ysize(3) xsize(5) legend(off) 
	graph export "$outpath/DemandCurveMean.png", replace width(1200)
	graph close
	graph drop _all	
	
*** Predicted vs. observed demand ***
* Calculate mean coverage level for each model
local predicts "cpt1_nlib cpt2_all_loss eut1 eut2 rdeu1 rdeu2 kr dt1 dt2 ev_ce eut_g_ce eut_l_ce rdeu_g_ce rdeu_l_ce dt_g_ce dt_l_ce"
foreach v in `predicts' {
	local label: variable label `v'
	local label = subinstr("`label'", "EUT", "EU", .)
	local label = subinstr("`label'", "Pred: ", "", .)
	replace `v' = round(`v'*100, 1)
	egen m_`v' = mean(`v'), by(ins_qid)
	la var m_`v' "Mean predicted: `label'"
}
la var m_coins "Observed"
la var m_kr "KR"
la var m_eut2 "EU{sup: {bf:{&minus}}}"
la var m_rdeu2 "RDEU{sup: {bf:{&minus}}}"
la var m_ev_ce "EV{sub:{bf:CP}}"
la var m_cpt2_all_loss "All others"

* Demand over loading factor (holding p=10%)
sort lambda
local p = 10
qui su lambda if ploss == `p'
local loadmin = `r(min)'
local loadmax = min(`r(max)', 2.5)
local loadstep = round((`loadmax'-`loadmin')/5, 0.05)
tw 	(connected m_coins 		lambda if tag & ploss == `p', msymbol(diamond) msize(medium) lpattern(solid) lwidth(medthick) lcolor(black) mcolor(black)) ///
	(connected m_kr		 	lambda if tag & ploss == `p', msymbol(Oh) msize(medium) lpattern(solid) lwidth(medium) lcolor(gs6) mcolor(gs6)) ///
	(connected m_eut2 		lambda if tag & ploss == `p', msymbol(Dh) msize(medium) lpattern(solid) lwidth(medium) lcolor(gs6) mcolor(gs6)) ///
	(connected m_rdeu2 		lambda if tag & ploss == `p', msymbol(Th) msize(medium) lpattern(solid) lwidth(medium) lcolor(gs6) mcolor(gs6)) ///
	(connected m_ev_ce 		lambda if tag & ploss == `p', msymbol(Sh) msize(medium) lpattern(solid) lwidth(medium) lcolor(gs6) mcolor(gs6)) ///
	(line m_cpt2_all_loss 	lambda if tag & ploss == `p', lpattern(solid) lwidth(medium) lcolor(gs12)) ///
	(line m_eut1 			lambda if tag & ploss == `p', lpattern(solid) lwidth(medium) lcolor(gs12)) ///
	(line m_rdeu1 			lambda if tag & ploss == `p', lpattern(solid) lwidth(medium) lcolor(gs12)) ///
	(line m_cpt1_nlib		lambda if tag & ploss == `p', lpattern(solid) lwidth(medium) lcolor(gs12)) ///
	(line m_dt1 			lambda if tag & ploss == `p', lpattern(solid) lwidth(medium) lcolor(gs12)) ///
	(line m_dt2 			lambda if tag & ploss == `p', lpattern(solid) lwidth(medium) lcolor(gs12)) ///
	(line m_rdeu_g_ce 		lambda if tag & ploss == `p', lpattern(solid) lwidth(medium) lcolor(gs12)) ///
	(line m_rdeu_l_ce		lambda if tag & ploss == `p', lpattern(solid) lwidth(medium) lcolor(gs12)), ///
	scheme(plotplainblind) legend(order(1 2 3 4 5 6) rows(2) position(6) size(medium)) ylab(0(10)100, gmin gmax) xlab(`loadmin'(`loadstep')`loadmax', gmax) title("Scenarios with p=10%", size(large)) ///
	subtitle("") xsize(3) ysize(4) ytitle("Mean coverage level", size(medlarge)) xtitle("Loading factor (q)", size(medlarge)) graphregion(margin(0 4 1 1)) name(p`p', replace)
	graph export "$outpath/DemandActPredProb`p'.png", replace name(p`p')
 	graph close

* Demand over loss prob (holding load=1.50)
sort ploss
tw 	(connected m_coins 		ploss if tag & lambda == 1.50, msymbol(diamond) msize(medium) lpattern(solid) lwidth(medthick) lcolor(black) mcolor(black)) ///
	(connected m_kr		 	ploss if tag & lambda == 1.50, msymbol(Oh) msize(medium) lpattern(solid) lwidth(medium) lcolor(gs6) mcolor(gs6)) ///
	(connected m_eut2 		ploss if tag & lambda == 1.50, msymbol(Dh) msize(medium) lpattern(solid) lwidth(medium) lcolor(gs6) mcolor(gs6)) ///
	(connected m_rdeu2 		ploss if tag & lambda == 1.50, msymbol(Th) msize(medium) lpattern(solid) lwidth(medium) lcolor(gs6) mcolor(gs6)) ///
	(connected m_ev_ce 		ploss if tag & lambda == 1.50, msymbol(Sh) msize(medium) lpattern(solid) lwidth(medium) lcolor(gs6) mcolor(gs6)) ///
	(line m_cpt2_all_loss 	ploss if tag & lambda == 1.50, lpattern(solid) lwidth(medium) lcolor(gs12)) ///
	(line m_eut1 			ploss if tag & lambda == 1.50, lpattern(solid) lwidth(medium) lcolor(gs12)) ///
	(line m_rdeu1 			ploss if tag & lambda == 1.50, lpattern(solid) lwidth(medium) lcolor(gs12)) ///
	(line m_cpt1_nlib		ploss if tag & lambda == 1.50, lpattern(solid) lwidth(medium) lcolor(gs12)) ///
	(line m_dt1 			ploss if tag & lambda == 1.50, lpattern(solid) lwidth(medium) lcolor(gs12)) ///
	(line m_dt2 			ploss if tag & lambda == 1.50, lpattern(solid) lwidth(medium) lcolor(gs12)) ///
	(line m_rdeu_g_ce 		ploss if tag & lambda == 1.50, lpattern(solid) lwidth(medium) lcolor(gs12)) ///
	(line m_rdeu_l_ce		ploss if tag & lambda == 1.50, lpattern(solid) lwidth(medium) lcolor(gs12)), ///
	scheme(plotplainblind) legend(order(1 2 3 4 5 6) rows(2) position(6) size(medium)) ylab(0(10)100, gmin gmax) xlab(5(5)40, gmax) title("Scenarios with q=1.50", size(large)) ///
	subtitle("") xsize(3) ysize(4) xtitle("Loss probability (p)", size(medlarge)) ytitle("Mean coverage level", size(medlarge)) graphregion(margin(0 4 1 1)) name(load150, replace)
	graph export "$outpath/DemandActPredLoad150.png", replace name(load150)
	graph close
	
