* Selvfinansieringsgrad = (tau/1-tau)*a*e
* Laffer-kurve = 1/(1+a*e)

*bereging af tau = bysort tiar: sum(tau_arb_i)
*beregning af alpha = bysort tiar: sum(arb) 
* ^de værdier == sum(arb) / (sum(arb) - skattegrænse)

** tau for alle:
bysort tiar: sum tau_arb_i
ereturn list
di ...
di "gennemsnit = " r(mean) 
* = gennemsnitlig tau for alle danskere.

** indtast skattegrænse manuelt(!)
* NB vi bruger bundskattegrænsen for alle (eller AM, alpha=1). Prøv begge. 
* Bundskat = over personfradraget (på >41.000,- DKK (hvor man betaler bundskat)).
gen skattegraense_bund = .
edit skattegraense_bund

* INDSÆT 1990-2013 bund nedenfor manuelt. 
/*
1990 til og med 1993 == bund udgør både stat og kommune. derfor listet som stat + kommune. - prøv måske bare "stat" først; ellers + de to sammen.

1990 bund = 30200 + 23700
1990  top = 222800
1991 bund = 30800 + 24100
1991  top = 227200
1992 bund = 31500 + 24600
1992  top = 231800
1993 bund = 32600 + 25500
1993  top = 240000
1994 bund = 29300
1994  top = 234900
1995 bund = 29600
1995  top = 236600
1996 bund = 30400
1996  top = 243100
1997 bund = 30600
1997  top = 244600
1998 bund = 31400
1998  top = 251200
1999 bund = 32300
1999  top = 258400
2000 bund = 33400
2000  top = 267600
2001 bund = 33400
2001  top = 276900
2002 bund = 34400
2002  top = 285200
2003 bund = 35600
2003  top = 295300
2004 bund = 36800
2004  top = 304800
2005 bund = 37600
2005  top = 311500
2006 bund = 38500
2006  top = 318700
2007 bund = 39500
2007  top = 327200
2008 bund = 41000
2008  top = 335800
2009 bund = 42900
2009  top = 347200
2010 bund = 42900
2010  top = 389900
2011 bund = 42900
2011  top = 389900
2012 bund = 42900
2012  top = 389900
2013 bund = 42000
2013  top = 421100
*/

** alpha: (efter manuel indtastning), vi regner kun for individer over grænsen. 
bysort tiar: sum arb if arb>skattegraense_bund
** måske nødt til at "sum arb if arb>skattegraense_bund & tiar==1990 til 2013" manuelt og kopiere ind i nyt datasæt til beregning. 
gen gennemsnitarb = r(mean)

gen forskel = gennemsnitarb / (gennemsnitarb-skattegraense_bund)
sum forskel, det
** GNS = alpha.
** Sanity check med alpha fra DØRS (2011).

** 1) for 0,1:
* Vi bruger alpha som udregnet ovenfor (for alle)
* vi bruger tau som udregnet ovenfor.

* Laffer:
di "Laffertoppkt 1) = " 1/(1+(alpha*epsilon))
*selvf.:
di "selvfinansgr. 1) = " (tau/(1-tau))*(alpha*epsilon)

** 2) for vores estimat, 0.xx

* Laffer:
di "Laffertoppkt 2) = " 1/(1+(alpha*epsilon))
*selvf.:
di "selvfinansgr. 2) = " (tau/(1-tau))*(alpha*epsilon)

*** OBS: Beregninger for heterogene grupper beror på mere sofistikerede tilgange og ikke direkte sammenligneligt med resultaterne fra 1) og 2).

* bundskat = samme beregning som ovenfor (2)



