#import "TerminalClient.h"

#define useLog 0

@implementation TerminalClient

- (id)init
{
	if (self = [super init]) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[self setModeDefaults:[userDefaults objectForKey:@"ModeDefaults"]];
		[userDefaults addObserver:self forKeyPath:@"ModeDefaults"
						  options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
        NSError *err = nil;
        self.lineHeadPattern = [NSRegularExpression regularExpressionWithPattern:@"(?m)^" options:0 error:&err];
	}
	
	return self;
}

#pragma mark singleton
static id sharedInstance = nil;

+ (id)sharedTerminalClient
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        (void)[[self alloc] init];
    });
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
	
	__block id ret = nil;
	
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		sharedInstance = [super allocWithZone:zone];
		ret = sharedInstance;
	});
	
	return  ret;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark methods
- (BOOL)isReadyTerminalContents:(NSString *)theText withPrompt:(NSString *)thePrompt
{
	BOOL result = NO;
	NSString *regex_prompt = thePrompt;
	if (![regex_prompt hasPrefix:@"^"])
		regex_prompt = [@"^" stringByAppendingString:regex_prompt];
	NSRange theRange = NSMakeRange([theText length],0);
	NSString *theSubString;
	
	// skip trailing empty lines
	while(theRange.location > 0) {
		theRange.location--;
		theRange.length = 0;
		theRange = [theText lineRangeForRange:theRange];
		theSubString = [theText substringWithRange:theRange];
		if ([theSubString length] > 1) {
			theRange.location++;
			break;
		}
	}
	
	if (theRange.location > 0) {
		theRange.location = theRange.location - 1;
		theRange.length = 0;
		
		theRange = [theText lineRangeForRange:theRange];
		theSubString = [theText substringWithRange:theRange];
	#if useLog
		NSLog(theSubString);
	#endif
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regex_prompt
                                                                               options:0
                                                                                 error:&error];
        if ([regex numberOfMatchesInString:theSubString options:0 range:NSMakeRange(0, theSubString.length)]) {
			result = YES;	
		}
	} 
	
	return result;
}

- (NSNumber *)extactLastResult:(NSString *)theText withPrompt:(NSString *)thePrompt
{
    /*
     -1 : can't find previous prompt. need to expand search region.
     1 : success to obtain last result
     0 : error. no result.
     */
#if useLog
	NSLog(@"start extactLastResult:");
#endif
	NSString *regex_prompt = thePrompt;
	if (![regex_prompt hasPrefix:@"^"])
		regex_prompt = [@"^" stringByAppendingString:regex_prompt];
	NSRange lastRange, firstRange;
	NSRange theRange = NSMakeRange([theText length],0);
	NSString *theSubString;
	
	// skip trailing empty lines
	while(theRange.location > 0) {
		theRange.location--;
		theRange.length = 0;
		theRange = [theText lineRangeForRange:theRange];
		theSubString = [theText substringWithRange:theRange];
		if ([theSubString length] > 1) {
			theRange.location++;
			break;
		}
	}
	
	//find last line which does not begin prompt
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regex_prompt
                                                                           options:0
                                                                             error:&error];
    if (error) {
        [NSApp presentError:error];
        return @0;
    }
    
	while(theRange.location > 0) {
		theRange.location = theRange.location - 1;
		theRange.length = 0;
		
		theRange = [theText lineRangeForRange:theRange];
		
#if useLog
		theSubString = [theText substringWithRange:theRange];
        NSLog(theSubString);
#endif
        if (! [regex numberOfMatchesInString:theText options:0 range:theRange]) {
            lastRange = theRange;
			break;
		}
	}	
	
	if (theRange.location == 0) {
		return @0; // no result.
	}
	
	// find the line start with prompt
	firstRange = lastRange;
	while(theRange.location > 0) {
		theRange.location = theRange.location - 1;
		theRange.length = 0;
		
		theRange = [theText lineRangeForRange:theRange];
        if ([regex numberOfMatchesInString:theText options:0 range:theRange]) {
			break;
		} else {
#if useLog
			NSLog(theSubString);
#endif
			firstRange = theRange;
		}
	}
	
	if (theRange.location == 0) {
		return  @-1; // can't find prompt. need to go back more.
	}
	
	theRange.location = firstRange.location;
	theRange.length = NSMaxRange(lastRange)-theRange.location;
	self.lastResult = [theText substringWithRange:theRange];

	return @1;
}

-(NSString *)lastResultWithCR {
	return [_lastResult stringByReplacingOccurrencesOfString:@"\n" withString:@"\r"];
}

-(void)setLastResult:(NSString *)theString {
    NSString *commented_result =[_lineHeadPattern
                                 stringByReplacingMatchesInString:theString
                                                        options:0
                                 range:NSMakeRange(0, theString.length)
                                 withTemplate:@"# "];
	//NSString *commented_result = [theString stringByReplacingOccurrencesOfRegex:@"(?m)^" withString:@"# "];
	_lastResult = nil;
	_lastResult = commented_result;
}

- (NSString *)promptForMode:(NSString *)theMode
{
	return _modePrompts[theMode];
}

- (NSString *)commandForMode:(NSString *)theMode
{
	return _modeCommands[theMode];
}

- (NSString *)settingsNameForMode:(NSString *)theMode
{
	return _modeSettingsNames[theMode];
}

- (void)setModeDefaults:(NSArray *)modeDefaults
{
#if useLog
	NSLog([modeDefaults description]);
#endif
	NSUInteger nCap = [modeDefaults count];
	self.modeCommands = [NSMutableDictionary dictionaryWithCapacity:nCap];
	self.modePrompts = [NSMutableDictionary dictionaryWithCapacity:nCap];
	self.modeSettingsNames = [NSMutableDictionary dictionaryWithCapacity:nCap];
	
	NSDictionary *mode;
	NSString *a_value = nil;
    for (NSDictionary *dict in [modeDefaults objectEnumerator]) {
 		mode = [dict objectForKey:@"mode"];
		_modeCommands[mode] = dict[@"command"];
		_modePrompts[mode] =  dict[@"prompt"];
		if ((a_value = dict[@"terminalSettings"]))
			_modeSettingsNames[mode] = a_value;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"ModeDefaults"]) {
		[self setModeDefaults:[change objectForKey:NSKeyValueChangeNewKey]];
	}
}

@end
