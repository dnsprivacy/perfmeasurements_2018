#!/usr/local/bin/gnuplot

set terminal pngcairo
set output 'transport-bar-percent.png'
set title "TCP and TLS (as percent of UDP)"
set style line 1 lc rgb "red" 
set style line 2 lc rgb "blue"
set style line 3 lc rgb "orange"
set key left top;

set yrange [0:150]
set ylabel "% of UDP performance"
set xtics ("Unbound" 0.75, "Knot R" 2.25, "BIND R" 3.75, "dnsdist" 5.25)

set boxwidth 0.5
set style fill solid

plot 'bar_data_percent.txt' every 2    using 1:2 with boxes ls 2 title "TCP",\
     'bar_data_percent.txt' every 2::1 using 1:2 with boxes ls 3 title "TLS"

