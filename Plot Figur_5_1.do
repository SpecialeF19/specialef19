/* Sæt working directory med "cd" nedenfor, hvis grafen skal eksporteres til dit lokale drev.
   Dernæst køres koder til og med linje 21 for at producere grafen, og mens grafen er åben køres sidste linje med "graph export" */

cd ""

set scheme lean2
clear

tw (scatteri 1 -0.006 (12) "-0.006" 2 0.003 (12) "0.003" 3 0.016 (12) ///
    "0.016" 4 0 (12) "0", connect(line) lp(dash) mlabel() ///
	    mlabposition(12) mlabgap(small)) ///
    , yscale(range(0.5 4.5)) xscale(range(-0.02 0.02)) ///
    xlab(-0.02(0.01)0.02) xline(0, lcolor(gs15) lpattern(dash)) ///
    ylabel(,nogrid) xtitle("Kompenseret elasticitet") ///
    ytitle("Indkomstkvartiler") ///
    title("Kompenseret elasticitet på tværs af kvartiler") ///
    yline(1, lcolor(gs15) lpattern(dash) noextend) ///
    yline(2, lcolor(gs15) lpattern(dash) noextend) ///
    yline(3, lcolor(gs15) lpattern(dash) noextend) ///
    yline(4, lcolor(gs15) lpattern(dash) noextend) ///
    name(Figur_5_1, replace)

    *** Kør hertil først, og kør graph export efterfølgende med graf-vinduet åbent.

    graph export Figur_5_1.pdf
