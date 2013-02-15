//
//  AppDelegate.m
//  Rest In DND
//
//  Created by Sang-jun Jung on 13. 2. 15..
//  Copyright (c) 2013년 Sang-jun Jung. All rights reserved.
//

#import "AppDelegate.h"

#import "AppDelegate.h"

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ncAppID = CFSTR(NOTIFICATION_CENTER_APPID);
    ncDND = CFSTR(NOTIFICATION_CENTER_DND);
    ncDNDDate = CFSTR(NOTIFICATION_CENTER_DND_DATE);
    
    // Insert code here to initialize your application
}


- (void) turnOnNCWithShell:(NSInteger) delaySecond {
    NSString *delayMinStr = [NSString stringWithFormat:@"%ld", (delaySecond)];

    NSBundle *thisBundle = [NSBundle mainBundle];
    NSString *filePath = nil;
    
    if ((filePath = [thisBundle pathForResource:@"notification_center_on" ofType:@"sh"]))  {

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self runShell:@"/bin/sh" withArg:[NSArray arrayWithObjects:filePath, delayMinStr, nil]];
            
            // Perform Task back in the main thread
            //            [viewController updateStuff:stuff];
        });
        // when completed, it is the developer's responsibility to release theContents
    }

}

- (void) runShell:(NSString*)strCommand withArg:(NSArray*)arrArgs{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:strCommand];
    
    //    args = [NSArray arrayWithObjects: @"foo", @"bar.txt", nil];
    [task setArguments: arrArgs];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
//    NSData *data;
//    data = [file readDataToEndOfFile];
//    
//    NSString *string;
//    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
//    //    NSLog (@"returned:\n%@", string);
    
//    [string release];
    [task autorelease];
    
}

- (IBAction)turnOffNC:(id)sender {
    NSLog(@"turnOffNC");
    
    
    ncDNDDateVal = CFDateCreate( kCFAllocatorDefault, CFAbsoluteTimeGetCurrent());
    CFPreferencesSetValue(ncDND, kCFBooleanTrue, ncAppID, kCFPreferencesCurrentUser , kCFPreferencesCurrentHost);
    CFPreferencesSetValue(ncDNDDate, ncDNDDateVal, ncAppID, kCFPreferencesCurrentUser , kCFPreferencesCurrentHost);
    CFPreferencesSynchronize(ncAppID, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
    
    
    [self runShell:@"/bin/launchctl" withArg:[NSArray arrayWithObjects:@"stop", @"com.apple.notificationcenterui.agent", nil]];

    NSInteger delayMinVal = [delayMinute integerValue];
    if (delayMinVal > 0) {
        [self turnOnNCWithShell:(delayMinVal * SECOND_PER_MIN)];
//        [self performSelector:@selector(turnOnNC:) withObject:sender afterDelay:(delayMinVal * SECOND_PER_MIN)];
    }
    return;
}



- (IBAction)turnOnNC:(id)sender {
    NSLog(@"turnOnNC");
    
    // save to plist
    //    CFPreferencesSetAppValue( ncDND, kCFBooleanFalse, ncAppID );
    //    CFPreferencesAppSynchronize(ncAppID);
    //    CFPreferencesSetAppValue(ncDNDDate, NULL, ncAppID);
    
    CFPreferencesSetValue(ncDND, kCFBooleanFalse, ncAppID, kCFPreferencesCurrentUser , kCFPreferencesCurrentHost);
    CFPreferencesSetValue(ncDNDDate, NULL, ncAppID, kCFPreferencesCurrentUser , kCFPreferencesCurrentHost);
    CFPreferencesSynchronize(ncAppID, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
    
    
    [self runShell:@"/bin/launchctl" withArg:[NSArray arrayWithObjects:@"stop", @"com.apple.notificationcenterui.agent", nil]];
    
}


@end
