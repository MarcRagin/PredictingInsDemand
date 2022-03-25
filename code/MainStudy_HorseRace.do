********************************************************************************
*
* Coinsurance Demand Project, 2019
* Johannes Jaspersen, Marc Ragin, Justin Sydnor
* Code for horse race table
* 
********************************************************************************

* Start with cleaned wide dataset, which includes parameter estimates
use "$datapath/MainAllLong_merged.dta", clear

global predicts "ev eut1 eut2 dt1 dt2 kr rdeu1 rdeu2 cpt2 cpt1 ev_ce dt_g_ce dt_l_ce eut_g_ce eut_l_ce rdeu_g_ce rdeu_l_ce"

* Made actual demand between 0 and 100
replace coins = coins*100

* Rename CPT variables
ren cpt1_nlib cpt1
ren cpt2_all_loss cpt2

* Create expected value prediction
gen ev = ., before(cpt1)
replace ev = 1 if lambda == 80
replace ev = 0 if lambda > 100
replace ev = 0.5 if lambda == 100
replace ev = . if violate_fosd == 1
la var ev "EV"

* Make all predicted coins levels on a scale of 0 to 100
foreach pred in $predicts {
	local ti = upper("`pred'")
	local ti = subinstr("`ti'", "CPT1", "CPT^{NLIB}", .)
	local ti = subinstr("`ti'", "1", "^{+}", .)
	local ti = subinstr("`ti'", "2", "^{-}", .)
	local ti = subinstr("`ti'", "_G_CE", "_{CP}^{+}", .)
	local ti = subinstr("`ti'", "_L_CE", "_{CP}^{-}", .)
	local ti = subinstr("`ti'", "_CE", "_{CP}", .)
	di "`ti'"
	la var `pred' "`ti'"
	replace `pred' = `pred'*100
}
tabstat $predicts, s(min p25 p50 p75 max mean n) c(s)

keep subjectid ins_qid lambda ploss coins $predicts mturk violate_fosd
drop if violate_fosd == 1

* Generate overall average coinsurance level
tabstat coins, s(mean p50 n)
egen allavg = mean(coins)
tabstat allavg, s(mean p50 n)

* Generate conditional average coinsurance level
tabstat coins, s(mean p50 n) by(ins_qid)
egen scenavg = mean(coins), by(ins_qid)
tabstat scenavg, s(mean p50 n) by(ins_qid)

****************************
* PREDICTION SUMMARY STATS *
****************************
tabstat $predicts, s(mean) c(s) save
mat A = r(StatTotal)
mat CoinsMean = A'
mat list CoinsMean

tabstat $predicts, s(sd) c(s) save
mat B = r(StatTotal)
mat CoinsSD = B'
mat list CoinsSD

mat SummStats = CoinsMean, CoinsSD
mat list SummStats

