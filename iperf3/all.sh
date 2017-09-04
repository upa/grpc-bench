#!/bin/bash


# gather 1 flow results
./parser.py Host	host_none_host_send_parallel-01 \
		> dat/single-flow-send.dat
./parser.py GRAFT	docker_graft_host_send_parallel-01 \
		>> dat/single-flow-send.dat
./parser.py NAT		docker_nat_host_send_parallel-01 \
		>> dat/single-flow-send.dat


./parser.py GRAFT	docker_graft_same-host_send_parallel-01 \
		> dat/single-flow-send-lo.dat
./parser.py NAT		docker_nat_same-host_send_parallel-01 \
		>> dat/single-flow-send-lo.dat


# gather 1 flow results
./parser.py Host	host_none_host_recv_parallel-01 \
		> dat/single-flow-recv.dat
./parser.py GRAFT	docker_graft_host_recv_parallel-01 \
		>> dat/single-flow-recv.dat
./parser.py NAT		docker_nat_host_recv_parallel-01 \
		>> dat/single-flow-recv.dat


./parser.py GRAFT	docker_graft_same-host_recv_parallel-01 \
		> dat/single-flow-recv-lo.dat
./parser.py NAT		docker_nat_same-host_recv_parallel-01 \
		>> dat/single-flow-recv-lo.dat

gnuplot -e "direct='send'" plot-bps.plt
gnuplot -e "direct='recv'" plot-bps.plt

# gater multiple flows results
for scheme in host_none_host docker_graft_host docker_nat_host; do
for direct in send recv; do
	of=dat/multi-flow_${scheme}_${direct}.dat
	rm $of
	touch $of
for para in 01 02 04 06 08 10 12 14 16 18 20; do
	./parser.py $para ${scheme}_${direct}_parallel-${para} \
		>> $of
done
done
done

gnuplot -e "direct='send'" plot-bps-flows.plt
gnuplot -e "direct='recv'" plot-bps-flows.plt