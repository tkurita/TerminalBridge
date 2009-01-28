#import <Cocoa/Cocoa.h>


@interface TerminalClient : NSObject {
	NSMutableDictionary *modeCommands;
	NSMutableDictionary *modePrompts;
	NSMutableDictionary *modeSettingsNames;
	NSString *_lastResult;
}

+ (id)sharedTerminalClient;
- (NSNumber *)extactLastResult:(NSString *)theText withPrompt:(NSString *)thePrompt;
- (NSString *)promptForMode:(NSString *)theMode;
- (NSString *)commandForMode:(NSString *)theMode;

- (void)setModeDefaults:(NSArray *)modeDefaults;
-(void)setLastResult:(NSString *)theString;
-(NSString *)lastResultWithCR;
-(NSString *)lastResult;
@end
