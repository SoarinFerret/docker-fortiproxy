#!/bin/sh

if [ -z "$VPNADDR" -o -z "$VPNUSER" -o -z "$VPNPASS" -o -z "$HOSTIP" ]; then
  echo "Variables HOSTIP, VPNADDR, VPNUSER and VPNPASS must be set."; exit;
fi

if [ -z "$VPNHASH" ]; then
  echo "Variable VPNHASH is required";
  trustedcert=$(/usr/bin/openfortivpn ${VPNADDR} -u ${VPNUSER} -p ${VPNPASS}| grep trusted-cert | head -n 1 | awk -F "--" ' { print $2} ' | sed -e 's/trusted-cert//g')
  echo "Trusted cert for $VPNADDR is$trustedcert";
  exit;
fi

export VPNTIMEOUT=${VPNTIMEOUT:-5}

# Setup IPTABLES

## Start setting the proxy
iptables -t nat -A PREROUTING -i eth0 -j DNAT --to-destination  ${HOSTIP} > /dev/null 2>&1

## ...and check for privileged access real quickly like
if ! [ $? -eq 0 ]; then
    echo "Sorry, this container requires the '--priviledged' flag to be set in order to use PPPD for VPN functionality"
    exit 1;
fi

iptables -t nat -A POSTROUTING -j MASQUERADE

# Setup masquerade, to allow using the container as a gateway
for iface in $(ip a | grep eth | grep inet | awk '{print $2}'); do
  iptables -t nat -A POSTROUTING -s "$iface" -j MASQUERADE
done

# Setup Custom Route
cat <<EOF >> /etc/ppp/ip-up.d/fortivpn
#!/bin/sh
route add $HOSTIP dev ppp0
EOF
chmod +x /etc/ppp/ip-up.d/fortivpn

# Docker on Windows Support
mknod /dev/ppp c 108 0 2> /dev/null

# VPN Loop
while [ true ]; do
  echo "------------ VPN Starts ------------"
  /usr/bin/openfortivpn ${VPNADDR} -u ${VPNUSER} -p ${VPNPASS} --no-dns --trusted-cert ${VPNHASH} --no-routes --pppd-no-peerdns
  echo "------------ VPN exited ------------"
  sleep 10
done
