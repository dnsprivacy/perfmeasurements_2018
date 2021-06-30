#!/usr/local/bin/gnuplot

qpc_low_file='test-TCPz10-10000.csv'
qpc_high_file='test-TCPz1000-61000.csv'
qpc_tls_low_file='test-TLSz10-10000.csv'
qpc_tls_high_file='test-TLSz1000-61000.csv'

unbound='Unbound-release-1.7.0/'
bind='Bind9-v9_12_1/'
dnsdist='DNSDist-1.3.0/'
knot='Knot-resolver-v2.3.0/'


set output 'varyZ_low_tls.png'
set terminal pngcairo
set title "Queries per connection for TLS"
set format y "%.f"
set grid
set key outside;
set key right top;

repeats=5
z_res=4+(2*repeats)
z_std=z_res+1

#set ytics 50
#set xtics 2
set format y "%6.0s"
set xlabel "Queries per connection"
set ylabel "kQps"
set autoscale
plot \
unbound.qpc_tls_low_file  using  1:z_res with lines lw 3 lc "blue"   dashtype 1 title 'Unbound',        "" using 1:z_res:z_std with yerrorbars lw 1 lc "blue"  title '', \
knot.qpc_tls_low_file     using  1:z_res with lines lw 3 lc "orange" dashtype 1 title 'Knot R',         "" using 1:z_res:z_std with yerrorbars lw 1 lc "orange"  title '', \
dnsdist.qpc_tls_low_file  using  1:z_res with lines lw 3 lc "red"    dashtype 1 title 'dnsdist',        "" using 1:z_res:z_std with yerrorbars lw 1 lc "red"  title '', \



