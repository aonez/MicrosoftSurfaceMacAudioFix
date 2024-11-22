//
//  main.m
//  MicrosoftSurfaceAudioFix
//
//  Created by aone on 21/11/24.
//  https://github.com/aonez/MicrosoftSurfaceMacAudioFix
//

#import "log.h"

#import "microsoftSurfaceAudioFix.h"

BOOL needsRunLoop = false;

int main(int argc, const char *argv[]) {
	#if DEBUG
	//skipMicrosoftSurfaceAudioFix = true;
	#endif
	@autoreleasepool {
		
		if (!skipMicrosoftSurfaceAudioFix) {
			needsRunLoop = trackAndFixMicrosoftSurfaceAudio();
		}
		
		if (needsRunLoop) {
			[[NSRunLoop currentRunLoop] run];
		}
		
	}
	return 0;
}

