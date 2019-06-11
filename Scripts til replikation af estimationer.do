/*   Samlet setup til at loade data ind.
     De angivne stier o.a. vil ikke fungere, da data findes på Den Ministerielle Lovmodel. Vi henviser til Kleven & Schultz' (2014) replikationsguide af datagrundlaget på https://github.com/specialeF19/specialeF19 */

clear
set matsize 11000
set more off

cd "Y:\Projekt\FM\Skatteelasticiteter\Speciale\data\"
global data sp_87_13_040419_LOENMV_13_fuld // Ændr denne global for at specificere hvilket datasæt, der skal importeres. Her er det sammenkobling af alle skattesimulatorer, samkoblet med baggrundsvariable fra RAS/BEF/lign. fra DST.
global data_dta ${data}.dta 
use ${data_dta}, clear
drop if tiar==1989 //Fjernes pga. observationerne alligevel ville blive trunkeret sfa. casewise-deletion i regressionerne, da vi lagger kovariater (eg. første år er 1990).
drop if arbstatus == 0
drop if overfor0==1 | overfor3==1
keep if arb >=100000
keep if alder >=25 & alder <=55

/*   Herefter følger en række omkodninger af variable, generering af labels mv. */

gen uddannelse = . 
foreach i of num 0/5{ 
recode uddannelse (.=`i') if udd`i' == 1
}

gen puddannelse=.
foreach i of num 0/5 {
recode puddannelse(.=`i') if pudd`i' == 1
}

gen etnicitet = 0
recode etnicitet (0=1) if etni == "01 Danmark" & ie_type == 1
recode etnicitet (0=2) if etni == "02 Vestlige lande" & ie_type == 2
recode etnicitet (0=3) if etni == "02 Vestlige lande" & ie_type == 3
recode etnicitet (0=4) if etni == "03 Ikke-vestlige lande" & ie_type== 2
recode etnicitet (0=5) if etni == "03 Ikke-vestlige lande" & ie_type== 3

gen petnicitet = 0
recode petnicitet (0=1) if petni == "01 Danmark" & pie_type == 1
recode petnicitet (0=2) if petni == "02 Vestlige lande" & pie_type == 2
recode petnicitet (0=3) if petni == "02 Vestlige lande" & pie_type == 3
recode petnicitet (0=4) if petni == "03 Ikke-vestlige lande" & pie_type== 2
recode petnicitet (0=5) if petni == "03 Ikke-vestlige lande" & pie_type== 3

gen startaar=.
foreach i of num 87/99 {
replace startaar= 1900+`i' if d`i'==1
}
foreach i of num 0/9 {
replace startaar= 2000+`i' if d0`i'==1
}
foreach i of num 10/13 {
replace startaar= 2000+`i' if d`i'==1
}

gen amt=0
foreach i of num 1/15 {
replace amt= `i' if amt`i'==1
}

gen pamt=0
foreach i of num 1/15 {
replace pamt= `i' if pamt`i'==1
}

gen pindere = 0
foreach i of num 0/9 {
replace pindere = `i' if pind`i'==1
}

gen qvarts=1 // Danner kvartilindikatorer:
foreach i of num 1990/2013 {
sum arb if tiar==`i', detail
recode qvarts (1=2) if tiar==`i' & arb>=r(p25) & arb < r(p50)
sum arb if tiar==`i', detail
recode qvarts (1=3) if tiar==`i' & arb>=r(p50) & arb < r(p75)
sum arb if tiar==`i', detail
recode qvarts (1=4) if tiar==`i' & arb >= r(p75)
}

label define kvartiler 1 "1. kvartil" /*
                    */ 2 "2. kvartil" /*
					*/ 3 "3. kvartil" /*
					*/ 4 "4. kvartil" /*
					*/ , modify 

label define etnicitet 1 "Dansker" /*
                */ 2 "Indvandrer fra vestligt land" /*
                */ 3 "Efterkommer fra vestligt land" /*
                */ 4 "Indvandrer fra ikke-vestligt land" /*
                */ 5 "Efterkommer fra ikke-vestligt land" /*
								*/ , modify
								
label define amter 1 "Københavns og Fredriksberg kommunne" /*
                */ 2 "Københavns amt" /*
                */ 3 "Fredriksborg amt" /*
                */ 4 "Roskilde amt" /*
                */ 5 "Vestsjællands amt" /*
                */ 6 "Storstrøms amt" /*
                */ 7 "Bornholms amt" /*
                */ 8 "Fyns amt" /*
                */ 9 "Sønderjyllands amt" /*
                */ 10 "Ribe amt" /*
                */ 11 "Vejle amt" /*
                */ 12 "Ringkøbing amt" /*
                */ 13 "Århus amt" /*
                */ 14 "Viborg amt" /*
                */ 15 "Nordjyllands amt" /*
                */ 0 "Ukendt amt" /*
				*/ , modify

recode pamt (0=.)
recode amt (0=.)
				
label define indere 0 "ingen info om industri" /*
                 */ 1 "skov, landbrug, fødevarer" /*
                 */ 2 "råstoffer" /*
				 */ 3 "Fremstilling/industri" /*
				 */ 4 "forsyning" /*
				 */ 5 "Bygge og anlæg" /*
				 */ 6 "handel, restauration, hotel" /*
				 */ 7 "Transport mv." /*
				 */ 8 "Finansielle ydelser og udledning mm." /*
				 */ 9 "Offentlige- og tjenesteydelser" /*
				 */ , modify

label define landsdele 1 "København" /*
                    */ 2 "Københavns omegn" /*
					*/ 3 "Nordsjælland" /*
					*/ 4 "Bornholm" /*
					*/ 5 "Østsjælland" /*
					*/ 6 "Vest- og Sydsjælland" /*
					*/ 7 "Fyn" /*
					*/ 8 "Sydjylland" /*
					*/ 9 "Østjylland" /*
					*/ 10 "Vestjylland" /*
					*/ 11 "Nordjylland" /*
					*/ , modify

label value qvarts kvartiler
label value landsdel landsdele
label value plandsdel landsdele
label value pindere indere
label value petnicitet etnicitet
label value etnicitet etnicitet
label value pamt amter
label value amt amter

label var qvarts "Indkomstkvartiler"
label var amt "Amter"
label var startaar "Startår"
label var pamt "amt i s-1"
label var etnicitet "Etnicitet"
label var puddannelse "LAGGET uddannelse 0-5"
label var petnicitet "LAGGET: Etnicitet"
label var ie_type "1=Dansker, 2=Indvandrer, 3=efterkommer"
label var pie_type "LAGGET: 1=Dansker, 2=Indvandrer, 3=efterkommer"
label var diffarb1 "Ændring i skattepligtig indkomst s"
label var diffarb3 "Ændring i skattepligtig indkomst s+3"
label var diffmtr_arb_h1 "Ændring i efterskatraten s"
label var diffmtr_arb_h3 "Ændring i efterskatraten s+3"
label var diffmtr_arb_h_iv1 "Mekanisk ændring i efterskatraten s"
label var diffmtr_arb_h_iv3 "Mekanisk ændring i efterskatraten s+3"
label var diffvir_h11 "Ændring i virtuel indkomst s"
label var diffvir_h13 "Ændring i virtuel indkomst s+3"
label var diffvir_h1_iv1 "Mekanisk ændring i virtuel indkomst s"
label var diffvir_h1_iv3 "Mekanisk ændring i virtuel indkomst s+3"
label var dlogarb2 "Ændring log arbejdsinkomst fra s-1 til s"
label var exp "Erfaring i år s"
label var pexp "LAGGET: Erfaring i år s-1"
label var exp2 "Erfaring i år s kvardreret"
label var pexp2 "LAGGET: Erfaring i år s-1 kvadreret"
label var bornu6 "Antal børn (0-6 år) hos forælderen i år s"
label var pbornu6 "LAGGET: Antal børn (0-6 år) hos forælderen i s-1"
label var born618 "Antal børn (6-18 år) hos forælderen i år s"
label var pborn618 "LAGGET: Antal børn (6-18 år) hos forælderen i s-1"
label var alder "Alder i år s"
label var palder "LAGGET: Alder i s-1"
label var alder2 "alder i år s kvadreret"
label var palder2 "LAGGET: alder i år s-1 kvadreret"
label var uddannelse "uddannelse 0-5"
label var gift "Gift i år s"
label var pgift "LAGGET: Gift i år s-1"
label var unem "Arbejdsløshedsrate i amtet i år s"
label var punem "LAGGET: Arbejdsløshedsrate i amt i s-1"
label var gdp "BNP-vækst i år s KILDE UKENDT!"
label var pgdp "LAGGET: BNP-vækst i s-1 (Ukendt kilde)"
label var mand "Mand"
label var pmand "LAGGET: Mand"
label var udd0 "Uoplyst"
label var udd1 "Ufaglært"
label var udd2 "Faglærte"
label var udd3 "Kort videregående uddannelse"
label var udd4 "Mellemlang videregående uddannelse"
label var udd5 "Lang videregående uddannelse"
label var amt1 "Københavns og Fredriksberg kommunne"
label var amt2 "Københavns amt"
label var amt3 "Fredriksborg amt"
label var amt4 "Roskilde amt"
label var amt5 "Vestsjællands amt"
label var amt6 "Storstrøms amt"
label var amt7 "Bornholms amt"
label var amt8 "Fyns amt"
label var amt9 "Sønderjyllands amt"
label var amt10 "Ribe amt"
label var amt11 "Vejle amt"
label var amt12 "Ringkøbing amt"
label var amt13 "Aarhus amt"
label var amt14 "Viborg amt"
label var amt15 "Nordjyllands amt"
label var ind0 "Ingen info om industri i år s"
label var ind1 "Industri i år s: Skov, landbrug, fødevare"
label var ind2 "Industri i år s: Råstof"
label var ind3 "Industri i år s: Fremstilling/industri"
label var ind4 "Industri i år s: Forsyning"
label var ind5 "Industri i år s: Bygge og anlæg"
label var ind6 "Industri i år s: Handel, restauration, hotel"
label var ind7 "Industri i år s: Transport mm."
label var ind8 "Industri i år s: Finansiel, udlejning mm."
label var ind9 "Industri i år s: Offentlig og tjenesteydelser"
label var d87 "Startår (s) 1987"
label var d88 "Startår (s) 1988"
label var d89 "Startår (s) 1989"
label var d90 "Startår (s) 1990"
label var d91 "Startår (s) 1991"
label var d92 "Startår (s) 1992"
label var d93 "Startår (s) 1993"
label var d94 "Startår (s) 1994"
label var d95 "Startår (s) 1995"
label var d96 "Startår (s) 1996"
label var d97 "Startår (s) 1997"
label var d98 "Startår (s) 1998"
label var d99 "Startår (s) 1999"
label var d00 "Startår (s) 2000"
label var d01 "Startår (s) 2001"
label var d02 "Startår (s) 2002"
label var d03 "Startår (s) 2003"
label var d04 "Startår (s) 2004"
label var d05 "Startår (s) 2005"
label var d06 "Startår (s) 2006"
label var d07 "Startår (s) 2007"
label var d08 "Startår (s) 2008"
label var d09 "Startår (s) 2009"
label var d10 "Startår (s) 2010"
label var d11 "Startår (s) 2011"
label var d12 "Startår (s) 2012"
label var d13 "Startår (s) 2013" // Seneste starår (pba. 3 år frem i tiden og datagrundlag stopper i 2016).
label var plogarb2 "Log lag(s-1) arbejdsindkomst"
label var arb "arbejdsindkomst år s"
label var parb "arbejdsindkomst lagged år s-1"
label var occ "0=arbløs, 1=lønmodt, 2=funktionær, 3=selvstændig"
label var pocc "LAGGET: 0=arbløs, 1=lønmodt, 2=funktionær, 3=selvstændig"
label var arbstatus "1=positiv arbindkomst, lagged og log-dif"
label var parbstatus "LAGGET: 1=positiv arbindk, lagged arbindk og log-dif arbindk"
label var kom "1/332 kommuner" // se startaar_kom for omdannelse til dummies.
label var pkom "LAGGET: 1/332 kommuner"
label var overfor0 "0/1 har modtaget overførselsindkomst s"
label var overfor3 "0/1 har modtaget overførselsindkomst s+3"
label var taxable "Desc: Skattepligtig indkomst?"
label var pindere "Industri i s-1"
label var broad "Desc: Bredt indkomstmål?"
label var per_income "Desc: Andet indkomstmål? Pers."
label var top_dummy "Desc: Betaler topskat i år s?"
label var mellem_dummy "Desc: Betaler mellemskat i år s?"
label var bund_dummy "Desc: Betaler bundskat i år s?"
label var notax_dummy "Desc: Betaler IKKE skat i år s?"
label var tt "topskat år s og s+3"
label var tm "topskat år s mellemskat s+3"
label var tb "topskat år s bundskat s+3"
label var tn "topskat år s ingen skat s+3"
label var mt "mellemskat år s topskat s+3"
label var mm "mellemskat år s og s+3"
label var mb "mellemskat år s bundskat s+3"
label var mn "mellemskat år s ingen skat s+3"
label var bt "bundskat år s topskat s+3"
label var bm "bundskat år s mellemskat s+3"
label var bb "bundskat år s og s+3"
label var bn "bundskat år s og ingen skat s+3"
label var nt "ingen skat år s topskat s+3"
label var nm "ingen skat år s mellemskat s+3"
label var nb "ingen skat år s bundskat s+3"
label var nn "ingen skat år s og s+3"
label var landsdel "Landsdele"
label var plandsdel "LAGGET: Landsdele"
label var etni "Etnicitet 1: DK, 2: Vestlige lande, 3: Ikke-vestlige lande"
label var partner "Er gift/registreret partnerskab i s? IKKE beskatning"
label var ppartner "LAGGET: Er gift/registreret partnerskab i s-1? IKKE beskatning"
label var pendler "Kommunekode IKKE lig bopælskode i s? = 1"
label var ppendler "Kommunekode IKKE lig bopælskode i s-1? = 1"
label var bk "Indenfor 2000 kr. af bundskattegrænse?" 
label var mk "Indenfor 2000 kr af mellemskatterænsen?"
label var tk "Indenfor 2000 kr af topskattegrænsen?"
label var kink "Indenfor 2000 kr af any kinks?"
label var indkomst "Desc: arb+apers+kap"
label var pudd0 "LAGGET: Uoplyst"
label var pudd1 "LAGGET: Ufaglært"
label var pudd2 "LAGGET: Faglærte"
label var pudd3 "LAGGET: Kort videregående uddannelse"
label var pudd4 "LAGGET: Mellemlang videregående uddannelse"
label var pudd5 "LAGGET: Lang videregående uddannelse"
label var pamt1 "LAGGET: Københavns og Fredriksberg kommunne"
label var pamt2 "LAGGET: Københavns amt"
label var pamt3 "LAGGET: Fredriksborg amt"
label var pamt4 "LAGGET: Roskilde amt"
label var pamt5 "LAGGET: Vestsjællands amt"
label var pamt6 "LAGGET: Storstrøms amt"
label var pamt7 "LAGGET: Bornholms amt"
label var pamt8 "LAGGET: Fyns amt"
label var pamt9 "LAGGET: Sønderjyllands amt"
label var pamt10 "LAGGET: Ribe amt"
label var pamt11 "LAGGET: Vejle amt"
label var pamt12 "LAGGET: Ringkøbing amt"
label var pamt13 "LAGGET: Aarhus amt"
label var pamt14 "LAGGET: Viborg amt"
label var pamt15 "LAGGET: Nordjyllands amt"
label var pind0 "LAGGET: Ingen info om industri i år s"
label var pind1 "LAGGET: Industri i år s: Skov, landbrug, fødevare"
label var pind2 "LAGGET: Industri i år s: Råstof"
label var pind3 "LAGGET: Industri i år s: Fremstilling/industri"
label var pind4 "LAGGET: Industri i år s: Forsyning"
label var pind5 "LAGGET: Industri i år s: Bygge og anlæg"
label var pind6 "LAGGET: Industri i år s: Handel, restauration, hotel"
label var pind7 "LAGGET: Industri i år s: Transport mm."
label var pind8 "LAGGET: Industri i år s: Finansiel, udlejning mm."
label var pind9 "LAGGET: Industri i år s: Offentlig og tjenesteydelser"
label var petni "LAGGET: Etnicitet (etni) s-1"

/* Herfra fortsættes med at konstruere globale makroer til outputs */
cd "Y:\projekt\FM\Skatteelasticiteter\Speciale\OUTPUTS"

global output_fuldmodel fuldmodel.tex /* Til estimation på alle */
global output_ikketopskat ikketopskat.tex /* Til estimation på ikke-topskatteydere */
global output_topskat topskat.tex /* Til estimation på topskatteydere */
global output_foerstekvartil foerstekvartil.tex /* Estimation på første indkomstkvartil */
global output_andenkvartil andenkvartil.tex /* Estimation på anden indkomstkvartil */
global output_tredjekvartil tredjekvartil.tex /* Estimation på tredje indkomstkvartil */
global output_fjerdekvartil fjerdekvartil.tex /* Estimation på fjerde indkomstkvartil */
global output_kvartilsplines kvartiler_kvartilsplines_M2.tex /* Etimation på alle kvartiler (kun model II) med kvartilsplines */
global output_udenmakro udenmakro.tex /* Estimation uden makroøonomiske variable, dvs kun på individuelt hierarkisk niveau */

/* Danner splines på tværs af alle estimationssamples: */
mkspline sp10plogarb 10=plogarb2, pctile /* For fuld sample */
mkspline ikketopsp10plogarb 10=plogarb2 if top_dummy==0, pctile /* For ikke-topskatteydere i basisåret */
mkspline topsp10plogarb 10=plogarb2 if top_dummy==1, pctile /* For topskatteydere */
mkspline ensp10plogarb 10=plogarb2 if qvarts==1, pctile /* For 1. kvartil */
mkspline tosp10plogarb 10=plogarb2 if qvarts==2, pctile /* For 2. kvartil */
mkspline tresp10plogarb 10=plogarb2 if qvarts==3, pctile /* For 3. kvartil */
mkspline firesp10plogarb 10=plogarb2 if qvarts==4, pctile /* For 4. kvartil */
mkspline ensp4plogarb 4=plogarb2 if qvarts==1, pctile /* For 1. kvartil med kvartilsplines */
mkspline tosp4plogarb 4=plogarb2 if qvarts==2, pctile /* For 2. kvartil med kvartilsplines */
mkspline tresp4plogarb 4=plogarb2 if qvarts==3, pctile /* For 3. kvartil med kvartilsplines */
mkspline firesp4plogarb 4=plogarb2 if qvarts==4, pctile /* For 4. kvartil med kvartilsplines */
do "D:\projekt\Skatteelasticiteter\STATA\labels til splines 10.do" /* Separat .do til spline labels - ikke nødvendigt */

/* Herfra følger en række modeller á følgende rækkefølge:
1) Den fulde population - estimation på fuld sample. 4 modeller.
2) Kun estimation på ikke-topskatteydere. 4 modeller.
3) Kun estimation på topskatteydere. 4 modeller.
4) 4x4 estimationer på de fire kvartiler.
5) Estimation på fire kvartiler (kun model II) med kvartilsplines.
6) Estimation på fuld sample kun med individniveau-variable (kun model II), dvs. ikke BNP-vækst, landsdel og lokal arbejdsløshed.
*/


/* første 4 modeller estimeret på fuld sample */


** 1.1: fuld sample. Alm estimation m. analytiske vægte. 
ivreg2 diffarb3 sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb], cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_fuldmodel}, replace ctitle("Alm.model") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

