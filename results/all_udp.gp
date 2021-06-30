#!/usr/local/bin/gnuplot

reset session
udp_file='test-UDPct-1-16.csv'
tcp_file='test-TCPct-1-16.csv'
tls_file='test-TLSct-1-16.csv'

unbound='Unbound-release-1.7.0/'
bind='Bind9-v9_12_1/'
dnsdist='DNSDist-1.3.0/'
knot='Knot-resolver-v2.3.0/'


set output 'transport_udp.png'
set terminal pngcairo
set title "UDP for all nameservers"
set format y "%.f"
set grid

repeats='5'
ct_res=5+(2*repeats)
ct_std=ct_res+1

set key outside;
set key right top;

set ytics 50000
set xtics 2
set format y "%6.0s"
set xlabel "# dnsperf clients"
set ylabel "kQps"
#set autoscale
set yrange [0:850000]
plot \
unbound.udp_file using 1:ct_res  with lines lw 3 lc "blue"    dashtype 1 title 'U-UDP',     "" using 1:ct_res:ct_std with yerrorbars lw 2 lc "blue"    title '' , \
bind.udp_file    using 1:ct_res  with lines lw 3 lc "green"   dashtype 1 title 'B-UDP',     "" using 1:ct_res:ct_std with yerrorbars lw 2 lc "green"    title '', \
knot.udp_file    using 1:ct_res  with lines lw 3 lc "orange"  dashtype 1 title 'K-UDP',     "" using 1:ct_res:ct_std with yerrorbars lw 2 lc "orange"    title '', \
dnsdist.udp_file using 1:ct_res  with lines lw 3 lc "red"     dashtype 1 title 'd-UDP',     "" using 1:ct_res:ct_std with yerrorbars lw 2 lc "red"    title ''


