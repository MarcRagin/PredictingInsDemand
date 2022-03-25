********************************************************************************
*
* Coinsurance Demand Project, 2019
* Johannes Jaspersen, Marc Ragin, Justin Sydnor
* Code for regressions in paper
* 
********************************************************************************

* Start with "regression" dataset, which includes standardized prefs
use "$datapath/RegressionData", clear

* Regression of coinsurance on prob and load
gen double load = lambda/100
la var load "Loading factor"
	eststo clear
	eststo probload: reg coins ploss load, vce(cluster subjectid)
	esttab using "$outpath/ProbLoadReg", ///
		csv replace fragment label wide ///
		b(2) se(2) star(* 0.10 ** 0.05 *** 0.01) ///
		nogaps nodep nonum nolines  mlabels(none) collabels(none) ///
		stats(r2 N N_clust, labels("R2" "N choices" "N subjects") fmt(%7.2f %7.0f %7.0f))

* Regress EUT- prediction on prob and load, so we can compare coefficient on load (actual vs. predicted elasticity)
	reg coins ploss load if violate_fosd == 0, vce(cluster subjectid)
	gen eut_loss = eut2 * 100
	reg eut_loss ploss load, vce(cluster subjectid)
	drop eut_loss

* Regress coins on each preference seperately (with Sidak MHT adjustment)
* Nonparametric measures
	tempfile pvals
	clear
	gen pscale = ""
	gen pval1 = .
	save `pvals', replace
	use "$datapath/RegressionData", clear
	eststo clear
	local pscales "uc_gain pw_gain cert_ef uc_loss pw_loss loss_av"
	foreach p in `pscales' {
		use "$datapath/RegressionData", clear
		eststo np_`p': reg coins st_`p' i.ins_qid, vce(cluster subjectid)
		estadd local fe		 	"Scenario", replace
		estadd local clusterse 	"Subject", replace
		estadd local fosd 		"Yes", replace
		mat np = r(table)
		mat psidak_`p' = np[4,1...]
		mat rown psidak_`p' = sidak
		mat list psidak_`p'
		clear
		svmat psidak_`p', n(pval)
		gen pscale = "`p'"
		append using `pvals'
		save `pvals', replace
	}
	use `pvals', clear
	sort pval1
	gen k = (_N + 1) - _n
	gen sidak = 1 - (1 - pval1)^k
	replace  sidak = sidak[_n-1] if sidak[_n-1] > sidak in 2/L
	clist pscale pval1 k sidak
	save `pvals', replace
	local pscales "uc_gain pw_gain cert_ef uc_loss pw_loss loss_av"
	foreach p in `pscales' {
		mat list psidak_`p'
		use `pvals', clear
		drop if pscale != "`p'"
		mat psidak_`p'[1,1] = sidak[1]
		mat list psidak_`p'
		estadd matrix psidak = psidak_`p': np_`p'
	}
	use "$datapath/RegressionData", clear
	esttab np_* using "$outpath/RegCoinsPrefs_SingRHSnp", ///
		csv replace fragment label type varlabels() compress nogaps ///
		cells(b(fmt(2) star pval(psidak)) se(fmt(2) par)) drop(*ins_qid _cons) ///
		starlevels(* 0.10 ** 0.05 *** 0.01) ///
		nodep nocon mlabels(none) nomtitles nonum collabels(none) nolines ///
		stats(fosd fe clusterse r2 N N_clust, labels("FOSD violators" "Fixed effects" "Clustered SEs" "R2" "N choices" "N subjects") fmt(%~6s %~6s %~6s %7.2f %7.0f %7.0f))

