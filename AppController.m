#import "AppController.h"

#define useLog 0

@implementation AppController

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
}

@end