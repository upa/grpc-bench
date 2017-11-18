#!/bin/bash


docker_server=yayoi1
sshcmd="ssh -i ~/.ssh/id_rsa_nopass $docker_server"

eachthr=~/src/zeromq-4.2.2/perf/eachthr
mirror_thr=~/src/zeromq-4.2.2/perf/mirror_thr


duration=70

#ipcmd="ip gr add zmq type ipv4 addr 10.0.0.1 port 5555"
#perfcmd="mirror_thr tcp://0.0.0.0:5555"
#dockercmd="${ipcmd} && ${perfcmd}"


for msgsize in 64 128 256 512 1000 2000 4000 8000 16000 32000 64000 128000 1000000 2000000 4000000 8000000 16000000 32000000 64000000;
do
	out="output/nat-eachthr-reverse-msgsize_${msgsize}.txt"

	echo msgsize $msgsize, output $out

	echo start mirror_thr at this server
	$mirror_thr tcp://10.0.0.2:5555 > $out &


	echo start eachthr
	dockercmd="eachthr tcp://10.0.0.2:5555 $msgsize $duration"
	$sshcmd docker run -i --rm nat-zmq bash -c \"${dockercmd}\"

	echo done sleep 5sec
	echo
	sleep 5
done
