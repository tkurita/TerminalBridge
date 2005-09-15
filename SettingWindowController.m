#import "SettingWindowController.h"

@implementation SettingWindowController

- (IBAction)showSettingHelp:(id)sender
{
	NSHelpManager *helpManager = [NSHelpManager sharedHelpManager];
	NSDictionary *theDict = [[NSBundle mainBundle] infoDictionary];
	NSString *bookName = [theDict objectForKey:@"CFBundleHelpBookName"];
	
	[helpManager openHelpAnchor:@"Setting" inBook:bookName];
}

- (void)awakeFromNib
{
	[[self window] center];
	[self setWindowFrameAutosaveName:@"SettingWindow"];}

@end
