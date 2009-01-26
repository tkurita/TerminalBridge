#import "DefaultToNilTransformer.h"


@implementation DefaultToNilTransformer

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
	return aString;
}

- (id)reverseTransformedValue:(id)value
{
	if ([nilWords containsObject:value]) {
		return nil;
	}

	return value;	
}

@end