*************************
* HORSE RACE - AVERAGES *
*************************
tempfile HorseRaceData
local tabhoa ""
local tabhsa ""
foreach pred in $predicts {
	* Dummies for model prediction is better than predicting overall average
	gen hoa_`pred' = 0
	replace hoa_`pred' = 0.5 if abs(`pred'-coins) == abs(allavg-coins)
	replace hoa_`pred' = 1 if abs(`pred'-coins) < abs(allavg-coins)
	la var hoa_`pred' "Dummy for model prediction better than predicting overall average"
	local tabhoa "`tabhoa' hoa_`pred'"
	
	* Dummies for model prediction is better than predicting scenario average
	gen hsa_`pred' = 0
	replace hsa_`pred' = 0.5 if abs(`pred'-coins) == abs(scenavg-coins)
	replace hsa_`pred' = 1 if abs(`pred'-coins) < abs(scenavg-coins)
	la var hsa_`pred' "Dummy for model prediction better than predicting scenario average"
	local tabhsa "`tabhsa' hsa_`pred'"
}
tabstat `tabhoa', s(mean) c(s)
tabstat `tabhsa', s(mean) c(s)
save `HorseRaceData', replace

******************************
* HORSE RACE - RANDOM CHOICE *
******************************
* Generate random choice and evaluate whether each model was better, repeat 1000 times
use `HorseRaceData', clear
local reps = 1000
* First iteration, set up temp variables/dataset
	tempfile randchoice
	qui gen rand = runiformint(0,100)
	qui gen randmean = rand
	foreach pred in $predicts {
		* Dummies for model prediction is better than random choice
		qui gen hrnd_`pred' = 0
		qui replace hrnd_`pred' = 0.5 if abs(`pred'-coins) == abs(rand-coins)
		qui replace hrnd_`pred' = 1 if abs(`pred'-coins) < abs(rand-coins)
	}
	qui drop rand
	qui save `randchoice', replace
* Iterations 2-1000, amend temp variables/dataset
	forvalues i = 2/`reps' {
		* Display status of loop replications
			local pct = abs((`i'/1000)*100)
			if `i' == 2 dis "Loop running: 0%" _continue
			if mod(`pct',10) == 0 & `i' != 1000 dis "...`pct'%" _continue
			if `i' == 1000 dis "...100%. DONE." _newline(1)
		
		qui use `randchoice', clear
		qui gen rand = runiformint(0,100)
		qui replace randmean = randmean + rand
		foreach pred in $predicts {
			* Dummies for model prediction is better than random choice
			qui replace hrnd_`pred' = hrnd_`pred' + 0.5 if abs(`pred'-coins) == abs(rand-coins)
			qui replace hrnd_`pred' = hrnd_`pred' + 1 if abs(`pred'-coins) < abs(rand-coins)
		}
		qui drop rand
		qui save `randchoice', replace
	}
* Calculate average number of times random choice was superior
	qui use `randchoice', clear
	foreach pred in $predicts {
		* Dummies for model prediction is better than random choice
		qui replace hrnd_`pred' = (hrnd_`pred'/`reps')
		la var hrnd_`pred' "Dummy for model better than random choice"
	}
	qui replace randmean = randmean/`reps'

* Create matrix of correlations
pwcorr ev coins
mat tempcorr = r(C)
mat HorseCorr = tempcorr[2,1]
mat rownames HorseCorr = ev
local predicts "eut1 eut2 dt1 dt2 kr rdeu1 rdeu2 cpt2 cpt1 ev_ce dt_g_ce dt_l_ce eut_g_ce eut_l_ce rdeu_g_ce rdeu_l_ce"
foreach pred in `predicts' {
	* Calculate mean of each horse race test for each predictive model
	qui pwcorr `pred' coins
	mat temprho = r(C)
	mat rho = temprho[2,1]
	mat rownames rho = `pred'
	mat HorseCorr = HorseCorr \ rho
	mat drop rho temprho
}	

* Create matrix of Kendall's Tau rank-order correlations
ktau ev coins
mat HorseRankCorr = r(tau_b)
mat rownames HorseRankCorr = ev
local predicts "eut1 eut2 dt1 dt2 kr rdeu1 rdeu2 cpt2 cpt1 ev_ce dt_g_ce dt_l_ce eut_g_ce eut_l_ce rdeu_g_ce rdeu_l_ce"
foreach pred in `predicts' {
	* Calculate mean of each horse race test for each predictive model
	qui ktau `pred' coins
	mat rho = r(tau_b)
	mat rownames rho = `pred'
	mat HorseRankCorr = HorseRankCorr \ rho
	mat drop rho
}
mat list HorseRankCorr, f(%9.3fc)
save `HorseRaceData', replace

* Create matrix of horse race results
tabstat hrnd_ev hoa_ev hsa_ev, s(mean) save
mat HorseRace = r(StatTotal)
mat rownames HorseRace = ev
local predicts "eut1 eut2 dt1 dt2 kr rdeu1 rdeu2 cpt2 cpt1 ev_ce dt_g_ce dt_l_ce eut_g_ce eut_l_ce rdeu_g_ce rdeu_l_ce"
foreach pred in `predicts' {
	* Calculate mean of each horse race test for each predictive model
	tabstat hrnd_`pred' hoa_`pred' hsa_`pred', s(mean) save
	mat hr = r(StatTotal)
	mat rownames hr = `pred'
	mat HorseRace = HorseRace \ hr
	mat drop hr
}
mat list HorseRace

* Make correlations first column of Horse Race results
mat HorseRaceTable = SummStats, HorseCorr, HorseRace
mat list HorseRaceTable

esttab m(HorseRaceTable, fmt(%9.2fc %9.2fc %9.3fc %9.3fc %9.3fc %9.3fc)) using "$outpath/HorseRace", ///
	csv replace fragment label  varlabels() compress nogaps ///
	nodep nocon nonum nolines

