/* AppController */

#import <Cocoa/Cocoa.h>

@interface AppController : NSObject
{
	NSTimer *appQuitTimer;
	NSDictionary *factoryDefaults;	
}
- (IBAction)closeWindow:(id)sender;

- (void)anApplicationIsTerminated:(NSNotification *)aNotification;
- (void)checkQuit:(NSTimer *)aTimer;
- (id)factoryDefaultForKey:(NSString *)theKey;
- (void)revertToFactoryDefaultForKey:(NSString *)theKey;

@end
