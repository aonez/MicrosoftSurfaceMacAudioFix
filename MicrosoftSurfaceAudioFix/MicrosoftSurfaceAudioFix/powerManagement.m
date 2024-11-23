//
//  powerManagement.m
//  MicrosoftSurfaceAudioFix
//
//  Created by aone on 22/11/24.
//  https://github.com/aonez/MicrosoftSurfaceMacAudioFix
//

#import <AppKit/AppKit.h>

#import "log.h"
#import "powerManagement.h"

BOOL sleepAndWakeNotificationsRegistered = false;

SleepCallback onSleepCallback = nil;
void setOnSleepCallback(SleepCallback callback) {
	onSleepCallback = callback;
}

WakeCallback onWakeCallback = nil;
void setOnWakeCallback(WakeCallback callback) {
	onWakeCallback = callback;
}

void registerSleepAndWakeNotifications(void) {
	if (sleepAndWakeNotificationsRegistered) {
		return;
	}
	sleepAndWakeNotificationsRegistered = true;
	if (onSleepCallback) {
		logMessage(@"Listening for sleep notifications");
		[NSWorkspace.sharedWorkspace.notificationCenter addObserverForName:NSWorkspaceWillSleepNotification
																	object:nil
																	 queue:[NSOperationQueue mainQueue]
																usingBlock:^(NSNotification * note) {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				if (onSleepCallback) {
					onSleepCallback();
				}
			});
		}];
	}
	if (onWakeCallback) {
		logMessage(@"Listening for wake notifications");
		[NSWorkspace.sharedWorkspace.notificationCenter addObserverForName:NSWorkspaceDidWakeNotification
																	object:nil
																	 queue:[NSOperationQueue mainQueue]
																usingBlock:^(NSNotification * note) {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				if (onWakeCallback) {
					onWakeCallback();
				}
			});
		}];
	}
}
