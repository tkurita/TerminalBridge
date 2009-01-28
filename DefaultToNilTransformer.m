#import "DefaultToNilTransformer.h"


@implementation DefaultToNilTransformer
@synthesize nilWord;

static NSArray *nilWords = nil;

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (void)setNilWords:(NSArray *)array
{
	nilWords = [array retain];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
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
	/*
	 if ([nilWords containsObject:value]) {
		return nil;
	}
	*/
	if ([value isEqualToString:NSLocalizedString(nilWord, @"")]) {
		return nil;
	}
	return value;	
}

@end
