#!/bin/sh
# HomePass
# To be called by cron every few minutes

# /etc/homepass.list must contain at least one line with a MAC.
# Optionally, you can specify a SSID after any MAC separating it with a tab.

DEFAULT_SSID="attwifi"

DATE=$(date)

# The WiFi network number we need to toggle the MAC address of
# This will use the first wifi in access point mode (ap)
WIFI=$(uci show wireless | grep "mode='ap'" | awk 'NR>1{print $1}' RS=[ FS=] | head -n 1)

if [ ! -s /etc/homepass.list ]; then
  echo "MAC address list is missing or zero in length."
  exit
fi

LENGTH=$(wc -l < /etc/homepass.list)

if [ -z "$WIFI" ]; then
  echo "Unable to identify the WiFi configuration for the Nintendo Zone network!"
  echo "Please make sure you have configured a Nintendo Zone WiFi access point (ssid $DEFAULT_SSID) before running this script."
  exit
fi

# If no profile was manually specified then read it from uci
if [ -z "$1" ]; then
   I=$(uci get wireless.@wifi-iface[$((WIFI))].profile)
   # If there is no uci entry then we start from scratch
   if [ -z "$I" ]; then
      I=1
   else
     I=$((I+1))
   fi
   # If we went over the last profile we reset back to $MIN
   if [ $I -gt $LENGTH ]; then
      I=1
   fi
else
   I=$1
fi

# Read MAC address number $I from the list
MAC=$(sed -n $((I))p /etc/homepass.list | awk '{print $1}' FS="\t")
# Make sure we actually got a MAC address from the list
if [ -n "$MAC" ]; then
   # Check if the list also specifies a SSID for this MAC
   SSID=$(sed -n $((I))p /etc/homepass.list | awk '{print $2}' FS="\t")
   if [ -n "$SSID" ]; then
      echo "$DATE: Setting profile $I. Found in list ssid $SSID for mac $MAC"
   else
      # otherwise, use the default
      SSID="$DEFAULT_SSID"
      echo "$DATE: Setting profile $I. Using default ssid $SSID for mac $MAC"
   fi
   # Save a custom config called profile so that we know where we are in the list next time
   uci set wireless.@wifi-iface[$((WIFI))].profile=$I
   # Save the new MAC address
   uci set wireless.@wifi-iface[$((WIFI))].macaddr=$MAC
   uci set wireless.@wifi-iface[$((WIFI))].ssid="$SSID"
   # Restart the WiFi
   wifi
else
   echo "We had a problem reading the MAC address from the list, aborting."
fi
