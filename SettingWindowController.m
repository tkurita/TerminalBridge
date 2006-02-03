#import "SettingWindowController.h"

@implementation SettingWindowController

- (IBAction)insert:(id)sender
{
	//[arrayController insertObject:[NSDictionary dictionaryWithObject:@"process" forKey:@"process"] atArrangedObjectIndex:2];
	NSMutableDictionary *newObj = [NSMutableDictionary dictionaryWithObject:@"new_process" forKey:@"process"];
	[arrayController addObject:newObj];
	[arrayController setSelectedObjects:[NSArray arrayWithObject:newObj]];
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
	[self setWindowFrameAutosaveName:@"SettingWindow"];}

@end
