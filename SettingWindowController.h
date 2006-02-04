/* SettingWindowController */

#import <Cocoa/Cocoa.h>

@interface SettingWindowController : NSWindowController
{
    IBOutlet id cleanCommandController;
	IBOutlet id defaultCommandController;
}
- (IBAction)addProcess:(id)sender;
- (IBAction)addModeCommand:(id)sender;
- (IBAction)showSettingHelp:(id)sender;

@end
