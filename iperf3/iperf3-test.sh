#!/bin/bash

image=graft-iperf3
nic=enp1s0
dst=10.0.0.2
src=10.0.0.1
port=5201
outputdir=output
trynum=20



function docker_run() {

	cmd=$1
	shift
	options=$@

	ipgraft="ip gr add in type ipv4 addr ${src} port ${port}"
	ipgraft+=" && ip gr add out type ipv4 addr ${src} port dynamic"

	execcmd="${ipgraft} && $cmd"

	docker run -it --cap-add=NET_ADMIN			\
		-e GRAFT_CONV_PAIRS="0.0.0.0:${port}=in"	\
		-e GRAFT_BBCONN="out"				\
		$options					\
		$image bash -c "${execcmd}" $output
}



for p in 01 02 04 06 08 10 12 14 16 18 20; do

#####################################################################
echo
echo Testing Graft. enable LRO on $nic
sudo ethtool -K $nic lro on

for x in `seq -w 1 $trynum`; do
	echo docker graft send test parallel ${p}, $x
	docker_run "iperf3 -c $dst -O 5 -t 15 -J" \
		> $outputdir/docker_graft_send_pararel-${p}_${x}.txt
done


for x in `seq -w 1 $trynum`; do
	echo docker graft recv test parallel ${p}, $x
	docker_run "iperf3 -c $dst -O 5 -t 15 -R -J" \
		> $outputdir/docker_graft_recv_parallel-${p}_$x.txt
done


docker rm $(docker ps -a --filter 'status=exited' -q)
#####################################################################
echo
echo Testing Docker NAT. disalbe LRO on $nic
sudo ethtool -K $nic lro off

for x in `seq -w 1 $trynum`; do
	echo docker nat send test parallel ${p}, $x
	docker_run "iperf3 -c $dst -O 5 -t 15 -J" "-e GRAFT=disable" \
		> $outputdir/docker_nat_send_parallel-${p}_$x.txt
done


for x in `seq -w 1 $trynum`; do
	echo docker nat recv test parallel ${p}, $x
	docker_run "iperf3 -c $dst -O 5 -t 15 -R -J" "-e GRAFT=disable" \
		> $outputdir/docker_nat_send_parallel-${p}_$x.txt
done


docker rm $(docker ps -a --filter 'status=exited' -q)
#####################################################################
echo
echo Testing Host. enable LRO on $nic
sudo ethtool -K $nic lro on

for x in `seq -w 1 $trynum`; do
	echo host send test parrallel ${p}, $x
	iperf3 -c $dst -O 5 -t 15 -J \
		> $outputdir/host_none_send_parallel-${p}_$x.txt
done


for x in `seq -w 1 $trynum`; do
	echo host recv test parrallel ${p}, $x
	iperf3 -c $dst -O 5 -t 15 -J \
		> $outputdir/host_none_recv_parallel-${p}_$x.txt
done


docker rm $(docker ps -a --filter 'status=exited' -q)
#####################################################################
echo
echo Testing Docker Container to Hosting Host via GRAFT

for x in `seq -w 1 $trynum`; do
	echo docker graft send to same host test parallel ${p}, $x
	docker_run "iperf3 -c $src -O 5 -t 15 -J" \
		> $outputdir/docker_graft_send-host_parallel-${p}_$x.txt
done

for x in `seq -w 1 $trynum`; do
	echo docker nat recv from same host test parallel ${p}, $x
	docker_run "iperf3 -c $src -O 5 -t 15 -R -J" \
		> $outputdir/docker_graft_recv-host_parallel-${p}_$x.txt
done


docker rm $(docker ps -a --filter 'status=exited' -q)
#####################################################################
echo
echo Testing Docker Container to Hosting Host via NAT

for x in `seq -w 1 $trynum`; do
	echo docker nat send to same host test parallel ${p}, $x
	docker_run "iperf3 -c $src -O 5 -t 15 -J" "-e GRAFT=disable" \
		> $outputdir/docker_nat_send-host_parallel-${p}_$x.txt
done

for x in `seq -w 1 $trynum`; do
	echo docker nat recv from same host test parallel ${p}, $x
	docker_run "iperf3 -c $src -O 5 -t 15 -R -J" "-e GRAFT=disable" \
		> $outputdir/docker_nat_recv-host_parallel-${p}_$x.txt
done


done