** 1.2: fuld sample. Alm estimation m. analytiske vægte, men med censurering af top 0,1% af indkomster.
_pctile arb, p(99.9) 
return list
gen percfoerstemodel == r(r1)

ivreg2 diffarb3 sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if arb < percfoerstemodel, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_fuldmodel}, append ctitle("M. censur") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

** 1.3: fuld sample. Alm. estimation men uden splines.
ivreg2 diffarb3 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb], cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_fuldmodel}, append ctitle("U. splines") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

** 1.4: fuld sample. Uden individer tæt på skatteknæk.
ivreg2 diffarb3 sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if kink==0, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_fuldmodel}, append ctitle("U. kinks") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))


/* Næste 4 modeller estimeret på samplen af ikke-skatteydere; dvs. top_dummy==0 */


** 2.1: uden topskatteydere. Alm estimation m. analytiske vægte. 
ivreg2 diffarb3 ikketopsp10plogarb1 ikketopsp10plogarb2 ikketopsp10plogarb3 ikketopsp10plogarb4 ikketopsp10plogarb5 ikketopsp10plogarb6 ikketopsp10plogarb7 ikketopsp10plogarb8 ikketopsp10plogarb9 ikketopsp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if top_dummy==0, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_ikketopskat}, replace ctitle("Alm.model") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

