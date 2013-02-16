//
//  AppDelegate.m
//  Rest In DND
//
//  Created by Sang-jun Jung on 13. 2. 15..
//  Copyright (c) 2013년 Sang-jun Jung. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize statusBar = _statusBar, window;

- (void)dealloc
{
    [super dealloc];
}

- (void) awakeFromNib {
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    self.statusBar.title = @"D";
    
    // you can also set an image
    //self.statusBar.image =
    
    self.statusBar.menu = menuBar;
    self.statusBar.highlightMode = YES;
    
    ncAppID = CFSTR(NOTIFICATION_CENTER_APPID);
    ncDND = CFSTR(NOTIFICATION_CENTER_DND);
    ncDNDDate = CFSTR(NOTIFICATION_CENTER_DND_DATE);
    ridAppId = CFSTR(RIDND_APPID);

    [menuBar setAutoenablesItems:NO];
    [dndMenuItem setTitle:[NSString stringWithFormat:@"%ld분간 방해금지", [self getDNDMinute]]];
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    [delayMinute setTarget:self];
    [delayMinute setAction:@selector(saveDNDMinute:)];
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


// 설정 화면 보이기
- (IBAction)showSetting:(id)sender {
    [delayMinute setStringValue:[NSString stringWithFormat:@"%ld", (long)[self getDNDMinute]]];
    [window makeKeyAndOrderFront:self];
    [[NSApplication sharedApplication] activateIgnoringOtherApps : YES];
//    [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateAllWindows];
//    [[NSRunningApplication currentApplication] activateWithOptions: NSApplicationActivateIgnoringOtherApps];
}

- (IBAction)saveDNDMinute:(id)sender {
    NSInteger delayMinVal = [delayMinute integerValue];
    if (delayMinVal > 0) {
        [self setDNDMinute:delayMinVal];
        if ([dndMenuItem isEnabled]) {
            [dndMenuItem setTitle:[NSString stringWithFormat:@"%ld분간 방해금지", [self getDNDMinute]]];
        }
        [window close];
    } else {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert addButtonWithTitle:@"확인"];
        [alert setMessageText:@"값이 올바르지 않습니다"];
        [alert setInformativeText:@"자연수를 입력해주세요."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
    }
}

- (IBAction)doDelayedDND:(id)sender {
    
    [dndMenuItem setTitle:[NSString stringWithFormat:@"%ld분간 방해금지 진행중", [self getDNDMinute]]];
    [dndMenuItem setEnabled:NO];
    

    ncDNDDateVal = CFDateCreate( kCFAllocatorDefault, CFAbsoluteTimeGetCurrent());
    CFPreferencesSetValue(ncDND, kCFBooleanTrue, ncAppID, kCFPreferencesCurrentUser , kCFPreferencesCurrentHost);
    CFPreferencesSetValue(ncDNDDate, ncDNDDateVal, ncAppID, kCFPreferencesCurrentUser , kCFPreferencesCurrentHost);
    CFPreferencesSynchronize(ncAppID, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
    
    [self runShell:@"/bin/launchctl" withArg:[NSArray arrayWithObjects:@"stop", @"com.apple.notificationcenterui.agent", nil]];
    
    NSInteger delayMinVal = [self getDNDMinute];
    if (delayMinVal > 0) {
        [self performSelector:@selector(enableDNDMenuItem) withObject:nil afterDelay:([self getDNDMinute] * SECOND_PER_MIN)];
    }

}

- (void) enableDNDMenuItem {
    [dndMenuItem setEnabled:YES];
    [dndMenuItem setTitle:[NSString stringWithFormat:@"%ld분간 방해금지", [self getDNDMinute]]];
    [self turnOnNCWithShell:0];
}

// plist 에 기록
- (void) setDNDMinute:(NSInteger)dndMinute {
    CFNumberRef numValue = CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &dndMinute);
    CFPreferencesSetAppValue(CFSTR(RIDND_MINUTE), numValue, ridAppId);
    CFPreferencesAppSynchronize(ridAppId);
}

// plist에서 가져오기 
- (NSInteger)getDNDMinute {
    CFPreferencesAppSynchronize(ridAppId);
    NSInteger dndMinute = 15;
    CFPropertyListRef value;
    
    /* Initialize the checkbox */
    value = CFPreferencesCopyAppValue( CFSTR(RIDND_MINUTE),  ridAppId );
    if ( value && CFGetTypeID(value) == CFNumberGetTypeID()  ) {
        CFNumberGetValue(value, kCFNumberNSIntegerType, &dndMinute);
        NSLog(@"%ld", (long)dndMinute);
        
    }
    return dndMinute;

}
@end
