//
//  audioDevices.m
//  microsoftsurfaceaudiofix
//
//  Created by aone on 22/11/24.
//  https://github.com/aonez/MicrosoftSurfaceMacAudioFix
//

#import <CoreAudio/CoreAudio.h>

#import "log.h"

#import "audioDevices.h"

AudioObjectPropertyAddress getAudioObjectPropertyAddress(void) {
	AudioObjectPropertyAddress propertyAddress = {
		kAudioHardwarePropertyDevices,
		kAudioObjectPropertyScopeGlobal,
		kAudioObjectPropertyElementMain
	};
	return propertyAddress;
}

AudioDevicesChangedCallback audioDevicesChangedCallback = nil;
void setAudioDevicesChangedCallback(AudioDevicesChangedCallback callback) {
	audioDevicesChangedCallback = callback;
}

OSStatus _AudioDevicesChangedCallback(AudioObjectID objectID,
									  UInt32 numberAddresses,
									  const AudioObjectPropertyAddress addresses[],
									  void *clientData) {	
	if (audioDevicesChangedCallback) {
		audioDevicesChangedCallback();
	}
	
	return noErr;
}

void trackAudioDevicesChanges(void) {
	AudioObjectPropertyAddress propertyAddress = getAudioObjectPropertyAddress();

	OSStatus status = AudioObjectAddPropertyListener(kAudioObjectSystemObject, &propertyAddress, _AudioDevicesChangedCallback, NULL);
	if (status != noErr) {
		logMessage([NSString stringWithFormat:@"Failed to add audio devices listener: %d", status]);
	}
	logMessage(@"Listening for audio device changes");
}
