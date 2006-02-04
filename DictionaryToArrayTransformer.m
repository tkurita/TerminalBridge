#import "DictionaryToArrayTransformer.h"
#import "StringExtra.h"

#define useLog 0

@implementation DictionaryToArrayTransformer

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
#if useLog
	NSLog([value description]);
#endif
	NSArray *keyArray = [value allKeys];
	
	NSEnumerator *enumerator = [keyArray objectEnumerator];
	
	NSString *theKey;
	NSMutableArray *array = [NSMutableArray array];
	while (theKey = [enumerator nextObject]) {
			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:theKey forKey:@"mode"];
			[dict setObject:[value objectForKey:theKey] forKey:@"command"];	
			[array addObject:dict];
	}
#if useLog
	NSLog([array description]);
#endif
	return array;
}


- (id)reverseTransformedValue:(id)array
{
	NSEnumerator *enumerator = [array objectEnumerator];
	NSDictionary *dict;
	NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
	while (dict = [enumerator nextObject]) {
		[resultDict setObject:[dict objectForKey:@"command"] forKey:[dict objectForKey:@"mode"]];
	}

	return resultDict;
}

@end