** 2.2: : u/ topskatteydere. Alm estimation m. analytiske vægte, men med censurering af top 0,1 indkomster.
_pctile arb if top_dummy==0, p(99.9) 
return list
gen percandenmodel == r(r1)

ivreg2 diffarb3 ikketopsp10plogarb1 ikketopsp10plogarb2 ikketopsp10plogarb3 ikketopsp10plogarb4 ikketopsp10plogarb5 ikketopsp10plogarb6 ikketopsp10plogarb7 ikketopsp10plogarb8 ikketopsp10plogarb9 ikketopsp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if arb < percandenmodel & top_dummy==0 , cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_ikketopskat}, append ctitle("M. censur") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

** 2.3: u/ topskatteydere. Alm. estimation  uden splines.
ivreg2 diffarb3 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if top_dummy==0, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_ikketopskat}, append ctitle("U. splines") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

** 2.4: u/ topskatteydere. Uden individer tæt på kinks.
ivreg2 diffarb3 ikketopsp10plogarb1 ikketopsp10plogarb2 ikketopsp10plogarb3 ikketopsp10plogarb4 ikketopsp10plogarb5 ikketopsp10plogarb6 ikketopsp10plogarb7 ikketopsp10plogarb8 ikketopsp10plogarb9 ikketopsp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if kink==0 & top_dummy==0, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_ikketopskat}, append ctitle("U. kinks") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))


