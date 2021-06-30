#!/usr/bin/env bash
# Based on Robert Olsson & Jesse Brandeburg set_irq_affinity.sh
# and on previous netsetup script.

set -x
set -u
set -o pipefail

# Set affinity part



set_affinity()
{
	if [ $VEC -ge 32 ]
	then
		MASK_FILL=""
		MASK_ZERO="00000000"
		let "IDX = $VEC / 32"
		for ((i=1; i<=$IDX;i++))
		do
			MASK_FILL="${MASK_FILL},${MASK_ZERO}"
		done

		let "VEC -= 32 * $IDX"
		MASK_TMP=$((1<<$VEC))
		MASK=`printf "%X%s" $MASK_TMP $MASK_FILL`
	else
		MASK_TMP=$((1<<$VEC))
		MASK=`printf "%X" $MASK_TMP`
	fi

    printf "%s mask=%s for /proc/irq/%d/smp_affinity\n" $DEV $MASK $IRQ
    printf "%s" $MASK > /proc/irq/$IRQ/smp_affinity
}


tune_linux () {
	devlist=( ${1} )
	# brctl_ret=0
	# if which brctl &>/dev/null; then
	# 	brctl show ${devlist[0]} 2>&1|grep -q "not supported"
	# 	brctl_ret=$?
	# fi
	# if [ ${brctl_ret} -ne 0 ]; then
	# 	devlist=( $(brctl show ${devlist[0]} 2>/dev/null|tail -n +2|tr -d "\n"|tr -s "[:blank:]"|cut -f4-) )
	# 	echo "interface '${1}' is bridging ${devlist[@]}"
	# fi

	# # check for irqbalance running
	# IRQBALANCE_ON=`ps ax | grep -v grep | grep -q irqbalance; echo $?`
	# if [ "$IRQBALANCE_ON" == "0" ] ; then
	# 	echo " WARNING: irqbalance is running and will"
	# 	echo "          likely override this script's affinitization."
	# 	echo "          Please stop the irqbalance service or execute"
	# 	echo "          'killall irqbalance'"
	# fi

	# System-wide defaults
  # net.core.[wr]mem.* == SO_SNDBUF and SO_RCVBUF
  # net.core.busy_* == SO_BUSY_POLL
  # net.core.optmem_max == Maximum length of ancillary data and user control data
  # netdev_max_backlog == Maximum number of packets in the global input queue.
  # tcp_[rw]mem == increase Linux autotuning TCP buffer limits

	buflen=4096
	socket_bufsize=524288
# 	# https://fasterdata.es.net/host-tuning/nic-tuning/
# 	socket_bufsize=67108864
# 	max_tcp_send_receive=33554432
	busy_latency=0
	backlog=40000
	optmem_max=20480

	sysctl -p - << EOF
net.core.wmem_max     = $socket_bufsize
net.core.wmem_default = $socket_bufsize
net.core.rmem_max     = $socket_bufsize
net.core.rmem_default = $socket_bufsize
net.core.busy_read    = $busy_latency
net.core.busy_poll    = $busy_latency
net.core.optmem_max   = $optmem_max
net.core.netdev_max_backlog = $backlog
EOF
# net.ipv4.tcp_rmem = 4096 87380 $max_tcp_send_receive
# net.ipv4.tcp_wmem = 4096 65536 $max_tcp_send_receive
# EOF

#dont seem to work on 4.13 kernel
#net.core.default_qdisc = sch_fq

#make sure the changes take effect
sysctl -w net.ipv4.route.flush=1

	# # disable huge pages
	echo never > /sys/kernel/mm/transparent_hugepage/enabled

	# cpu governor
	for governor_conf in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
		echo performance > "$governor_conf"
	done

	# # Set the interface
 #  # -G Changes the rx/tx ring parameters of the specified network device.
  
	 for dev in ${devlist[@]}; do
		ethtool -L $dev combined 16
		ethtool -A $dev autoneg off rx off tx off
		ethtool -K $dev tso off gro off ufo off
		ethtool -G $dev rx ${buflen} tx ${buflen}
		ethtool -C $dev adaptive-tx on adaptive-rx on
		ethtool -C $dev rx-usecs-low 32 tx-usecs-low 32
		ethtool -C $dev rx-usecs-high 75 tx-usecs-high 75
		ethtool -N $dev rx-flow-hash udp4 sdfn
		ethtool -N $dev rx-flow-hash udp6 sdfn
	 done

	# # Set up the desired devices.
if service --status-all 2>&1 | grep irqbalance>/dev/null; then
	service irqbalance stop
fi
	for DEV in ${devlist[@]}; do
		for DIR in rx tx TxRx q; do
                        IRQS=$(egrep $DEV.*$DIR /proc/interrupts | cut -d: -f1 | sed "s/ //g")
                        if [ -z "$IRQS" ] ; then
                                echo no $DIR vectors found on $DEV
                                continue
                        fi
                        MAX=$(echo $IRQS | wc -w)
                        VEC=0
                        for IRQ in $IRQS; do
                                set_affinity
                                VEC=$((VEC+1))
                        done
		done
	done

}

tune_freebsd() {
	devlist=( ${1} )

	for dev in ${devlist[@]}; do
                ifconfig ${dev} -rxcsum -txcsum -lro -tso &>/dev/null
        done
        echo "$(uname -sr) {rxcsum,txcsum,lro,tso} off"
}


if [ "$1" = "" ] ; then
	echo "Description:"
	echo "    This script attempts to bind each queue of a multi-queue NIC"
	echo "    to the same numbered core, ie tx0|rx0 --> cpu0, tx1|rx1 --> cpu1"
	echo "usage:"
	echo "    $0 eth0 [eth1 eth2 eth3]"
fi

if [ `uname` = 'Linux' ]; then
	echo "Linux... Hmm"
	tune_linux "$1"
elif [ `uname` = 'FreeBSD' ]; then
	echo "FreeBSD... Hmm"
	tune_freebsd "$1"
else
	echo "Unknown OS. Exitting..."
	exit 0
fi

echo "$(uname -sr) / $1"