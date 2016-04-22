# openwrt-homepass
HomePass for OpenWRT. Forked from https://github.com/Nephiel/openwrt-homepass
and modified as little as possible for TP-Link TL-WR841N(D) .  
May work for other devices.

What you need : at least one Access Point (AP) set.  
What the script does : renames SSID and sets MAC address of first AP. SSIDs and Macs are read from homepass.list .

Now allows to specify a SSID for each MAC.

Place the list in /etc/homepass.list and the script in /usr/bin/homepass.sh. Set the script as executable.
Didn't have enough space on device to install full wget you won't be able to download directly from https sites.
Worked around it by installing xampp on a local machine then wget'ing from it.
Then call the script from cron every few minutes using the provided crontab template.

To activate cron in OpenWRT: log in and run "/etc/init.d/cron enable".  
You might need to start it with "/etc/init.d/cron start"