/* Næste 4 modeller estimeret på samplen af topskatteydere, dvs. top_dummy==1 */


** 3.1: kun topskatteydere. Alm estimation m. analytiske vægte. 
ivreg2 diffarb3 topsp10plogarb1 topsp10plogarb2 topsp10plogarb3 topsp10plogarb4 topsp10plogarb5 topsp10plogarb6 topsp10plogarb7 topsp10plogarb8 topsp10plogarb9 topsp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if top_dummy==1, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_topskat}, replace ctitle("Alm.model") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

** 3.2: Kun topskatteydere. Alm estimation m. analytiske vægte, men med censurering af top 0,1 indkomster.
_pctile arb if top_dummy==1, p(99.9) 
return list
gen perctredjemodel == r(r1)

ivreg2 diffarb3 topsp10plogarb1 topsp10plogarb2 topsp10plogarb3 topsp10plogarb4 topsp10plogarb5 topsp10plogarb6 topsp10plogarb7 topsp10plogarb8 topsp10plogarb9 topsp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if arb < perctredjemodel & top_dummy==1 , cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_topskat}, append ctitle("M. censur") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

** 3.3: Kun topskatteydere. Alm. estimation men uden splines.
ivreg2 diffarb3 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if top_dummy==1, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_topskat}, append ctitle("U. splines") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

