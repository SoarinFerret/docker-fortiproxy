FROM ubuntu:18.04

RUN apt-get update && \
  apt-get install -y net-tools iproute2 ppp iptables openfortivpn && \
  apt-get clean autoclean && \
  apt-get autoremove --yes && \
  rm -rf /var/lib/{apt,dpkg,cache,log}/

# Copy runfiles
COPY start.sh /start.sh

# Set permissions
RUN chmod +x /start.sh

CMD [ "/start.sh" ]