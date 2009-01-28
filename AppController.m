#import "AppController.h"
#import "DelimedStringToArrayTransformer.h"
#import "DonationReminder/DonationReminder.h"
#define useLog 0

static id sharedObj = nil;

enum cantExecWindowResult {
	CANTEXEC_CANCEL,
	CANTEXEC_NEWTERM,
	CANTEXEC_ADDPROCESSES,
	CANTEXEC_SHOWTERM
};

@implementation AppController
@synthesize terminalName;

+ (void)initialize	// Early initialization
{	
	NSValueTransformer *transformer = [[[DelimedStringToArrayTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer forName:@"DelimedStringToArrayTransformer"];
}

+ (id)sharedAppController
{
	if (sharedObj == nil) {
		sharedObj = [[self alloc] init];
	}
	return sharedObj;
}

- (id)init
{
	if (self = [super init]) {
		if (sharedObj == nil) {
			sharedObj = self;
		}
	}
	
	return self;
}

- (void)checkQuit:(NSTimer *)aTimer
{
	NSArray *appList = [[NSWorkspace sharedWorkspace] launchedApplications];
	NSEnumerator *enumerator = [appList objectEnumerator];
	
	id appDict;
	BOOL isMiLaunched = NO;
	while (appDict = [enumerator nextObject]) {
		NSString *appName = [appDict objectForKey:@"NSApplicationName"];
		if ([appName isEqualToString:@"mi"] ) {
			isMiLaunched = YES;
			break;
		}
	}
	
	if (! isMiLaunched) {
		[[NSApplication sharedApplication] terminate:self];
	}
}

- (void)anApplicationIsTerminated:(NSNotification *)aNotification
{
#if useLog
	NSLog(@"anApplicationIsTerminated");
#endif
	NSString *appName = [[aNotification userInfo] objectForKey:@"NSApplicationName"];
	//NSLog(appName);
	if ([appName isEqualToString:@"mi"] ) [[NSApplication sharedApplication] terminate:self];
}

- (IBAction)closeWindow:(id)sender
{
	[[NSApp mainWindow] close];
}


#pragma mark methods for factory settings
- (void)revertToFactoryDefaultForKey:(NSString *)theKey
{
	id factorySetting = [factoryDefaults objectForKey:theKey];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:factorySetting forKey:theKey];
}

- (id)factoryDefaultForKey:(NSString *)theKey
{
#if useLog
	NSLog(@"call farcotryDefaultForKey");
#endif
	return [factoryDefaults objectForKey:theKey];
}

#pragma mark delegate of NSApplication

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
#if useLog
	NSLog(@"start applicationWillFinishLaunching");
#endif
	NSString *defaultsPlistPath = [[NSBundle mainBundle] pathForResource:@"FactorySettings" ofType:@"plist"];
	factoryDefaults = [[NSDictionary dictionaryWithContentsOfFile:defaultsPlistPath] retain];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults registerDefaults:factoryDefaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#if useLog
	NSLog(@"start applicationDidFinishLaunching");
#endif
	
	appQuitTimer = [NSTimer scheduledTimerWithTimeInterval:60*60 target:self selector:@selector(checkQuit:) userInfo:nil repeats:YES];
	[appQuitTimer retain];
	
	NSNotificationCenter *notifyCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
	[notifyCenter addObserver:self selector:@selector(anApplicationIsTerminated:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
	
	[DonationReminder remindDonation];
}

#pragma mark methods for can't exec window
- (IBAction)cancelCantExecWindow:(id)sender
{
	[[NSApplication sharedApplication] stopModalWithCode:CANTEXEC_CANCEL];
}

- (IBAction)newTermCantExecWindow:(id)sender
{
	[[NSApplication sharedApplication] stopModalWithCode:CANTEXEC_NEWTERM];	
}

- (IBAction)addProcessesCantExecWindow:(id)sender
{
	[[NSApplication sharedApplication] stopModalWithCode:CANTEXEC_ADDPROCESSES];	
}

- (IBAction)showTermCantExecWindow:(id)sender
{
	[[NSApplication sharedApplication] stopModalWithCode:CANTEXEC_SHOWTERM];	
}

- (NSString *)displayCantExecWindowForTerminalName:(NSString *)termname processes:(NSArray *)processes
{
	[self setTerminalName:termname];
	if ([processes count]) {
		[processListView setString:[processes componentsJoinedByString:@"\n"]];
		[addProcessButton setEnabled:YES];
	} else {
		[processListView setString:@""];
		[addProcessButton setEnabled:NO];
	}
	[cantExecWindow center];
	NSString *result;
	int result_code = [[NSApplication sharedApplication] runModalForWindow:cantExecWindow];
    [cantExecWindow orderOut:self];
    
	switch (result_code) {
		case CANTEXEC_CANCEL:
			result = @"Cancel";
			break;
		case CANTEXEC_NEWTERM:
			result = @"NewTerminal";
			break;
		case CANTEXEC_ADDPROCESSES:
			result = @"AddProcesses";
			break;
		case CANTEXEC_SHOWTERM:
			result = @"ShowTerminal";
			break;
		case NSRunAbortedResponse:
			result = @"Cancel";
			break;
		default:
			result = @"Cancel";
			break;
	}
	return result;
}

@end
