# Article

Jaspersen, J. G., Ragin, M. A., and Sydnor, J. R. (2022). Predicting insurance demand from risk attitudes. _Journal of Risk and Insurance_, 89(1), 63– 96.

- [Published version](https://onlinelibrary.wiley.com/doi/10.1111/jori.12342)
- [Manuscript](/2021_PredictingIns_JRI_Main.pdf)
- [Online appendix](/2021_PredictingIns_JRI_OnlineApp.pdf)

Funding from the Alfred P. Sloan foundation, Grant No. G-2016-7312

# Code and data

The only initial data files needed are MainAll_long.dta and MainAll_wide.dta. Everything else is created by the Stata and Matlab code.

### \_MasterDoFile.do
- Sets global filepaths for all Stata code.
- Runs all other Stata do-files (cleaner, analysis, etc.).

### MainStudy_cleaner.do
- This must be run before any of the other Stata do-files (other than \_MasterDoFile.do, which calls the cleaner first). Once this is run, the other do-files can be run in any order.
- Cleans and labels raw experiment data.
- Includes a shell script to run Matlab code for estimation of parameters and coinsurance predictions. Sometimes this freezes or takes a long time, so it may be best to comment it out and run the Matlab code separately.
- Merges raw experiment data with parameters and predictions estimated in Matlab.
- Outputs clean data in both "wide" format (mostly used for summary stats and graphics) and "long" format (mostly used for regressions).

### getparams_final_01.m
- Takes lottery choices in Excel format (created by MainStudy_cleaner.do) and estimates preference parameters.
- Calls functions from u.m, u_loss.m, and weightp2.m.
- Uses relative filepaths for input/output that may need to be changed.

### makepredictions_final_01.m
- Takes estimated preference parameters (created by getparams_final_01.m) and estimates coinsurance demand.
- Uses relative filepaths for input/output that may need to be changed.

### MainStudy_FigsTabs.do
- Creates...
  - Histograms of preference measures
  - Summary stats tables
  - Correlation tables
  - Demand curves

### MainStudy_Reg_Coins_Prefs.do
- Regresses actual coinsurance demand on preference measures, individually and jointly (Tables 5-7).

### MainStudy_HorseRace.do
- Creates "horse race" table comparing predictions of each model to actual insurance demand (Table 8).



