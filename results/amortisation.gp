#!/usr/local/bin/gnuplot

set terminal pngcairo
set title "Amortisation"
set output 'amortisation.png'
set xlabel "N"
set ylabel "RTT Amortisation"
f(x) = x/(1+x)
set autoscale
set ytics (0,0.5,1,1.5,2)
#set xrange [0:500]
set format y "%f"
set yrange [0:1]
plot \
[x=1:200] f(x) with lines lw 3 lc "blue" 
