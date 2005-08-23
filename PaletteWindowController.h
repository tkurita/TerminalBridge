/* PaletteWindowController */

#import <Cocoa/Cocoa.h>

@interface PaletteWindowController : NSWindowController
{
	NSTimer *displayToggleTime;
	BOOL isCollapsed;
	NSRect expandedRect;
	NSString *frameName;
	id contentViewBuffer;
	NSArray *applicationsFloatingOn;
}

//accessor methods
- (void)setFrameName:(NSString *)theName;

//setup behavior
- (void)setApplicationsFloatingOnFromDefaultName:(NSString *)entryName;
- (void)useWindowCollapse;
- (void)useFloating;

//methods for override
- (void)saveDefaults;

//private
- (void)collapseAction;
- (void)setDisplayToggleTime;
- (void)updateVisibility:(NSTimer *)theTimer;
- (float)titleBarHeight;
- (void)toggleCollapseWithAnimate:(BOOL)flag;
- (void)willApplicationQuit:(NSNotification *)aNotification;

@end
