//
//  audioDevices.h
//  microsoftsurfaceaudiofix
//
//  Created by aone on 22/11/24.
//  https://github.com/aonez/MicrosoftSurfaceMacAudioFix
//

#import <Foundation/Foundation.h>

//BOOL checkAudioDeviceExists(CFStringRef audioDeviceName, NSMutableArray<NSNumber *> **audioDeviceIDs);
//BOOL checkAudioDeviceHasAvailableFormats(UInt32 deviceID, CFStringRef audioDeviceName);

typedef void (*AudioDevicesChangedCallback)(void);
void setAudioDevicesChangedCallback(AudioDevicesChangedCallback callback);

void trackAudioDevicesChanges(void);
