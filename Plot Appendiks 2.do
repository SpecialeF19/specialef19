/* Sæt working directory med "cd" nedenfor, hvis grafen skal eksporteres til dit lokale drev.
   Dernæst køres koder til og med linje 26 for at producere grafen, og mens grafen er åben køres sidste linje med "graph export" */

cd ""

set scheme lean2
clear

tw (scatteri 2 1.5 3 2 4 2.5 5 3 6 3.5 7 4 7 4.5, connect(line) lp(dash)) ///
   (scatteri 4 1.5 5 2 6 2.5 8 3 9 3.5 10 4 11 4.5, connect(line) lp(dash)) ///
   (scatteri 6 1.5 8 2 10 2.5 11 3 13 3.5 15 4 17 4.5, connect(line) lp(dash)) ///
   (scatteri 9 1.5 11 2 14 2.5 17 3 20 3.5 23 4 26 4.5, connect(line) lp(dash)) ///
   (scatteri 13 1.5 18 2 22 2.5 27 3 31 3.5 35 4 40 4.5, connect(line) lp(dash)) ///
   (scatteri 23 1.5 30 2 38 2.5 46 3 53 3.5 61 4 68 4.5, connect(line) lp(dash)) ///
   (scatteri 94.61 1.5 (12) "a=1.5" 92.937 2 (12) "a=2" 91.32 2.5 (12) "a=2.5" 89.77 3 (12) "a=3" 88.26 3.5 (12) "a=3.5" 86.806 4 (12) "a=4" 85.4 4.5 (12) "a=4.5") ///
   , ///
   xtitle("Fordelingsparameteret, alpha", size(small)) ///
   ytitle("Lafferkurvens toppunkt/Selvfinansieringsgraden", size(small)) ///
   title("Fordelingsoversigt ved varierende marginalskatterate og fordelingsparametre", size(small)) ///
   legend(label (1 "Selvfinansieringsgrad v. tau=0,3") label (2 "Selvfinansieringsgrad v. tau=0,4") ///
   label (3 "Selvfinansieringsgrad v. tau=0,5") label (4 "Selvfinansieringsgrad v. tau=0,6") ///
   label (5 "Selvfinansieringsgrad v. tau=0,7") label (6 "Selvfinansieringsgrad v. tau=0,8") ///
   label (7 "Toppunkter på Lafferkurven") position(6) order(1 2 3 4 5 6 7) ///
   size(vsmall) cols(2)) ///
   note("Alle beregninger er baseret på en kompenseret substitutionselasticitet på 0,038", size(vsmall)) ///
   name(Appendiks2, replace)
   
   *** Kør hertil først, og kør graph export efterfølgende med graf-vinduet åbent.
   
   graph export Appendiks2.pdf


