#!/usr/local/bin/gnuplot

reset session
udp_tcp_file='test-UDPTCPct-10-24000.csv'

unbound='Unbound-release-1.7.0/'
bind='Bind9-v9_12_1/'
dnsdist='DNSDist-1.3.0/'
knot='Knot-resolver-v2.3.0/'

set datafile separator ","

set output 'transport_udp_tcp_conns.png'
set terminal pngcairo
set title "UDP vs TCP with many clients"
set format y "%.f"
set grid

set key outside;
set key right top;

set ytics 50000
set xtics 5000
set format y "%6.0s"
set xlabel "# clients"
set ylabel "kQps"
#set autoscale
set yrange [0:850000]
plot \
unbound.udp_tcp_file using 1:5 with lines lw 3 lc "blue"   dashtype 1 title 'U-UDP', \
                  '' using 1:2 with lines lw 3 lc "blue"   dashtype 2 title 'U-TCP', \
bind.udp_tcp_file    using 1:5 with lines lw 3 lc "green"  dashtype 1 title 'B-UDP', \
                  '' using 1:2 with lines lw 3 lc "green"  dashtype 2 title 'B-TCP', \
knot.udp_tcp_file    using 1:5 with lines lw 3 lc "orange" dashtype 1 title 'K-UDP', \
                  '' using 1:2 with lines lw 3 lc "orange" dashtype 2 title 'K-TCP', \
dnsdist.udp_tcp_file using 1:5 with lines lw 3 lc "red"    dashtype 1 title 'D-UDP', \
                  '' using 1:2 with lines lw 3 lc "red"    dashtype 2 title 'D-TCP'
