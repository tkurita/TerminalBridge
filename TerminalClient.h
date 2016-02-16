#import <Cocoa/Cocoa.h>


@interface TerminalClient : NSObject {
}

@property (retain) NSMutableDictionary *modeCommands;
@property (retain) NSMutableDictionary *modePrompts;
@property (retain) NSMutableDictionary *modeSettingsNames;
@property (retain) NSString *lastResult;

+ (id)sharedTerminalClient;
- (NSNumber *)extactLastResult:(NSString *)theText withPrompt:(NSString *)thePrompt;
- (NSString *)promptForMode:(NSString *)theMode;
- (NSString *)commandForMode:(NSString *)theMode;

- (void)setModeDefaults:(NSArray *)modeDefaults;
-(void)setLastResult:(NSString *)theString;
-(NSString *)lastResultWithCR;
-(NSString *)lastResult;
@end