** 4.4: Kun topskatteydere. Uden individer tæt på kinks.
ivreg2 diffarb3 topsp10plogarb1 topsp10plogarb2 topsp10plogarb3 topsp10plogarb4 topsp10plogarb5 topsp10plogarb6 topsp10plogarb7 topsp10plogarb8 topsp10plogarb9 topsp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if kink==0 & top_dummy==1, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_topskat}, append ctitle("U. kinks") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))


/* Næste 16 modeller (4x4) er alle modeltyperne på de fire populationer af indkomstkvartiler */

*******************************************
*****          Første kvartil         *****
*******************************************

*Q1.1: Første indkomstkvartil, almindelig estimation m. analytiske vægte
ivreg2 diffarb3 ensp10plogarb1 ensp10plogarb2 ensp10plogarb3 ensp10plogarb4 ensp10plogarb5 ensp10plogarb6 ensp10plogarb7 ensp10plogarb8 ensp10plogarb9 ensp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if qvarts==1, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_foerstekvartil}, replace ctitle("Alm.model") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*Q1.2: Første indkomstkvartil, almindelig estimation m. analytiske vægte og censurering af top 0,1 indkomster
_pctile arb if qvarts==1, p(99.9) 
return list
gen q1perc == r(r1)

ivreg2 diffarb3 ensp10plogarb1 ensp10plogarb2 ensp10plogarb3 ensp10plogarb4 ensp10plogarb5 ensp10plogarb6 ensp10plogarb7 ensp10plogarb8 ensp10plogarb9 ensp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if arb < q1perc & qvarts==1 , cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_foerstekvartil}, append ctitle("M. censur") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*Q1.3: Første indkomstkvartil, estimation m. analytiske vægte uden splines.
ivreg2 diffarb3 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if qvarts==1, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_foerstekvartil}, append ctitle("U. splines") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*Q1.4: Første indkomstkvartil, almindelig estimation m. analytiske vægte uden individer tæt på skatteknæk
ivreg2 diffarb3 ensp10plogarb1 ensp10plogarb2 ensp10plogarb3 ensp10plogarb4 ensp10plogarb5 ensp10plogarb6 ensp10plogarb7 ensp10plogarb8 ensp10plogarb9 ensp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if kink==0 & qvarts==1, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_foerstekvartil}, append ctitle("U. kinks") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*******************************************
*****           Anden kvartil         *****
*******************************************