* Parametric measures
	mat drop _all
	tempfile pvals
	clear
	gen pscale = ""
	gen pval1 = .
	save `pvals', replace
	use "$datapath/RegressionData", clear
	eststo clear
	local pscales "uc_g_p pw_g_p ce_p uc_l_p pw_l_p la_index1 "
	foreach p in `pscales' {
		use "$datapath/RegressionData", clear
		eststo p_`p': reg coins st_`p' i.ins_qid, vce(cluster subjectid)
		estadd local fe		 	"Scenario", replace
		estadd local clusterse 	"Subject", replace
		estadd local fosd 		"No", replace
		mat param = r(table)
		mat psidak_`p' = param[4,1...]
		mat rown psidak_`p' = sidak
		mat list psidak_`p'
		clear
		svmat psidak_`p', n(pval)
		gen pscale = "`p'"
		append using `pvals'
		save `pvals', replace
	}
	use `pvals', clear
	sort pval1
	gen k = (_N + 1) - _n
	gen sidak = 1 - (1 - pval1)^k
	replace  sidak = sidak[_n-1] if sidak[_n-1] > sidak in 2/L
	clist pscale pval1 k sidak
	save `pvals', replace
	local pscales "uc_g_p pw_g_p ce_p uc_l_p pw_l_p la_index1 "
	foreach p in `pscales' {
		mat list psidak_`p'
		use `pvals', clear
		drop if pscale != "`p'"
		mat psidak_`p'[1,1] = sidak[1]
		mat list psidak_`p'
		estadd matrix psidak = psidak_`p': p_`p'
	}
	use "$datapath/RegressionData", clear
	esttab p_* using "$outpath/RegCoinsPrefs_SingRHSp", ///
		csv replace fragment label type varlabels() compress nogaps ///
		cells(b(fmt(2) star pval(psidak)) se(fmt(2) par)) drop(*ins_qid _cons) ///
		starlevels(* 0.10 ** 0.05 *** 0.01) ///
		nodep nocon mlabels(none) nomtitles nonum collabels(none) nolines ///
		stats(fosd fe clusterse r2 N N_clust, labels("FOSD violators" "Fixed effects" "Clustered SEs" "R\textsuperscript{2}" "N choices" "N subjects") fmt(%~6s %~6s %~6s %7.2f %7.0f %7.0f))

********************************************************************************
*
* TABLE WITH NONPARAMETRIC AND PARAMETRIC ESTIMATIONS TOGETHER
*
********************************************************************************
gen st_ucg = st_uc_gain
la var st_ucg	"UC_{std}^{+} / \gamma_{std}^{+}"
gen st_ucl = st_uc_loss
la var st_ucl	"UC_{std}^{-} / \gamma_{std}^{-}"
gen st_pwg = st_pw_gain
la var st_pwg 	"PW_{std}^{+} / \beta_{std}^{+}"
gen st_pwl = st_pw_loss
la var st_pwl 	"PW_{std}^{-} / \beta_{std}^{-}"
gen st_lossav = st_loss_av
la var st_lossav 	"LA_{std} / \hat{\lambda}_{std}"
gen st_certpref = st_cert_ef
la var st_certpref 	"CP_{std} / \hat{\kappa}_{std}"

