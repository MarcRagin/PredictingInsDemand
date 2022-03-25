********************************************************************************
*
* Coinsurance Demand Project, 2019
* Johannes Jaspersen, Marc Ragin, Justin Sydnor
* Cleaning raw data and creating variables
*
* 1,352 subjects via mTurk (3/15/2018 and 3/26/2018)
* 378 subjects in-person at UW-Madison (3/20/2018 - 3/22/2018)
* 
********************************************************************************

* Export data to estimate parameters in Matlab
use "$datapath/MainAll_long", clear

* Create simple dataset for Matlab analysis
keep subjectid coins ploss lambda violate_fosd uc1_nsafe uc2_nsafe ld1_nsafe ld2_nsafe la_nsafe ce_nsafe
order subjectid coins ploss lambda violate_fosd uc1_nsafe uc2_nsafe ld1_nsafe ld2_nsafe la_nsafe ce_nsafe
	
* Export to XLS so JJ can import to Matlab for parameter estimation
export excel using "$datapath/MainAll_long.xlsx", replace nolabel firstrow(var)

********************************************************************************
* Run Matlab code to get parameters and predictions
********************************************************************************
* These use the "shell" command to open Matlab and run the getparams_final_01 and makepredictions_final_01 scripts. Sometimes it freezes or takes a long time. Might be easier to comment this out and run the scripts separately once the MainAll_long.xlsx file is created (above).

* Estimate parametric prefs
shell matlab -nosplash -nodesktop -minimize -nodisplay -r "try; run('${codepath}\getparams_final_01.m'); catch; end; quit;" -wait

* Predict coinsurance demand
shell matlab -nosplash -nodesktop -minimize -nodisplay -r "try; run('${codepath}\makepredictions_final_01.m'); catch; end; quit;" -wait

********************************************************************************
* Merge cleaned data with parametric prefs, non-parametric prefs, and predicted 
* coinsurance levels
********************************************************************************
* Import parameter values calculated in Matlab
tempfile Params
import excel using "$datapath/Params.xls", firstrow case(l) clear
la var fosd 		"Matlab FOSD violator dummy"
la var fosd_data 	"Original FOSD violator dummy"
la var uc_g_p 		"UC P (gain domain)"
la var uc_l_p 		"UC P (loss domain)"
la var pw_g_p 		"Inv-S PW P (gain domain)"
la var pw_l_p 		"Inv-S PW P (gain domain)"
la var la_p   		"Loss aversion P"
la var la_index1	"Loss aversion P - avg ratio of utility"
la var la_index2	"Loss aversion P - avg ratio of slopes"
la var la_index3	"Loss aversion P - LA if risk neutral"
la var ce_p   		"Certainty pref P"

* Replace with missing if subject violated FOSD
local prefs "uc_g_p uc_l_p pw_g_p pw_l_p la_p la_index1 la_index2 la_index3 ce_p"
foreach p in `prefs' {
	replace `p' = . if fosd == 1
	list `p' if `p' == 99
}

* Winsorize loss aversion measures at 99th percentile
* LA
	su la_p, d
	winsor2 la_p, replace cuts(0 99)
	su la_p, d
* LA Index 1
	su la_index1, d
	winsor2 la_index1, replace cuts(0 99)
	su la_index1, d
	
* Winsorize certainty preference at 1st and 99th percentiles
	su ce_p, d
	winsor2 ce_p, replace cuts(1 99)
	su ce_p, d

* Adjust parametric measures to get same-sign coefficients
	* Replace parametric pw measures (\beta) with (2-\beta)
	replace pw_g_p = 2 - pw_g_p
	replace pw_l_p = 2 - pw_l_p
	* Replace parametric UC- measure (\gamma^{-}) with (-1*\gamma^{-})
	replace uc_l_p = -1 * uc_l_p

