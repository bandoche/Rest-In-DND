#!/bin/sh

#  notification_center_on.sh
#  Rest In DND
#
#  Created by Sang-jun Jung on 13. 2. 15..
#  Copyright (c) 2013년 Sang-jun Jung. All rights reserved.


sleep $@
f=$HOME/Library/Preferences/ByHost/com.apple.notificationcenterui.*.plist;
defaults write $f doNotDisturb -boolean false;
defaults delete $f doNotDisturbDate;
killall NotificationCenter;