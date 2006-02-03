/* SettingWindowController */

#import <Cocoa/Cocoa.h>

@interface SettingWindowController : NSWindowController
{
    IBOutlet id arrayController;
}
- (IBAction)insert:(id)sender;
- (IBAction)showSettingHelp:(id)sender;

@end
