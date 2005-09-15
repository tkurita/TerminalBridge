/* PaletteWindowController */

#import <Cocoa/Cocoa.h>

@interface PaletteWindowController : NSWindowController
{
	NSTimer *displayToggleTimer;
	BOOL isCollapsed;
	NSRect expandedRect;
	NSString *frameName;
	id contentViewBuffer;
	NSArray *applicationsFloatingOn;
	NSString *applicationsFloatingOnKeyPath;
	NSString *applicationsFloatingOnEntryName;
}

//accessor methods
- (void)setFrameName:(NSString *)theName;
- (void)setApplicationsFloagingOn:(NSArray *)appList;

//setup behavior
- (void)bindApplicationsFloatingOnForKey:(NSString *)theKeyPath;
- (void)setApplicationsFloatingOnFromDefaultName:(NSString *)entryName;
- (void)useWindowCollapse;
- (void)useFloating;
- (BOOL)isWorkingDisplayToggleTimer;

//methods for override
- (void)saveDefaults;

//private
- (void)collapseAction;
- (void)setDisplayToggleTimer;
- (void)updateVisibility:(NSTimer *)theTimer;
- (float)titleBarHeight;
- (void)toggleCollapseWithAnimate:(BOOL)flag;
- (void)willApplicationQuit:(NSNotification *)aNotification;

@end
