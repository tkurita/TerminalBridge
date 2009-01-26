/* SettingWindowController */

#import <Cocoa/Cocoa.h>

@interface SettingWindowController : NSWindowController
{
    IBOutlet id cleanCommandController;
	IBOutlet id defaultCommandController;
    IBOutlet NSPopUpButton* settingMenu;
	IBOutlet NSTabView* tabView;
	IBOutlet id interactiveProcessSettingsMenu;
}

- (IBAction)addModeCommand:(id)sender;
- (IBAction)showSettingHelp:(id)sender;
- (IBAction)reloadSettingsMenu:(id)sender;
- (IBAction)revertToFactoryDefaults:(id)sender;

@end
