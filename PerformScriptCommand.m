#import "PerformScriptCommand.h"
#import "AppController.h"

@interface TerminalBridgeController : NSObject
- (void) performTask:(NSAppleEventDescriptor *)desc;
@end

@implementation PerformScriptCommand

- (id)performDefaultImplementation
{
	//NSLog(@"%@", [self directParameter]);
	NSAppleEventDescriptor *desc =  [[self arguments] objectForKey:@"withScript"];
	[[[AppController sharedAppController] terminalBridgeController] performTask:desc];
	return nil;
}

@end
