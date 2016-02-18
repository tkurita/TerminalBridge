#import <Cocoa/Cocoa.h>


@interface TerminalClient : NSObject {
}

@property (strong) NSMutableDictionary *modeCommands;
@property (strong) NSMutableDictionary *modePrompts;
@property (strong) NSMutableDictionary *modeSettingsNames;
@property (nonatomic, strong) NSString *lastResult;
@property (strong) NSRegularExpression *lineHeadPattern;

+ (id)sharedTerminalClient;
- (NSNumber *)extactLastResult:(NSString *)theText withPrompt:(NSString *)thePrompt;
- (NSString *)promptForMode:(NSString *)theMode;
- (NSString *)commandForMode:(NSString *)theMode;

- (void)setModeDefaults:(NSArray *)modeDefaults;
-(void)setLastResult:(NSString *)theString;
-(NSString *)lastResultWithCR;
-(NSString *)lastResult;
@end
