#!/bin/bash


docker_server=yayoi1
sshcmd="ssh -i ~/.ssh/id_rsa_nopass $docker_server"

local_thr=~/src/zeromq-4.2.2/perf/local_thr
remote_thr=~/src/zeromq-4.2.2/perf/remote_thr


# docker nat

msgcnt=10000

for x in `seq 1 10`; do
for msgsize in 64 256 1000 4000 16000 64000 256000 1000000 4000000 16000000 64000000; do

	out="output/thr-thr-msgsize_${msgsize}-msgcnt_${msgcnt}-${x}.txt"

	echo msgsize $msgsize, count $x
	echo output file: $out
	echo start local_thr in graft conitaner at $docker_server

	ipcmd="ip gr add zmq type ipv4 addr 10.0.0.1 port 5555"
	perfcmd="local_thr tcp://0.0.0.0:5555 $msgsize $msgcnt"
	dockercmd="${ipcmd} && $perfcmd"

	$sshcmd docker run -i --rm --cap-add=NET_ADMIN  \
	graft-zmq bash -c \"$dockercmd\" > $out &

	echo start remote_thr
	$remote_thr tcp://10.0.0.1:5555 $msgsize $msgcnt

	sleep 2

	echo
done
done
