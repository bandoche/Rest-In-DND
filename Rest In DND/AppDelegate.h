//
//  AppDelegate.h
//  Rest In DND
//
//  Created by Sang-jun Jung on 13. 2. 15..
//  Copyright (c) 2013년 Sang-jun Jung. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#define NOTIFICATION_CENTER_APPID "com.apple.notificationcenterui"
#define NOTIFICATION_CENTER_DND "doNotDisturb"
#define NOTIFICATION_CENTER_DND_DATE "doNotDisturbDate"
#define SECOND_PER_MIN 60

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    CFStringRef ncAppID, ncDND, ncDNDDate;
    CFDateRef ncDNDDateVal;
    IBOutlet NSTextField *delayMinute;
    
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)turnOffNC:(id)sender;
- (IBAction)turnOnNC:(id)sender;

@end
