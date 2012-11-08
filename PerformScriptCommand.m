#import "PerformScriptCommand.h"
#import "AppController.h"

@implementation PerformScriptCommand

- (id)performDefaultImplementation
{
	//NSLog(@"%@", [self directParameter]);
	NSAppleEventDescriptor *desc =  [[self arguments] objectForKey:@"withScript"];
	[[[AppController sharedAppController] terminalBridgeController] performTask:desc];
	return nil;
}

@end
