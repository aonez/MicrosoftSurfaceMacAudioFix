//
//  microsoftSurfaceAudioFix.m
//  MicrosoftSurfaceAudioFix
//
//  Created by aone on 21/11/24.
//  https://github.com/aonez/MicrosoftSurfaceMacAudioFix
//

#import "log.h"

#import "powerManagement.h"
#import "audioDevices.h"

#import "microsoftSurfaceAudioFix.h"

#define MICROSOFT_SURFACE_THUNDERBOLT_AUDIO_DEVICE_NAME "Microsoft Surface Thunderbolt(TM) 4 Dock Audio"
#define MICROSOFT_SURFACE_THUNDERBOLT_DEVICE_NAME @"Surface Thunderbolt(TM) 4 Dock"
#define VOLUME_APP_NAME @"MultiSoundChanger"

BOOL skipMicrosoftSurfaceAudioFix = false;

int fixSafeTime = 10;
BOOL applyingFixSafeTime = false;
BOOL forcedFixByTimeout = false;
BOOL checking = false;

BOOL shouldBeSleeping = false;

BOOL isThunderboltDeviceConnected(void) {
	@autoreleasepool {
		NSPipe * pipe = [NSPipe pipe];
		NSTask * task = [[NSTask alloc] init];
		task.launchPath = @"/usr/sbin/system_profiler";
		task.arguments = @[@"SPThunderboltDataType"];
		task.standardOutput = pipe;
		
		NSFileHandle * file = pipe.fileHandleForReading;
		[task launch];
		[task waitUntilExit];
		
		NSData * data = [file readDataToEndOfFile];
		NSString * output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		
		return [output containsString:MICROSOFT_SURFACE_THUNDERBOLT_DEVICE_NAME];
	}
}

void restartCoreAudio(void) {
	@autoreleasepool {
		logMessage(@"Restarting coreaudiod...");
		NSTask * task = [[NSTask alloc] init];
		task.launchPath = @"/usr/bin/sudo";
		task.arguments = @[@"killall", @"coreaudiod"];
		[task launch];
		[task waitUntilExit];
		logMessage(@"coreaudiod restarted successfully");
	}
}

void restartVolumeApp(void) {
	@autoreleasepool {
		NSString * appPath = [NSString stringWithFormat:@"/Applications/%@.app", VOLUME_APP_NAME];
		if ([[NSFileManager defaultManager] fileExistsAtPath:appPath]) {
			logMessage([NSString stringWithFormat:@"Restarting %@...", VOLUME_APP_NAME]);
			
			NSTask * killTask = [[NSTask alloc] init];
			killTask.launchPath = @"/usr/bin/killall";
			killTask.arguments = @[VOLUME_APP_NAME];
			[killTask launch];
			[killTask waitUntilExit];
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fixSafeTime * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				NSTask * openTask = [[NSTask alloc] init];
				openTask.launchPath = @"/usr/bin/open";
				openTask.arguments = @[appPath];
				[openTask launch];
				[openTask waitUntilExit];
				logMessage([NSString stringWithFormat:@"%@ restarted successfully", VOLUME_APP_NAME]);
			});
		} else {
			logMessage([NSString stringWithFormat:@"%@ is not installed, skipping restart", VOLUME_APP_NAME]);
		}
	}
}

void fixMicrosoftSurfaceAudio(void) {
	if (shouldBeSleeping) {
		logMessage(@"Skipping fix (should be sleeping)");
		return;
	}
	applyingFixSafeTime = true;
	
	restartCoreAudio();
	restartVolumeApp();
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fixSafeTime * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		applyingFixSafeTime = false;
	});
}

void checkAndFixMicrosoftSurfaceAudioDevice(void) {
	if (checking) {
		logMessage(@"Skipping check (already checking)");
	}
	checking = true;
	
	if (applyingFixSafeTime) {
		logMessage([NSString stringWithFormat:@"Skipping check (fix exectuted less than %i seconds before)", fixSafeTime]);
		return;
	}
	
	if (isThunderboltDeviceConnected()) {
		logMessage([NSString stringWithFormat:@"Device \"%@\" detected", MICROSOFT_SURFACE_THUNDERBOLT_DEVICE_NAME]);
		fixMicrosoftSurfaceAudio();
	}
	else {
		logMessage([NSString stringWithFormat:@"Device  \"%@\" not present", MICROSOFT_SURFACE_THUNDERBOLT_DEVICE_NAME]);
	}
	checking = false;
}

void onAudioDevicesChange(void) {
	if (shouldBeSleeping) {
		// Too much darkwake events, dismiss this log
		// logMessage(@"Ignoring audio devices change (should be sleeping)");
		return;
	}
	if (checking) {
		logMessage(@"Ignoring audio devices change (already checking)");
		return;
	}
	if (applyingFixSafeTime) {
		logMessage([NSString stringWithFormat:@"Ignoring audio devices change (fix executed less than %i seconds before)", fixSafeTime]);
		return;
	}
	logMessage(@"Audio devices changed");
	checkAndFixMicrosoftSurfaceAudioDevice();
}

void onWake(void) {
	shouldBeSleeping = false;
	logMessage(@"Mac has woken up");
	checkAndFixMicrosoftSurfaceAudioDevice();
}

void onSleep(void) {
	shouldBeSleeping = true;
	logMessage(@"Mac is going to sleep");
}

BOOL trackAndFixMicrosoftSurfaceAudio(void) {
	setOnSleepCallback(onSleep);
	setOnWakeCallback(onWake);
	registerSleepAndWakeNotifications();
	
	setAudioDevicesChangedCallback(onAudioDevicesChange);
	trackAudioDevicesChanges();
	
	checkAndFixMicrosoftSurfaceAudioDevice();

	return true;
}