*Q2.1: Anden indkomstkvartil, almindelig estimation m. analytiske vægte
ivreg2 diffarb3 tosp10plogarb1 tosp10plogarb2 tosp10plogarb3 tosp10plogarb4 tosp10plogarb5 tosp10plogarb6 tosp10plogarb7 tosp10plogarb8 tosp10plogarb9 tosp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if qvarts==2, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_andenkvartil}, replace ctitle("Alm.model") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*Q2.2: Anden indkomstkvartil, almindelig estimation m. analytiske vægte og censurering af top 0,1 indkomster
_pctile arb if qvarts==2, p(99.9) 
return list
gen q2perc == r(r1)

ivreg2 diffarb3 tosp10plogarb1 tosp10plogarb2 tosp10plogarb3 tosp10plogarb4 tosp10plogarb5 tosp10plogarb6 tosp10plogarb7 tosp10plogarb8 tosp10plogarb9 tosp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if arb < q2perc & qvarts==2, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_andenkvartil}, append ctitle("M. censur") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*Q2.3: Anden indkomstkvartil, estimation m. analytiske vægte uden splines.
ivreg2 diffarb3 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if qvarts==2, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.
outreg2 using ${output_andenkvartil}, append ctitle("U. splines") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*Q2.4: Anden indkomstkvartil, almindelig estimation m. analytiske vægte uden individer tæt på skatteknæk
ivreg2 diffarb3 tosp10plogarb1 tosp10plogarb2 tosp10plogarb3 tosp10plogarb4 tosp10plogarb5 tosp10plogarb6 tosp10plogarb7 tosp10plogarb8 tosp10plogarb9 tosp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if kink==0 & qvarts==2, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_andenkvartil}, append ctitle("U. kinks") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))


