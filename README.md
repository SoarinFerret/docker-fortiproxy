# Docker-FortiProxy

This project is forked from [docker-fortivpn](https://github.com/SoarinFerret/docker-fortivpn), which was inspired by the work provided here: [docker-forticlient](https://github.com/AuchanDirect/docker-forticlient). Most recently, the migration to alpine linux was made available due to the work done here: [openfortivpn-haproxy](https://github.com/jeffre/openfortivpn-haproxy)

Instead of doing port forwards and such, this container forwards and NATs _ALL_ incoming traffic to the container over to the host on the other side of the FortiSSL VPN. Useful if you don't have standard ports you want to connect to, or want to forward different protocols besides TCP.

## Environment Varibles

Here are a list of the required environment variables:

* `VPNADDR`: Url of the VPN with port. For example, `fortigate.example.com:8443`
* `VPNHASH`: Hash of the certificate used by the VPN. If excluded, the script will grab that information for you.
* `VPNUSER`: Username for the user connecting to the VPN
* `VPNPASS`: Password of the user connection to the VPN
* `HOSTIP`: IP of the host you want to connect to on the other side

## Usage / Examples

Make sure to run this container with `privileged` access. Otherwise you cannot use PPPD which the VPN relies on.

The below example shows how to run it with every port. After executing the below, you could use `mstsc 127.0.0.1:33389` or `ssh 127.0.0.1 -p 22222` or etc to reach your specified host.

```bash
docker run --restart=always --privileged -d -it \
    --name="VPNConnection" \
    -p 22222:22 \
    -p 33389:3389 \
    -p 55900:5900 \
    -p 55985:5985 \
    -e VPNADDR="fortigate.example.com:10443" \
    -e VPNHASH=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    -e VPNUSER=admin \
    -e VPNPASS="password" \
    -e HOSTIP=172.20.1.30 \
    soarinferret/fortiproxy
```

### Docker-Compose

A docker-compose.yml file is included for your convienence. I use a similar docker-compose file to stand up around 10 VPNs to different locations.

```bash
# Using docker-compose
# Make sure to edit the environment variables within the docker-compose file
docker-compose up
```

## Building

If you want to modify the container and update it with different functionality, follow the steps below:

```bash
# download
git clone https://github.com/SoarinFerret/docker-fortiproxy.git

# make your changes

# build
docker build -t fortiproxy .
```