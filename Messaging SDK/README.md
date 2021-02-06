# MEMCM Messaging SDK playground

1. Send-Message.ps1<br />Sends a status message and if needed registers with the site. Also sends a datadiscoverymessage so that the server can add the newly created device to collections. Actions on the server side can be triggered by responding to this message using Status Filter Rules.
2. Fetchandapplybaselines.ps1<br />If the device has assigned baselines, get them and apply the settings. Useful to make sure CIs are in place at first boot.
3. Get-MEMCMReqApps.ps1<br />If the device has assigned required applications, set variables that can be used with the TS step "Install application" using a dynamic variable list. If the server adds the client to the right collections thanks to the script Send-Message.ps1 it should install all required applications that has been assigned to those collections.
