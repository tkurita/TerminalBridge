#import "ShowHelpCommand.h"


@implementation ShowHelpCommand
- (id)performDefaultImplementation
{
	[NSApp showHelp:self];
	return nil;
}
@end