*******************************************
*****          Tredje kvartil         *****
*******************************************


*Q3.1: Tredje indkomstkvartil, almindelig estimation m. analytiske vægte
ivreg2 diffarb3 tresp10plogarb1 tresp10plogarb2 tresp10plogarb3 tresp10plogarb4 tresp10plogarb5 tresp10plogarb6 tresp10plogarb7 tresp10plogarb8 tresp10plogarb9 tresp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if qvarts==3, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_tredjekvartil}, replace ctitle("Alm.model") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*Q3.2: Tredje indkomstkvartil, almindelig estimation m. analytiske vægte og censurering af top 0,1 indkomster
_pctile arb if qvarts==3, p(99.9) 
return list
gen q3perc == r(r1)

ivreg2 diffarb3 tresp10plogarb1 tresp10plogarb2 tresp10plogarb3 tresp10plogarb4 tresp10plogarb5 tresp10plogarb6 tresp10plogarb7 tresp10plogarb8 tresp10plogarb9 tresp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if arb < q3perc & qvarts==3, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_tredjekvartil}, append ctitle("M. censur") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*Q3.3: Tredje indkomstkvartil, estimation m. analytiske vægte uden splines.
ivreg2 diffarb3 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if qvarts==3, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_tredjekvartil}, append ctitle("U. splines") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*Q3.4: Anden indkomstkvartil, almindelig estimation m. analytiske vægte uden individer tæt på skatteknæk
ivreg2 diffarb3 tresp10plogarb1 tresp10plogarb2 tresp10plogarb3 tresp10plogarb4 tresp10plogarb5 tresp10plogarb6 tresp10plogarb7 tresp10plogarb8 tresp10plogarb9 tresp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if kink==0 & qvarts==3, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_tredjekvartil}, append ctitle("U. kinks") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*******************************************
*****          Fjerde kvartil         *****
*******************************************

