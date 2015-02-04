#!/bin/bash

# how to prepare a packet:
# 1) grab MPEG2-TS file of choice
# 2) filter out some packet (1..7) from it by using
#  dd if=file.ts of=mpeg_part.bin size=1 count=188(*N)
# 3) send it to any host
#  nc -u 192.168.0.1 40000 < mpeg_part.bin
# 4) find it in wireshark with a filter
#  udp.destport == 40000
# 5) select the packet, file -> export selected packet bytes
#  save to mpeg_packet.bin
# 6) convert to integers ready for the test bench with the following command:

od -w1 -An -vtu1 < mpeg_packet.bin > mpeg_packet.txt
echo "0" >> mpeg_packet.txt
echo "0" >> mpeg_packet.txt
echo "0" >> mpeg_packet.txt
echo "0" >> mpeg_packet.txt

