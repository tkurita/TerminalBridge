#import "DefaultToNilTransformer.h"


@implementation DefaultToNilTransformer
@synthesize nilWord;

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

- (void)dealloc
{
	[nilWord release];
	[super dealloc];
}

- (id)transformedValue:(id)aString
{
	if (!aString) {
		return NSLocalizedString(nilWord, @"");
	} 
	
	return aString;
}

- (id)reverseTransformedValue:(id)value
{
	if ([value isEqualToString:NSLocalizedString(nilWord, @"")]) {
		return nil;
	}
	return value;	
}

@end
