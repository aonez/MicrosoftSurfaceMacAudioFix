//
//  log.m
//  MicrosoftSurfaceAudioFix
//
//  Created by aone on 21/11/24.
//  https://github.com/aonez/MicrosoftSurfaceMacAudioFix
//

#import "log.h"

void logMessage(NSString *message) {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *timestamp = [formatter stringFromDate:[NSDate date]];
	NSString *formattedMessage = [NSString stringWithFormat:@"[%@] %@", timestamp, message];
	NSLog(@"%@", formattedMessage);
}
