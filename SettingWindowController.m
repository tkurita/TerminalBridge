#import "SettingWindowController.h"
#import "DefaultToNilTransformer.h"
#import "AppController.h"
#import "Terminal.h"

@implementation SettingWindowController
+ (void)initialize
{	
	DefaultToNilTransformer *transformer = [[DefaultToNilTransformer alloc] init];
	[transformer setNilWord:@"Default"];
	[NSValueTransformer setValueTransformer:transformer forName:@"DefaultToNil"];
	transformer = [[DefaultToNilTransformer alloc] init];
	[transformer setNilWord:@"No Change"];
	[NSValueTransformer setValueTransformer:transformer forName:@"NoChangeToNil"];
}

- (IBAction)addModeCommand:(id)sender
{
	NSMutableDictionary *newObj = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"new_mode",@"mode",@"new_command",@"command",@"new_prompt",@"prompt",nil]; 
	[defaultCommandController addObject:newObj];
	[defaultCommandController setSelectedObjects:@[newObj]];
}

- (IBAction)showSettingHelp:(id)sender
{
	NSHelpManager *helpManager = [NSHelpManager sharedHelpManager];
	NSDictionary *theDict = [[NSBundle mainBundle] infoDictionary];
	NSString *bookName = theDict[@"CFBundleHelpBookName"];
	
	[helpManager openHelpAnchor:@"Setting" inBook:bookName];
}

- (IBAction)reloadSettingsMenu:(id)sender
{
	TerminalApplication *termapp = [SBApplication applicationWithBundleIdentifier:@"com.apple.Terminal"];
	NSArray *names = [[termapp settingsSets] arrayByApplyingSelector:@selector(name)];
	names = [names sortedArrayUsingSelector:@selector(localizedCompare:)];
	
	NSString *selected_title = [[settingMenu selectedItem] title];
	NSUInteger nitems = [[settingMenu itemArray] count];
	
	for (NSUInteger n = nitems-1; n > 1; n--) {
		[settingMenu removeItemAtIndex:n];
	}
	[settingMenu addItemsWithTitles:names];	
	[settingMenu selectItemWithTitle:selected_title];

	nitems = [[interactiveProcessSettingsMenu itemArray] count];
	
	for (NSUInteger n = nitems-1; n > 1; n--) {
		[interactiveProcessSettingsMenu removeItemAtIndex:n];
	}
	[interactiveProcessSettingsMenu addItemsWithTitles:names];	
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
		[app_controller revertToFactoryDefaultForKey:@"ModeDefaults"];
	}
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	[self reloadSettingsMenu:self];
}

- (IBAction)showWindow:(id)sender
{
	[super showWindow:sender];
	[self reloadSettingsMenu:self];
}

- (void)awakeFromNib
{
	[[self window] center];
	[self setWindowFrameAutosaveName:@"SettingWindow"];
	[[[settingMenu menu] itemAtIndex:0] setTitle:NSLocalizedString(@"Default",@"")];
}

@end
