//
//  powerManagement.h
//  MicrosoftSurfaceAudioFix
//
//  Created by aone on 22/11/24.
//  https://github.com/aonez/MicrosoftSurfaceMacAudioFix
//

#import <Foundation/Foundation.h>

typedef void (*SleepCallback)(void);
typedef void (*WakeCallback)(void);

void setOnSleepCallback(SleepCallback callback);
void setOnWakeCallback(WakeCallback callback);

void registerSleepAndWakeNotifications(void);
