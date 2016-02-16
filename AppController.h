/* AppController */

#import <Cocoa/Cocoa.h>

@interface AppController : NSObject
{
	IBOutlet NSWindow *cantExecWindow;
	IBOutlet NSTextView *processListView;
	IBOutlet NSButton *addProcessButton;
	IBOutlet NSButton *showTerminalButton;
	IBOutlet id terminalBridgeController;
	IBOutlet NSWindow *startupWindow;
}

@property(retain) NSString *terminalName;
@property(retain) NSDictionary *factoryDefaults;
@property(retain) NSTimer *appQuitTimer;

+ (id)sharedAppController;

- (IBAction)closeWindow:(id)sender;

- (IBAction)cancelCantExecWindow:(id)sender;
- (IBAction)newTermCantExecWindow:(id)sender;
- (IBAction)addProcessesCantExecWindow:(id)sender;
- (IBAction)showTermCantExecWindow:(id)sender;
- (NSString *)displayCantExecWindowForTerminalName:(NSString *)termname processes:(NSArray *)processes;

- (void)anApplicationIsTerminated:(NSNotification *)aNotification;
- (void)checkQuit:(NSTimer *)aTimer;
- (id)factoryDefaultForKey:(NSString *)theKey;
- (void)revertToFactoryDefaultForKey:(NSString *)theKey;
- (id)terminalBridgeController;

@end
