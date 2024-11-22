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

/*
typedef struct {
	UInt32 deviceCount;
	AudioObjectID * audioDevices;
} AudioDevicesInformation;

AudioDevicesInformation getAudioDevices(void) {
	UInt32 dataSize = 0;
	AudioObjectPropertyAddress propertyAddress = getAudioObjectPropertyAddress();
	AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize);
	
	AudioDevicesInformation audioDevicesInformation;
	audioDevicesInformation.deviceCount = (UInt32)(dataSize / sizeof(AudioObjectID));
	audioDevicesInformation.audioDevices = (AudioObjectID *)malloc(dataSize);
	
	AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize, audioDevicesInformation.audioDevices);
	
	return audioDevicesInformation;
}

void listAudioDevices(void) {
	UInt32 dataSize = 0;
	AudioObjectPropertyAddress propertyAddress = getAudioObjectPropertyAddress();
	AudioDevicesInformation audioDevicesInformation = getAudioDevices();
	
	for (UInt32 i = 0; i < audioDevicesInformation.deviceCount; i++) {
		AudioObjectID deviceID = audioDevicesInformation.audioDevices[i];
		CFStringRef deviceName = NULL;
		propertyAddress.mSelector = kAudioObjectPropertyName;
		dataSize = sizeof(CFStringRef);
		if (AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, NULL, &dataSize, &deviceName) == noErr) {
			logMessage((__bridge NSString *)deviceName);
			CFRelease(deviceName);
		}
	}
}

BOOL checkAudioDeviceExists(CFStringRef audioDeviceName, NSMutableArray<NSNumber *> **audioDeviceIDs) {
	UInt32 dataSize = 0;
	AudioObjectPropertyAddress propertyAddress = getAudioObjectPropertyAddress();
	AudioDevicesInformation audioDevicesInformation = getAudioDevices();
	*audioDeviceIDs = [NSMutableArray array];

	for (UInt32 i = 0; i < audioDevicesInformation.deviceCount; i++) {
		AudioObjectID deviceID = audioDevicesInformation.audioDevices[i];
		CFStringRef deviceName = NULL;
		propertyAddress.mSelector = kAudioObjectPropertyName;
		dataSize = sizeof(CFStringRef);
		if (AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, NULL, &dataSize, &deviceName) == noErr) {
			if (deviceName && CFStringCompare(audioDeviceName, deviceName, kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
				[*audioDeviceIDs addObject:[NSNumber numberWithUnsignedInt:deviceID]];
				logMessage([NSString stringWithFormat:@"Audio device found at %i: %@", i, deviceName]);
			}
			if (deviceName) {
				CFRelease(deviceName);
			}
		}
	}
	
	return (*audioDeviceIDs).count > 0;
}

BOOL checkAudioDeviceHasAvailableFormats(AudioObjectID deviceID, CFStringRef audioDeviceName) {
	UInt32 size;
	OSStatus status;
	
	AudioObjectPropertyAddress propertyAddress = {
		kAudioDevicePropertyStreamConfiguration,
		kAudioObjectPropertyScopeOutput, // Use kAudioObjectPropertyScopeInput for input formats
		kAudioObjectPropertyElementMain
	};
	
	status = AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, NULL, &size);
	if (status != noErr) {
		logMessage([NSString stringWithFormat:@"Error %i getting property size for audio device: %@", status, audioDeviceName]);
		return false;
	}
	
	AudioBufferList *bufferList = (AudioBufferList *)malloc(size);
	if (!bufferList) {
		logMessage([NSString stringWithFormat:@"Failed to allocate memory for buffer list for audio device: %@", audioDeviceName]);
		return false;
	}
	
	status = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, NULL, &size, bufferList);
	if (status != noErr) {
		logMessage([NSString stringWithFormat:@"Error %i getting property data for audio device: %@", status, audioDeviceName]);
		free(bufferList);
		return false;
	}
	
	int mNumberBuffers = bufferList->mNumberBuffers;
	free(bufferList);
	
	return mNumberBuffers > 0;
}
*/

AudioDevicesChangedCallback audioDevicesChangedCallback = nil;
void setAudioDevicesChangedCallback(AudioDevicesChangedCallback callback) {
	audioDevicesChangedCallback = callback;
}

OSStatus _AudioDevicesChangedCallback(AudioObjectID objectID,
									  UInt32 numberAddresses,
									  const AudioObjectPropertyAddress addresses[],
									  void *clientData) {
	logMessage(@"Audio devices changed");
	
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
