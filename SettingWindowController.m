#import "SettingWindowController.h"
#import "DefaultToNilTransformer.h"
#import "AppController.h"
#import "Terminal.h"

@implementation SettingWindowController
+ (void)initialize
{	
	NSValueTransformer *transformer = [[[DefaultToNilTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer forName:@"DefaultToNil"];
}

- (IBAction)addProcess:(id)sender
{
	NSMutableDictionary *newObj = [NSMutableDictionary dictionaryWithObject:@"new_process" forKey:@"process"];
	[cleanCommandController addObject:newObj];
	[cleanCommandController setSelectedObjects:[NSArray arrayWithObject:newObj]];
}

- (IBAction)addModeCommand:(id)sender
{
	NSMutableDictionary *newObj = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"new_mode",@"mode",@"new_command",@"command",@"new_prompt",@"prompt",nil]; 
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

- (IBAction)reloadSettingsMenu:(id)sender
{
	TerminalApplication *termapp = [SBApplication applicationWithBundleIdentifier:@"com.apple.Terminal"];
	NSArray *names = [[termapp settingsSets] arrayByApplyingSelector:@selector(name)];
	
	NSString *selected_title = [[settingMenu selectedItem] title];
	NSUInteger nitems = [[settingMenu itemArray] count];
	for (int n = nitems-1; n > 1; n--) {
		[settingMenu removeItemAtIndex:n];
	}
	[settingMenu addItemsWithTitles:names];	
	[settingMenu selectItemWithTitle:selected_title];
}

- (IBAction)revertToFactoryDefaults:(id)sender
{
	NSString *identifier = [[tabView selectedTabViewItem] identifier];
	AppController* app_controller = [AppController sharedAppController];
	if ([identifier isEqualToString:@"TerminalSettings"]) {
		[app_controller revertToFactoryDefaultForKey:@"ExecutionString"];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SettingsSetName"];
	}
	else if ([identifier isEqualToString:@"CommandsAndProcesses"]) {
		[app_controller revertToFactoryDefaultForKey:@"CleanCommands"];
		[app_controller revertToFactoryDefaultForKey:@"ModeDefaults"];
	}
}

- (BOOL)windowShouldClose:(id)sender
{
	/* To support AppleScript Studio of MacOS X 10.4 */
	[[self window] orderOut:self];
	return NO;
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	if ([[tabViewItem identifier] isEqualToString:@"TerminalSettings"]) {
		[self reloadSettingsMenu:self];
	}
}

- (IBAction)showWindow:(id)sender
{
	[super showWindow:sender];
	if ([[[tabView selectedTabViewItem] identifier] isEqualToString:@"TerminalSettings"]) {
		[self reloadSettingsMenu:self];
	}
}

- (void)awakeFromNib
{
	[[self window] center];
	[self setWindowFrameAutosaveName:@"SettingWindow"];
	[DefaultToNilTransformer setPopupMenu:settingMenu];
}

@end