rename subject_id subjectid
save `Params', replace

* Import nonparametric scales calculated in Matlab
tempfile NonParams
import excel using "$datapath/NonParams.xls", firstrow case(l) clear
la var fosd 		"Matlab FOSD violator dummy"
la var fosd_data 	"Original FOSD violator dummy"
la var uc_g_np 		"UC NP (gain domain)"
la var uc_l_np 		"UC NP (loss domain)"
la var pw_g_np 		"Inv-S PW NP (gain domain)"
la var pw_l_np 		"Inv-S PW NP (loss domain)"
la var la_np 		"Loss aversion NP"
la var ce_np 		"Certainty pref NP"
rename fosd fosd_np
rename fosd_data fosd_data_np
rename subject_id subjectid
save `NonParams', replace

* Import predictions from nonparametric scales calculated in Matlab - 1% intervals
tempfile CoinsPredict
import excel using "$datapath/coins_predictions.xls", firstrow case(l) clear sheet("Sheet1")
la var cpt1_nlib 		"Pred: CPT - NLIB"
la var cpt2_all_loss 	"Pred: CPT - all loss"
la var eut1 			"Pred: EUT over gains"
la var eut2 			"Pred: EUT over losses"
la var rdeu1 			"Pred: RDEU over gains"
la var rdeu2 			"Pred: RDEU over losses"
la var kr 				"Pred: KR with linear utility"
la var dt1 				"Pred: Dual theory over gains"
la var dt2 				"Pred: Dual theory over losses"
la var ev_ce			"Pred: Expected value with CE"
la var eut_g_ce			"Pred: EUT over gains with CE"
la var eut_l_ce			"Pred: EUT over losses with CE"
la var rdeu_g_ce		"Pred: RDEU over gains with CE"
la var rdeu_l_ce		"Pred: RDEU over losses with CE"
la var dt_g_ce			"Pred: Dual theory over gains with CE"
la var dt_l_ce			"Pred: Dual theory over losses with CE"
rename subject_id subjectid
rename p ploss
* Change lambda and ploss to whole numbers for merge
replace lambda = round(lambda*100, 1)
replace ploss = round(ploss*100, 1)
save `CoinsPredict', replace

********************************************************************************
* Merge WIDE with parametric and non-parametric preferences
********************************************************************************
* Merge experiment data with parametric prefs estimated in Matlab
use "$datapath/MainAll_wide.dta", clear
cap drop uc_g_p uc_l_p pw_g_p pw_l_p la_p ce_p
merge 1:1 subjectid using `Params'
order uc_g_p uc_l_p pw_g_p pw_l_p la_p la_index* ce_p, after(cert_ef)
drop _merge

* Merge experiment data with nonparametric scales estimated in Matlab (as a check)
merge 1:1 subjectid using `NonParams'
order uc_g_np uc_l_np pw_g_np pw_l_np la_np ce_np, after(cert_ef)
* Check to make sure FOSD violators are correctly identified
tab violate_fosd fosd_np, m
tab violate_fosd fosd_data_np, m
drop _merge
gen ucg_NPcheck = cond(uc_gain == uc_g_np, 1, 0)
tab ucg_NPcheck, m
gen pwg_NPcheck = cond(pw_gain == pw_g_np, 1, 0)
tab pwg_NPcheck, m
gen ucl_NPcheck = cond(uc_loss == uc_l_np, 1, 0)
tab ucl_NPcheck, m
gen pwl_NPcheck = cond(pw_loss == pw_l_np, 1, 0)
tab pwl_NPcheck, m
gen la_NPcheck = cond(loss_av == la_np, 1, 0)
tab la_NPcheck, m
gen cp_NPcheck = cond(cert_ef == ce_np, 1, 0)
tab cp_NPcheck, m

* These all look consistent with Stata-estimated NP scales, so dropping the Matlab estimates
drop uc_g_np uc_l_np pw_g_np pw_l_np la_np ce_np *_NPcheck fosd_np fosd_data_np

label data "Clean data with estimated params (wide), saved $S_TIME $S_DATE"
save "$datapath/MainAllWide_merged", replace

********************************************************************************
* Merge LONG with parametric and non-parametric preferences and coins predictions
********************************************************************************
use "$datapath/MainAll_long.dta", clear
la var coins "Actual coinsurance level selected"
* First, merge m:1 with parametric preferences
merge m:1 subjectid using `Params'
order uc_g_p uc_l_p pw_g_p pw_l_p la_p la_index* ce_p, after(cert_ef)
tab violate_fosd fosd, m
tab violate_fosd fosd_data, m
drop _merge

