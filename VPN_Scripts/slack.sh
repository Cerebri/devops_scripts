#!/usr/bin/env bash

# Slack incoming web-hook URL and user name
url='https://hooks.slack.com/services/######/*******'
username='Cerebri VPN'

# Be sure to set the --script-security level to 2 - Allow calling of built-in executables and user-defined scripts.
#script-security 2;
#client-connect "/usr/local/share/openvpn/slack.sh #cerebri-gm LOGIN";
#client-disconnect "/usr/local/share/openvpn/slack.sh #cerebri-gm LOGOUT"


# OpenVPN will set the following variables:
# username - The username provided by a connecting client.
# time_duration - The duration (in seconds) of the client session which is now disconnecting. Set prior to execution of the --client-disconnect script.
# time_ascii - Client connection timestamp, formatted as a human-readable time string. Set prior to execution of the --client-connect script.
time_duration = $time_duration / 60
time_duration=${time_duration%.*}

## Values received by this script:
# To = $1 (Slack channel or user to send the message to, specified in the Zabbix web interface; "@username" or "#channel")
# Subject = $2 (usually either PROBLEM or RECOVERY)
# Message = $3 (whatever message the Zabbix action sends, preferably something like "Zabbix server is unreachable for 5 minutes - Zabbix server (127.0.0.1)")

# Get the Slack channel or user ($1) and Zabbix subject ($2 - hopefully either LOGIN or LOGOUT)
to="$1"
subject="$2"

# Change message emoji depending on the subject - smile (RECOVERY), frowning (PROBLEM), or ghost (for everything else)
if [[ "$subject" == 'LOGIN' ]]; then
        emoji=':arrow_up:'
        message="${subject}: The user \`${username}\` logged in on VPN at \`${time_ascii}\`"
elif [ "$subject" == 'LOGOUT' ]; then
        emoji=':arrow_down:'
        message="${subject}: The user \`${username}\` logged out of VPN after \`${time_duration}\` minutes"
else
        emoji=':ghost:'
        message="Unknown message received"
fi

# Build our JSON payload and send it as a POST request to the Slack incoming web-hook URL
payload="payload={\"channel\": \"${to//\"/\\\"}\", \"username\": \"${username//\"/\\\"}\", \"text\": \"*${message//\"/\\\"}*\", \"icon_emoji\": \"${emoji}\"}"
curl -m 5 --data-urlencode "${payload}" $url -A 'zabbix-slack-alertscript / https://github.com/ericoc/zabbix-slack-alertscript'