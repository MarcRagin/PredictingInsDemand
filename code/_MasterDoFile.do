********************************************************************************
*
* Predicting insurance demand from risk attitudes
* Johannes Jaspersen, Marc Ragin, Justin Sydnor
* The Journal of Risk and Insurance, 2022
* 
********************************************************************************

do c:\ado\personal\profile.do 

global codepath			"Coinsurance Demand/analysis/code"
global datapath			"Coinsurance Demand/analysis/data"
global outpath			"Coinsurance Demand/analysis/output"

* Step 1: Clean up data, estimate preferences, make insurance demand predictions
do "$codepath/MainStudy_cleaner"
* This needs to be done before any of the other do-files, but the others can be run in any order once the cleaner has run.

* Summary statistics, correlation tables, histograms, demand curves
do "$codepath/MainStudy_FigsTabs"

* Regressions of insurance demand on parametric and non-parametric preferences
do "$codepath/MainStudy_Reg_Coins_Prefs"

* Horse race comparing actual to predicted demand
do "$codepath/MainStudy_HorseRace"