* Second, merge m:1 with nonparametric preferences as a check
merge m:1 subjectid using `NonParams'
order uc_g_np uc_l_np pw_g_np pw_l_np la_np ce_np, after(cert_ef)
* Check to make sure FOSD violators are correctly identified
tab violate_fosd fosd_np, m
tab violate_fosd fosd_data_np, m
drop _merge
gen ucg_NPcheck = cond(uc_gain == uc_g_np, 1, 0)
tab ucg_NPcheck, m
gen pwg_NPcheck = cond(pw_gain == pw_g_np, 1, 0)
tab pwg_NPcheck, m
gen ucl_NPcheck = cond(uc_loss == uc_l_np, 1, 0)
tab ucl_NPcheck, m
gen pwl_NPcheck = cond(pw_loss == pw_l_np, 1, 0)
tab pwl_NPcheck, m
gen la_NPcheck = cond(loss_av == la_np, 1, 0)
tab la_NPcheck, m
gen cp_NPcheck = cond(cert_ef == ce_np, 1, 0)
tab cp_NPcheck, m
* These all look consistent with Stata-estimated NP scales, so dropping the Matlab estimates
drop uc_g_np uc_l_np pw_g_np pw_l_np la_np ce_np *_NPcheck fosd_np fosd_data_np

* Finally, merge on subject ID, ploss, and lambda
* Change lambda and ploss to whole numbers, since float gets weird
replace lambda = round(lambda*100, 1)
replace ploss = round(ploss*100, 1)

* Merge 1:1 with predicted coinsurance choice on Subject ID, loading, and ploss 
merge 1:1 subjectid lambda ploss using `CoinsPredict'
tab violate_fosd if _merge == 1
order coins cpt1_nlib-dt_l_ce, after(ce_p)
drop ins_decision_no _merge

label data "Clean data with estimated params and predictions (long), saved $S_TIME $S_DATE"
save "$datapath/MainAllLong_merged", replace

********************************************************************************
* Create dataset for regressions
********************************************************************************
* Start with cleaned wide dataset, which includes parameter estimates
use "$datapath/MainAllLong_merged.dta", clear

* Make coinsurance a whole number
replace coins = coins*100

* Create dummy for "high probability" losses
gen highprob = cond(ploss == 40 | ploss == 70, 1, 0)

* Create dummies for insurance question
forvalues i = 1/12 {
	gen insq`i' = 0
	replace insq`i' = 1 if ins_qid == `i'
	la var insq`i' "Insurance question dummy `i'"
}

* Standardize preference scales
local pscales "uc_gain uc_loss pw_gain pw_loss loss_av cert_ef uc_g_p uc_l_p pw_g_p pw_l_p la_p la_index1 la_index2 la_index3 ce_p"
	foreach p in `pscales' {
		egen st_`p' = std(`p')
	}

la var st_uc_gain 	"UC_{std}^{+}"
la var st_uc_loss 	"UC_{std}^{-}"
la var st_pw_gain 	"PW_{std}^{+}"
la var st_pw_loss 	"PW_{std}^{-}"
la var st_loss_av 	"LA_{std}"
la var st_cert_ef 	"CP_{std}"
la var st_uc_g_p 	"\gamma_{std}^{+}"
la var st_uc_l_p 	"\gamma_{std}^{-}"
la var st_pw_g_p 	"\beta_{std}^{+}"
la var st_pw_l_p 	"\beta_{std}^{-}"
la var st_la_p 	 	"\lambda_{std}"
la var st_la_index1	"\hat{\lambda}_{std}"
la var st_ce_p 		"\hat{\kappa}_{std}"

save "$datapath/RegressionData", replace	

* Erase temporary datasets
cap erase "${datapath}/coins_predictions.xls"
cap erase "${datapath}/for_predictions.csv"
cap erase "${datapath}/Params.xls"
cap erase "${datapath}/NonParams.xls"
cap erase "${datapath}/mainAll.mat"
cap erase "${datapath}/MainAll_long.xlsx"

