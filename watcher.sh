#!/bin/sh
#
# Collects system information and optionally sends the information via e-mail.
# Author: Alex Tsang <alextsang@live.com>
# License: The 3-Clause BSD License

# Strict mode.
set -e
set -u
IFS='\n\t'

workDirectory="$(cd "$(dirname "${0}")"; pwd)"
config="${workDirectory}/watcher.config"
systemLog="${workDirectory}/logs/system.log"
mailLog="${workDirectory}/logs/mail.log"
mailHeadTemplate="${workDirectory}/templates/head.template"
mailTailTemplate="${workDirectory}/templates/tail.template"

enableMail=
apiKey=
domainName=
senderName=
senderEmail=
receiverEmail=

if [ ! -r "${config}" ]; then
  echo "Cannot read configuration file ${config}. Exit now."
  exit 1
else
  . "${config}"
fi

# Collect system information.
getSystemInfo() {
  (
    # Operating system name.
    echo '##############################'
    echo '# Operating system name ######'
    echo '##############################'
    uname -srvm
    echo ''

    # System hostname.
    echo '##############################'
    echo '# System hostname ############'
    echo '##############################'
    hostname
    echo ''

    # System time.
    echo '##############################'
    echo '# System time ################'
    echo '##############################'
    echo "UTC time  : $(date -u +%Y-%m-%dT%H:%M:%S%z)"
    echo "Local time: $(date +%Y-%m-%dT%H:%M:%S%z)"
    echo ''

    # System uptime.
    echo '##############################'
    echo '# System uptime ##############'
    echo '##############################'
    uptime
    echo ''

    # CPU usage.
    echo '##############################'
    echo '# CPU usage ##################'
    echo '##############################'
    top -b 0 | grep CPU
    echo ''

    # Memory usage.
    echo '##############################'
    echo '# Memory usage ###############'
    echo '##############################'
    vmstat
    echo ''

    # Disk usage.
    echo '##############################'
    echo '# Disk usage #################'
    echo '##############################'
    df -h
    echo ''

    # Network interfaces.
    echo '##############################'
    echo '# Network interfaces #########'
    echo '##############################'
    ifconfig
    echo ''

    # Hardware sensors.
    echo '##############################'
    echo '# Hardware sensors ###########'
    echo '##############################'
    sysctl hw.sensors
    echo ''

    # Authentication logs.
    echo '##############################'
    echo '# Authentication logs ########'
    echo '##############################'
    tail /var/log/authlog
    echo ''

    # System messages.
    echo '##############################'
    echo '# System messages ############'
    echo '##############################'
    tail /var/log/messages
    echo ''

    # dmesg.
    echo '##############################'
    echo '# dmesg ######################'
    echo '##############################'
    dmesg
    echo ''
  ) > "${systemLog}"
}

# Send the system information via e-mail.
mailSystemInfo() {
  mailFile="$(mktemp)"

  (
    cat "${mailHeadTemplate}"
    # Escape several HTML entities.
    # Reference: https://stackoverflow.com/a/12873723
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g;' "${systemLog}"
    cat "${mailTailTemplate}"
  ) > "${mailFile}"

  (
    date -u +%Y-%m-%dT%H:%M:%S%z

    curl -s --user "api:${apiKey}" \
      "https://api.mailgun.net/v3/${domainName}/messages" \
      -F from="${senderName} <${senderEmail}>" \
      -F to="${receiverEmail}" \
      -F subject="Watcher ($(hostname))" \
      --form-string html="$(cat "${mailFile}")"

    echo ''

  ) >> "${mailLog}"

  rm "${mailFile}"
}

getSystemInfo

if [ "${enableMail}" != 'yes' ]; then
  exit 0
fi

mailSystemInfo

exit 0