*Q4.1: Fjerde indkomstkvartil, almindelig estimation m. analytiske vægte
ivreg2 diffarb3 firesp10plogarb1 firesp10plogarb2 firesp10plogarb3 firesp10plogarb4 firesp10plogarb5 firesp10plogarb6 firesp10plogarb7 firesp10plogarb8 firesp10plogarb9 firesp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if qvarts==4, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_fjerdekvartil}, replace ctitle("Alm.model") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*Q4.2: Fjerde indkomstkvartil, almindelig estimation m. analytiske vægte og censurering af top 0,1 indkomster
_pctile arb if qvarts==4, p(99.9) 
return list
gen q4perc == r(r1)

ivreg2 diffarb3 firesp10plogarb1 firesp10plogarb2 firesp10plogarb3 firesp10plogarb4 firesp10plogarb5 firesp10plogarb6 firesp10plogarb7 firesp10plogarb8 firesp10plogarb9 firesp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if arb < q4perc & qvarts==4, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_fjerdekvartil}, append ctitle("M. censur") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*Q4.3: Tredje indkomstkvartil, estimation m. analytiske vægte uden splines.
ivreg2 diffarb3 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if qvarts==4, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_fjerdekvartil}, append ctitle("U. splines") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*Q4.4: Anden indkomstkvartil, almindelig estimation m. analytiske vægte uden individer tæt på skatteknæk
ivreg2 diffarb3 firesp10plogarb1 firesp10plogarb2 firesp10plogarb3 firesp10plogarb4 firesp10plogarb5 firesp10plogarb6 firesp10plogarb7 firesp10plogarb8 firesp10plogarb9 firesp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if kink==0 & qvarts==4, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_fjerdekvartil}, append ctitle("U. kinks") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))


/* Estimationer af model 2-versionen med kvartilsplines, uden censurering og uden at fjerne individer tæt på kinkpoints */

*Q5.1: Første kvartil med kvartilsplines
ivreg2 diffarb3 ensp4plogarb1 ensp4plogarb2 ensp4plogarb3 ensp4plogarb4 dlogarb /// x+y & mean reversion 
pexp pexp2 palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if qvarts==1, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_kvartilsplines}, replace ctitle("1. kvartil") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*Q5.2: Anden kvartil med kvartilsplines
ivreg2 diffarb3 tosp4plogarb1 tosp4plogarb2 tosp4plogarb3 tosp4plogarb4 dlogarb /// x+y & mean reversion 
pexp pexp2 palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if qvarts==2, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_kvartilsplines}, append ctitle("2. kvartil") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*Q5.3: Tredje kvartil med kvartilsplines
ivreg2 diffarb3 tresp4plogarb1 tresp4plogarb2 tresp4plogarb3 tresp4plogarb4 dlogarb /// x+y & mean reversion 
pexp pexp2 palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if qvarts==3, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_kvartilsplines}, append ctitle("3. kvartil") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

*Q5.4: Fjerde kvartil med kvartilsplines
ivreg2 diffarb3 firesp4plogarb1 firesp4plogarb2 firesp4plogarb3 firesp4plogarb4 dlogarb /// x+y & mean reversion 
pexp pexp2 palder2 i.pindere i.pocc punem pgdp i.petnicitet /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.startaar##i.plandsdel i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand i.ppendler##i.plandsdel /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb] if qvarts==4, cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_kvartilsplines}, append ctitle("4. kvartil") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))

/* Robusthedstest på fuld model (alm. estimation med analytiske vægte) uden makroniveau-variable. */

ivreg2 diffarb3 sp10plogarb1 sp10plogarb2 sp10plogarb3 sp10plogarb4 sp10plogarb5 sp10plogarb6 sp10plogarb7 sp10plogarb8 sp10plogarb9 sp10plogarb10 dlogarb /// x+y & mean reversion 
pexp pexp2 palder palder2 i.pindere i.pocc i.petnicitet i.ppendler i.startaar /// kovariater
c.palder##i.pgift i.pmand##i.pgift i.pgift##c.pbornu6 i.pgift##c.pborn618 i.pmand##c.pbornu6 i.pmand##c.pborn618 c.puddannelse##i.pgift c.puddannelse##i.pmand /// interaktionsled
(diffmtr_arb_h3 diffvir_h13 = diffmtr_arb_h_iv3 diffvir_h1_iv3) /// instrumentering
[aw=arb], cluster(id_nr) // analytiske vægte, restriktion og klyngejustering af std.fejl.

outreg2 using ${output_udenmakro}, replace ctitle("Alm.model") label decmark(,) addstat(Justeret R2, e(r2_a), R2 alm., e(r2))