tempfile RegData2
save `RegData2', replace	

local reg1 "reg coins st_ucg st_ucl st_pwg st_pwl st_lossav st_certpref i.ins_qid, vce(cluster subjectid)"
local reg2 "reg coins st_ucg st_ucl c.st_pwg##i.highprob c.st_pwl##i.highprob st_lossav st_certpref i.ins_qid, vce(cluster subjectid)"
eststo clear
* List NP regressions to run
forvalues r = 1/2 {
	mat drop _all
	eststo prefreg`r': `reg`r''
	estadd local fe		 	"Scenario", replace
	estadd local clusterse 	"Subject", replace
	estadd local fosd 		"Yes", replace
	matrix pbonf_mat = e(b)
	matrix psidak_mat = e(b)
	* Calculate Bonferroni and Sidak-adjusted p-values
	parmest, norestore
	gen hyp = 1 - regexm(parm, "ins_qid")
	replace hyp = 0 if regexm(parm, "_cons") == 1
	qui su hyp
	gsort -hyp p
	tempname j
	qui gen `j' = `r(sum)'-_n+1
	qui gen double 	pbonf = min(p*`j',1) if _n==1
	qui replace    	pbonf = min(max(p*`j',pbonf[_n-1]),1) if _n > 1 & _n <= `r(sum)'
	qui replace		pbonf = p if hyp == 0
	qui replace		pbonf = 99 if p == .
	qui gen double 	psidak = min((1-(1-p)^(`j')),1) if _n==1
	qui replace    	psidak = min(max((1-(1-p)^(`j')),psidak[_n-1]),1) if _n > 1 & _n <= `r(sum)'
	qui replace		psidak = p if hyp == 0
	qui replace		psidak = 99 if p == .
	* Create matrix of adjusted p-values for each adjustment method
	local vars: colnames e(b)
	local pvals "pbonf psidak"
	foreach p in `pvals' {
		foreach v in `vars' {
			qui su `p' if parm == "`v'"
			local m = cond(`r(mean)' == 99, ., `r(mean)')
			matrix `p'_mat[1, colnumb(`p'_mat,"`v'")] = `m'
		}
		* Add adjusted p-values to stored estimates
		estadd matrix `p' = `p'_mat: prefreg`r'
	}
	use `RegData2', clear
}

replace st_ucg = st_uc_g_p
replace st_ucl = st_uc_l_p
replace st_pwg = st_pw_g_p
replace st_pwl = st_pw_l_p
replace st_lossav = st_la_index1
replace st_certpref = st_ce_p

save `RegData2', replace

local reg3 "reg coins st_ucg st_ucl st_pwg st_pwl st_lossav st_certpref i.ins_qid, vce(cluster subjectid)"
local reg4 "reg coins st_ucg st_ucl c.st_pwg##i.highprob c.st_pwl##i.highprob st_lossav st_certpref i.ins_qid, vce(cluster subjectid)"
* List NP regressions to run
forvalues r = 3/4 {
	mat drop _all
	eststo prefreg`r': `reg`r''
	estadd local fe		 	"Scenario", replace
	estadd local clusterse 	"Subject", replace
	estadd local fosd 		"No", replace
	matrix pbonf_mat = e(b)
	matrix psidak_mat = e(b)
	* Calculate Bonferroni and Sidak-adjusted p-values
	parmest, norestore
	gen hyp = 1 - regexm(parm, "ins_qid")
	replace hyp = 0 if regexm(parm, "_cons") == 1
	qui su hyp
	gsort -hyp p
	tempname j
	qui gen `j' = `r(sum)'-_n+1
	qui gen double 	pbonf = min(p*`j',1) if _n==1
	qui replace    	pbonf = min(max(p*`j',pbonf[_n-1]),1) if _n > 1 & _n <= `r(sum)'
	qui replace		pbonf = p if hyp == 0
	qui replace		pbonf = 99 if p == .
	qui gen double 	psidak = min((1-(1-p)^(`j')),1) if _n==1
	qui replace    	psidak = min(max((1-(1-p)^(`j')),psidak[_n-1]),1) if _n > 1 & _n <= `r(sum)'
	qui replace		psidak = p if hyp == 0
	qui replace		psidak = 99 if p == .
	* Create matrix of adjusted p-values for each adjustment method
	local vars: colnames e(b)
	local pvals "pbonf psidak"
	foreach p in `pvals' {
		foreach v in `vars' {
			qui su `p' if parm == "`v'"
			local m = cond(`r(mean)' == 99, ., `r(mean)')
			matrix `p'_mat[1, colnumb(`p'_mat,"`v'")] = `m'
		}
		* Add adjusted p-values to stored estimates
		estadd matrix `p' = `p'_mat: prefreg`r'
	}
	use `RegData2', clear
}

use "$datapath/RegressionData", clear
* Output regression results to tex file
esttab prefreg* using "$outpath/RegCoinsPrefsAll", ///
	csv replace fragment label  varlabels() ///
	cells(b(fmt(2) star pval(psidak)) se(fmt(2) par)) ///
	order(st_ucg st_pwg st_certpref st_ucl st_pwl st_lossav 1.highprob) drop(0.highprob 0.highprob#* *ins_qid _cons) ///
	substitute("highprob=1" "Prob > 40") ///
	starlevels(* 0.10 ** 0.05 *** 0.01) compress nogaps ///
	nodep nocon mlabels(none) collabels(none) interaction(" X ") lines ///
	stats(fosd fe clusterse r2 N N_clust, labels("FOSD violators" "Fixed effects" "Clustered SEs" "R\textsuperscript{2}" "N choices" "N subjects") fmt(%~6s %~6s %~6s %7.2f %7.0f %7.0f))
