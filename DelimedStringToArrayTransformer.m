#import "DelimedStringToArrayTransformer.h"
#import "StringExtra.h"

@implementation DelimedStringToArrayTransformer

+ (Class)transformedValueClass
{
	return [NSMutableArray class];
}


+ (BOOL)allowsReverseTransformation
{
	return YES;
}


- (id)transformedValue:(id)value
{
	if (value == nil) return nil;
	
	NSCharacterSet *delimiters = [NSCharacterSet characterSetWithCharactersInString:@";"];
	
	NSScanner *scanner = [NSScanner scannerWithString:value];
	NSString *scannedText;
	NSMutableArray * array = [NSMutableArray array];

	while(![scanner isAtEnd]) {
        if([scanner scanUpToCharactersFromSet:delimiters intoString:&scannedText]) {
			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:scannedText forKey:@"process"];
			[array addObject:dict];
        }
        [scanner scanCharactersFromSet:delimiters intoString:nil];
    }
	
	return array;
}


- (id)reverseTransformedValue:(id)array
{
	NSString *string = [[array valueForKey:@"process"] componentsJoinedByString:@";"];
	return string;
}

@end
