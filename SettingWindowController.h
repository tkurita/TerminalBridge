/* SettingWindowController */

#import <Cocoa/Cocoa.h>
#import "Terminal.h"

@interface SettingWindowController : NSWindowController
{
    IBOutlet id cleanCommandController;
	IBOutlet id defaultCommandController;
    IBOutlet id settingMenu;
	IBOutlet id tabView;
}

- (IBAction)addProcess:(id)sender;
- (IBAction)addModeCommand:(id)sender;
- (IBAction)showSettingHelp:(id)sender;
- (IBAction)reloadSettingsMenu:(id)sender;

@end
