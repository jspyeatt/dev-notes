# Linux Notes

## Restarting the Network Manager
```
sudo service network-manager restart
```

## What process is holding a port
```
netstat -tulpn|grep 9000
```
or
```
lsof -i :45002   # substitute your port number
```
## Shut off IPv6
```
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
```
## tcpdump
Can be a very useful command but has a lot of options.

### dump to file
```
/usr/sbin/tcpdump -i any -tttt -n -w /tmp/temp.pcap -s 65535 -p port 443 or port 8444 or port 8055 or port 5678
```
### dump to console
```
/usr/sbin/tcpdump -i any -tttt -n -A -s 65535 -p port 443 or port 8444 or port 8055 or port 5678
```
write the output to `temp.cap`. Set the snapshot `-s`  length to 65535. Send output to stdout `-p`
along with the .cap file. The last part is the filtering piece. This is the most complicated part
of the command. Hopefully the example above is pretty obvious what it does.

Other useful commmand line options.
1. `-i eth0` include only traffic from this interface.
1. `-c N` capture only N packets
1. `-A` display packages in ASCII
1. `-XX` display in ASCII and HEX
1. `-n` display hosts by IP Address, not DNS
1. -tttt display human-readable timestamps

### Hex dump to screen
```
/usr/sbin/tcpdump -XX -v -n -i any port 8081
```

Some other useful predicates:
1. `host www.cnn.com` include only traffic with cnn.com
1. `src 192.168.1.101` capture only packets which originate from 192.168.1.101
1. `dst 192.168.1.102` capture only packages being sent to 192.168.1.102.
1. `tcp` capture only tcp traffic

For a complete list of filters go here. (https://linux.die.net/man/7/pcap-filter)[pcap-filters].

### Reading a capture file
```
tcpdump -r <filename> | less
```
## Exploding a .deb file to Inspect its Contents
```
ar x FILENAME.deb
```
Look for a file called `data.tar.xz`.
Then you can run `tar -xf data.tar.xz` to explode the contents.

## iptables
### list active rules
```
sudo iptables -S
```
### list a specific chain
```
sudo iptables -S TCP
```
### list rules as tables
```
sudo iptables -L
```
### change the INPUT rules to allow all input
```
sudo iptables -P INPUT ACCEPT
```
