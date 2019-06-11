clear
set matsize 11000
set more off

* Setup:
cd "Y:\Projekt\FM\Skatteelasticiteter\Speciale\data\endelig"
global data TAXSIM2016 // Ændr denne global for at specificere hvilket datasæt, der skal importeres. Her importeres de beregnede marginalsattesatser med afsæt i skattesimulatoren fra 2016. 
global data_dta ${data}.dta 
use ${data_dta}, clear

*Step 1: Restriktioner
keep if alder >=25 & alder <=55
keep if ear >=100000

*Step 2: Kvartiler
// Danner "qvarts"
gen qvarts=1
foreach i of num 1990/2013{
sum ear if tiar==`i', det
recode qvarts (1=2) if tiar==`i' & ear>=r(p25) & ear < r(p50)
sum ear if tiar==`i', det
recode qvarts (1=3) if tiar==`i' & ear>=r(p50) & ear < r(p75)
sum ear if tiar==`i', det
recode qvarts (1=4) if tiar==`i' & ear >= r(p75)
}
label var qvarts "første til fjerde kvartil"

*Step 3: Danner top_dummy manuelt, da det normalt gøres i sammenkoblingen af skattesimulatorprogrammer
gen top_dummy = 0
recode top_dummy (0=1) if skattebracket == "TB" | skattebracket == "TM" | skattebracket == "TT"

*Danner skattegrænser:
gen topskattegraense = 467300
gen bundskattegraense = 42000 //Over beskæftigelsesfradraget

**Starter med en række summeringer, der benyttes i Slutsky-ligningen:

*1) Skattepligtig indkomst
sum ear
bys top_dummy: sum ear
bys qvarts: sum ear

*2) Virtuel indkomst
sum virtuelindk_h1
sum virtuelindk_h1 if top_dummy==1
sum virtuelindk_h1 if top_dummy==0
bys qvarts: sum virtuelindk_h1

*3) Marginalskat på arbejde
sum tau_arb_h
sum tau_arb_h if top_dummy==1
sum tau_arb_h if top_dummy==0
bys qvarts: sum tau_arb_h

** Dernæst: beregner alpha, fordelingsparameteret, for topskatteydere på tværs af grupperne.
*1) alle
sum ear if ear>topskattegraense, det
gen gnsarb_alle = r(mean)
gen alpha_alle = (gnsarb_alle/(gnsarb_alle-topskattegraense))

*2) Top_dummy==1
sum ear if top_dummy==1 & ear>topskattegraense, det
gen gnsarb_top = r(mean)
gen alpha_top = (gnsarb_top/(gnsarb_top-topskattegraense))

*3) Top_dummy==0 ; benyttes  ikke.
sum ear if ear>topskattegraense & top_dummy==0, det
gen gnsarb_ikketop = r(mean)
gen alpha_ikketop = (gnsarb_ikketop/(gnsarb_ikketop-topskattegraense))

*4) For de fire kvartiler
foreach i of num 1/4{
sum ear if ear>topskattegraense & qvarts==`i', det
gen gnsarb_q`i' = r(mean)
gen alpha_q`i' = (gnsarb_q`i'/(gnsarb_q`i'-topskattegraense))
}

sum alpha_q* // fordelingsparametre for de fire kvartiler
sum alpha_ikketop // fordelingsparameteret for ikke-topskatteydere (som dog mht. topskattegrænsen ikke giver mening, da Yi<G fra Boks 5.1).
sum alpha_top // Fordelingsparameteret for alle topskatteydere mht. topskattegrænsen
sum alpha_alle // Fordelingsparameteret for hele populationen mht. topskattegrænsen

** Dernæst: beregner alpha, fordelingsparameteret, for bundskatteydere på tværs af grupperne.
*1) alle
sum ear if ear>bundskattegraense, det
gen gnsarb_b_alle = r(mean)
gen alpha_b_alle = (gnsarb_b_alle/(gnsarb_b_alle-bundskattegraense))

*2) Top_dummy==1
sum ear if top_dummy==1 & ear>bundskattegraense, det
gen gnsarb_b_top = r(mean)
gen alpha_b_top = (gnsarb_b_top/(gnsarb_b_top-bundskattegraense))

*3) Top_dummy==0 ; giver ikke nødv. mening.
sum ear if ear>bundskattegraense & top_dummy==0, det
gen gnsarb_b_ikketop = r(mean)
gen alpha_b_ikketop = (gnsarb_b_ikketop/(gnsarb_b_ikketop-bundskattegraense))

*4) For de fire kvartiler
foreach i of num 1/4{
sum ear if ear>bundskattegraense & qvarts==`i', det
gen gnsarb_b_q`i' = r(mean)
gen alpha_b_q`i' = (gnsarb_b_q`i'/(gnsarb_b_q`i'-bundskattegraense))
}

sum alpha_b_q* // fordelingsparametre for de fire kvartiler
sum alpha_b_ikketop // fordelingsparameteret for ikke-topskatteydere (som dog mht. topskattegrænsen ikke giver mening, da Yi<G fra Boks 5.1).
sum alpha_b_top // Fordelingsparameteret for alle topskatteydere mht. topskattegrænsen
sum alpha_b_alle // Fordelingsparameteret for hele populationen mht. topskattegrænsen
