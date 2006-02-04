#import "SettingWindowController.h"

@implementation SettingWindowController

- (IBAction)addProcess:(id)sender
{
	NSMutableDictionary *newObj = [NSMutableDictionary dictionaryWithObject:@"new_process" forKey:@"process"];
	[cleanCommandController addObject:newObj];
	[cleanCommandController setSelectedObjects:[NSArray arrayWithObject:newObj]];
}

- (IBAction)addModeCommand:(id)sender
{
	NSMutableDictionary *newObj = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"new_mode",@"mode",@"new_command",@"command",nil]; 
	[defaultCommandController addObject:newObj];
	[defaultCommandController setSelectedObjects:[NSArray arrayWithObject:newObj]];
}

- (IBAction)showSettingHelp:(id)sender
{
	NSHelpManager *helpManager = [NSHelpManager sharedHelpManager];
	NSDictionary *theDict = [[NSBundle mainBundle] infoDictionary];
	NSString *bookName = [theDict objectForKey:@"CFBundleHelpBookName"];
	
	[helpManager openHelpAnchor:@"Setting" inBook:bookName];
}

- (BOOL)windowShouldClose:(id)sender
{
	/* To support AppleScript Studio of MacOS X 10.4 */
	[[self window] orderOut:self];
	return NO;
}

- (void)awakeFromNib
{
	[[self window] center];
	[self setWindowFrameAutosaveName:@"SettingWindow"];
}

@end
