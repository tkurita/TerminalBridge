#import "PaletteWindowController.h"

#define useLog 0

@implementation PaletteWindowController

#pragma mark init and actions

- (IBAction)showWindow:(id)sender
{
#if useLog
	NSLog(@"start showWindow");
#endif
	id theWindow = [self window];
	[theWindow center];
	[theWindow setFrameUsingName:frameName];
	
	[super showWindow:sender];
	[self setDisplayToggleTime];

	NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
	[notiCenter addObserver:self selector:@selector(willApplicationQuit:) name:NSApplicationWillTerminateNotification object:nil];	
}

- (void)dealloc
{
	[frameName release];
	[applicationsFloatingOn release];
	[contentViewBuffer release];
	
	[super dealloc];
}

- (void)setFrameName:(NSString *)theName
{
	[frameName autorelease];
	frameName = [theName retain];
}

- (void)setApplicationsFloatingOnFromDefaultName:(NSString *)entryName
{
#if useLog
	NSLog(@"setApplicationsFloatingOnFromDefaultName");
#endif
	[applicationsFloatingOn autorelease];
	applicationsFloatingOn = [[[NSUserDefaults standardUserDefaults] arrayForKey:entryName] retain];
}

#pragma mark methods for others
- (void)willApplicationQuit:(NSNotification *)aNotification
{
	[self saveDefaults];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveDefaults
{
	NSWindow *theWindow = [self window];
	if (!isCollapsed) [theWindow saveFrameUsingName:frameName];
}

- (void)useFloating
{
	id theWindow = [self window];
	[theWindow setHidesOnDeactivate:NO];
	[theWindow setLevel:NSFloatingWindowLevel];
}


#pragma mark methods for collapsing
- (float)titleBarHeight
{
	id theWindow = [self window];
	 NSRect windowRect = [theWindow frame];
	 NSRect contentRect = [NSWindow contentRectForFrameRect:windowRect
												  styleMask:[theWindow styleMask]];
	 //NSRect contentRect = [[theWindow contentView] frame];
	 return NSHeight(windowRect) - NSHeight(contentRect);
}

- (void)collapseAction
{
	[self toggleCollapseWithAnimate:NO];
}

- (void)toggleCollapseWithAnimate:(BOOL)flag
{
	NSWindow *theWindow = [self window];
	NSRect windowRect = [theWindow frame];

	if (isCollapsed) {
		windowRect.origin.y = windowRect.origin.y - expandedRect.size.height + windowRect.size.height;
		windowRect.size.height = expandedRect.size.height;
		[theWindow setFrame:windowRect display:YES animate:flag];
		[theWindow saveFrameUsingName:frameName];
		[theWindow setContentView:contentViewBuffer];
		isCollapsed = NO;
		
	}
	else {
		expandedRect = windowRect;
		NSRect contentRect = [NSWindow contentRectForFrameRect:windowRect styleMask:[theWindow styleMask]];
		windowRect.origin.y = windowRect.origin.y + NSHeight(contentRect);
		windowRect.size.height = NSHeight(windowRect) - NSHeight(contentRect);
		[theWindow saveFrameUsingName:frameName];
		[theWindow setContentView:nil];
		[theWindow setFrame:windowRect display:YES animate:flag];
		
		isCollapsed = YES;		
	}
}

- (void)updateVisibility:(NSTimer *)theTimer
{
#if useLog
	NSLog(@"updateVisibility:");
#endif
	NSString *appName = [[[NSWorkspace sharedWorkspace] activeApplication] objectForKey:@"NSApplicationName"];
	if (appName == nil) {
		return;
	}

	id theWindow = [self window];

	if ([applicationsFloatingOn containsObject:appName]){
		if (![theWindow isVisible]) [super showWindow:self];
	}
	else {
		if ([theWindow isVisible]) {
			if ([theWindow attachedSheet] == nil) [self close];	
		}
	}
}

- (void)setDisplayToggleTime
{
#if useLog
	NSLog(@"setDisplayToggleTime");
#endif
	if (displayToggleTime != nil) {
		[displayToggleTime invalidate];
	}
	[displayToggleTime release];
	displayToggleTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateVisibility:) userInfo:nil repeats:YES];
	[displayToggleTime retain];
}

- (void)useWindowCollapse
{
	isCollapsed = NO;
	id theWindow = [self window];
	contentViewBuffer = [[theWindow contentView] retain];
	NSButton *zoomButton = [theWindow standardWindowButton:NSWindowZoomButton];
	[zoomButton setTarget:self];
	[zoomButton setAction:@selector(collapseAction)];
}

#pragma mark delegates and overriding methods
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
	if (isCollapsed) {
		NSRect currentRect = [sender frame];
		return currentRect.size;
	}
	else {
		return proposedFrameSize;
	}
}

- (void)windowWillClose:(NSNotification *)aNotification
{
#if useLog
	NSLog(@"start windowWillClose:");
#endif
	[self saveDefaults];
}

- (BOOL)windowShouldClose:(id)sender
{
#if useLog
	NSLog(@"start windowShouldClose");
#endif
	if (displayToggleTime != nil) {
		[displayToggleTime invalidate];
	}
	[self saveDefaults];
	return YES;
}

@end
