##!/usr/bin/gnuplot -c


# Use this for macOS
# #!/usr/local/bin/gnuplot
# Use this on test4
# #!/usr/bin/gnuplot

# Script to generate plots for the results from a run of a single nameserver
# Script should be run from the directory that contains the results

# First plot is UDP vs TCP vs TLS
# Use the first and 15th column,

reset session
udp_file='test-UDPct-1-16.csv'
tcp_file='test-TCPct-1-16.csv'
tls_file='test-TLSct-1-16.csv'

set output 'transport.png'
set terminal png
set title "UDP vs TCP vs TLS"
set format y "%.f"
set grid

repeats=ARG1
ct_res=5+(2*repeats)
ct_std=ct_res+1

set ytics 50000
set xtics 2
set format y "%6.0s"
set xlabel "Clients"
set ylabel "kQps"
set autoscale
plot \
udp_file using 1:ct_res with lines lw 3 lc "blue" title 'UDP',     "" using 1:ct_res:ct_std with yerrorbars lw 2 lc "blue"  title '', \
tcp_file using 1:ct_res  with lines lw 3 lc "red" title 'TCP',     "" using 1:ct_res:ct_std with yerrorbars lw 2 lc "red"  title '', \
tls_file using 1:ct_res  with lines lw 3 lc "orange" title 'TLS',  "" using 1:ct_res:ct_std with yerrorbars lw 2 lc "orange"  title ''


reset session
qpc_low_file='test-TCPz10-10000.csv'
qpc_high_file='test-TCPz1000-61000.csv'
qpc_tls_low_file='test-TLSz10-10000.csv'
qpc_tls_high_file='test-TLSz1000-61000.csv'

set output 'varyZ.png'
set terminal png
set title "Queries per connection"
set format y "%.f"
set grid

repeats=ARG1
z_res=4+(2*repeats)
z_std=z_res+1

#set ytics 50
#set xtics 2
set format y "%6.0s"
set xlabel "Queries per connection"
set ylabel "kQps"
set autoscale
plot \
qpc_low_file using       1:z_res with lines lw 3 lc "red"  title '',      "" using 1:z_res:z_std with yerrorbars lw 1 lc "red"  title '', \
qpc_high_file using      1:z_res with lines lw 3 lc "red"  title 'TCP',   "" using 1:z_res:z_std with yerrorbars lw 2 lc "red"  title '', \
qpc_tls_low_file using   1:z_res with lines lw 3 lc "orange"  title '',   "" using 1:z_res:z_std with yerrorbars lw 1 lc "orange"  title '', \
qpc_tls_high_file using  1:z_res with lines lw 3 lc "orange" title 'TLS', "" using 1:z_res:z_std with yerrorbars lw 2 lc "orange"  title ''

set output 'varyZ_low.png'

plot \
qpc_low_file using      1:z_res with lines lw 3 lc "red" title 'TCP',     "" using 1:z_res:z_std with yerrorbars lw 1 lc "red"  title '',\
qpc_tls_low_file using  1:z_res with lines lw 3 lc "orange"  title 'TLS', "" using 1:z_res:z_std with yerrorbars lw 1 lc "orange"  title '',



