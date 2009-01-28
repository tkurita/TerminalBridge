#import "TerminalClient.h"
#import "RegexKitLite.h"

#define useLog 0

static id sharedObj;

@implementation TerminalClient

- (void) dealloc
{
	[modeCommands release];
	[modePrompts release];
	[super dealloc];
}

- (id)init
{
	if (self = [super init]) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[self setModeDefaults:[userDefaults objectForKey:@"ModeDefaults"]];
		[userDefaults addObserver:self forKeyPath:@"ModeDefaults"
						  options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
	}
	
	return self;
}

+ (id)sharedTerminalClient
{
	if (sharedObj == nil) {
		sharedObj = [[self alloc] init];
	}
	return sharedObj;
}

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
		if ([theSubString isMatchedByRegex:regex_prompt]) {
			result = YES;	
		}
	} 
	
	return result;
}

- (NSNumber *)extactLastResult:(NSString *)theText withPrompt:(NSString *)thePrompt
{
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
	while(theRange.location > 0) {
		theRange.location = theRange.location - 1;
		theRange.length = 0;
		
		theRange = [theText lineRangeForRange:theRange];
		theSubString = [theText substringWithRange:theRange];
#if useLog
		NSLog(theSubString);
#endif
		if (! [theSubString isMatchedByRegex:regex_prompt]) {
			lastRange = theRange;
			break;			
		}
	}	
	
	if (theRange.location == 0) {
		return  [NSNumber numberWithInt:0];
	}
	
	// find the line start with prompt
	firstRange = lastRange;
	while(theRange.location > 0) {
		theRange.location = theRange.location - 1;
		theRange.length = 0;
		
		theRange = [theText lineRangeForRange:theRange];
		theSubString = [theText substringWithRange:theRange];
		if ([theSubString isMatchedByRegex:regex_prompt]) {
			break;
		} 
		else {
#if useLog
			NSLog(theSubString);
#endif
			firstRange = theRange;
		}
	}
	
	if (theRange.location == 0) {
		return  [NSNumber numberWithInt:-1];
	}
	
	theRange.location = firstRange.location;
	theRange.length = NSMaxRange(lastRange)-theRange.location;
	[self setLastResult:[theText substringWithRange:theRange]];

	return [NSNumber numberWithInt:1];
}

-(NSString *)lastResult {
	return _lastResult;
}

-(NSString *)lastResultWithCR {
	return [_lastResult stringByReplacingOccurrencesOfString:@"\n" withString:@"\r"];
}

-(void)setLastResult:(NSString *)theString {
	NSString *commented_result = [[theString stringByReplacingOccurrencesOfRegex:@"(?m)^" withString:@"# "] retain];
	[_lastResult release];
	_lastResult = commented_result;
}

- (NSString *)promptForMode:(NSString *)theMode
{
	return [modePrompts objectForKey:theMode];
}

- (NSString *)commandForMode:(NSString *)theMode
{
	return [modeCommands objectForKey:theMode];
}

- (NSString *)settingsNameForMode:(NSString *)theMode
{
	return [modeSettingsNames objectForKey:theMode];
}

- (void)setModeDefaults:(NSArray *)modeDefaults
{
#if useLog
	NSLog([modeDefaults description]);
#endif
	[modeCommands release];
	[modePrompts release];
	[modeSettingsNames release];
	
	unsigned nCap = [modeDefaults count];
	modeCommands = [[NSMutableDictionary dictionaryWithCapacity:nCap] retain];
	modePrompts = [[NSMutableDictionary dictionaryWithCapacity:nCap] retain];
	modeSettingsNames = [[NSMutableDictionary dictionaryWithCapacity:nCap] retain];
	
	NSEnumerator *enumerator = [modeDefaults objectEnumerator];
	NSDictionary *dict;
	NSDictionary *mode;
	NSString *a_value = nil;
	while (dict = [enumerator nextObject]) {
		mode = [dict objectForKey:@"mode"];
		[modeCommands setObject:[dict objectForKey:@"command"] forKey:mode];
		[modePrompts setObject:[dict objectForKey:@"prompt"] forKey:mode];
		if (a_value = [dict objectForKey:@"terminalSettings"]) 
			[modeSettingsNames setObject:a_value forKey:mode];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"ModeDefaults"]) {
		[self setModeDefaults:[change objectForKey:NSKeyValueChangeNewKey]];
	}
}

@end
