/* AppController */

#import <Cocoa/Cocoa.h>

@interface AppController : NSObject
{
	NSTimer *appQuitTimer;
}

- (void)anApplicationIsTerminated:(NSNotification *)aNotification;
- (void)checkQuit:(NSTimer *)aTimer;

@end
