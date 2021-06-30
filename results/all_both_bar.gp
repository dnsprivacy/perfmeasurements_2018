#!/usr/local/bin/gnuplot

set terminal pngcairo
set output 'transport-bar.png'
set title "UDP vs TCP vs TLS for 8 clients"
set style line 1 lc rgb "red" 
set style line 2 lc rgb "blue"
set style line 3 lc rgb "orange"
set key left top;

set yrange [0:600]
set ylabel "kQps"
set xtics ("Unbound" 0.5, "Knot R" 2.5, "BIND R" 4.5, "dnsdist" 6.5)

set boxwidth 0.5
set style fill solid

plot 'bar_data.txt' every 2    using 1:2 with boxes ls 1 title "UDP",\
     'bar_data.txt' every 2::1 using 1:2 with boxes ls 2 title "TCP",\
     'bar_data.txt' every 2::2 using 1:2 with boxes ls 3 title "TLS"
