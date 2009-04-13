/* AppController */

#import <Cocoa/Cocoa.h>

@interface AppController : NSObject
{
	NSTimer *appQuitTimer;
	NSDictionary *factoryDefaults;
	IBOutlet NSWindow *cantExecWindow;
	IBOutlet NSTextView *processListView;
	IBOutlet NSButton *addProcessButton;
	IBOutlet NSButton *showTerminalButton;
	NSString *terminalName;
}

@property(retain, readwrite) NSString *terminalName;

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


@end
