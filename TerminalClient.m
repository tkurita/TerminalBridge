#import "TerminalClient.h"
#import <OgreKit/OgreKit.h>

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

- (NSNumber *)extactLastResult:(NSString *)theText withPrompt:(NSString *)thePrompt
{
	NSLog(@"start extactLastResult:");
	OGRegularExpression *regex = [OGRegularExpression regularExpressionWithString:[@"^" stringByAppendingString:thePrompt]];
	//theText = @"a\nb\nc";
	
	NSRange lastRange, firstRange;
	NSRange theRange = NSMakeRange([theText length],0);
	NSString *theSubString;
	OGRegularExpressionMatch *match;
	
	//find last line which does not begin prompt
	while(theRange.location > 0) {
		theRange.location = theRange.location - 1;
		theRange.length = 0;
		
		theRange = [theText lineRangeForRange:theRange];
		theSubString = [theText substringWithRange:theRange];
		match = [regex matchInString:theSubString];
		NSLog(theSubString);
		if (match == nil) {
			NSLog(theSubString);
			//NSLog([match matchedString]);
			lastRange = theRange;
			break;
		}
	}
	
	if (theRange.location == 0) {
		return  [NSNumber numberWithInt:0];
	}
	
	while(theRange.location > 0) {
		theRange.location = theRange.location - 1;
		theRange.length = 0;
		
		theRange = [theText lineRangeForRange:theRange];
		theSubString = [theText substringWithRange:theRange];
		match = [regex matchInString:theSubString];
		if (match != nil) {
			break;
		} 
		else {
			NSLog(theSubString);
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
	return [OGRegularExpression replaceNewlineCharactersInString:_lastResult 
															  withCharacter:OgreCrNewlineCharacter];
}

-(void)setLastResult:(NSString *)theString {
	OGRegularExpression *regex = [OGRegularExpression regularExpressionWithString:@"^"];
	theString = [regex replaceAllMatchesInString:theString withString:@"#"];
	[theString retain];
	[_lastResult release];
	_lastResult = theString;
}

- (NSString *)promptForMode:(NSString *)theMode
{
	return [modePrompts objectForKey:theMode];
}

- (NSString *)commandForMode:(NSString *)theMode
{
	return [modeCommands objectForKey:theMode];
}

- (void)setModeDefaults:(NSArray *)modeDefaults
{
	//NSLog([modeDefaults description]);
	[modeCommands release];
	[modePrompts release];
	
	unsigned nCap = [modeDefaults count];
	modeCommands = [[NSMutableDictionary dictionaryWithCapacity:nCap] retain];
	modePrompts = [[NSMutableDictionary dictionaryWithCapacity:nCap] retain];
	
	NSEnumerator *enumerator = [modeDefaults objectEnumerator];
	NSDictionary *dict;
	NSDictionary *mode;
	while (dict = [enumerator nextObject]) {
		mode = [dict objectForKey:@"mode"];
		[modeCommands setObject:[dict objectForKey:@"command"] forKey:mode];
		[modePrompts setObject:[dict objectForKey:@"prompt"] forKey:mode];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"ModeDefaults"]) {
		[self setModeDefaults:[change objectForKey:NSKeyValueChangeNewKey]];
	}
}

@end
