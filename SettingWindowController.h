/* SettingWindowController */

#import <Cocoa/Cocoa.h>
#import "Terminal.h"

@interface SettingWindowController : NSWindowController
{
    IBOutlet id cleanCommandController;
	IBOutlet id defaultCommandController;
    IBOutlet NSPopUpButton* settingMenu;
	IBOutlet NSTabView* tabView;
}

- (IBAction)addProcess:(id)sender;
- (IBAction)addModeCommand:(id)sender;
- (IBAction)showSettingHelp:(id)sender;
- (IBAction)reloadSettingsMenu:(id)sender;
- (IBAction)revertToFactoryDefaults:(id)sender;

@end
