#import <Cocoa/Cocoa.h>


@interface DefaultToNilTransformer : NSValueTransformer {
	NSString *nilWord;
}
@property (strong, readwrite) NSString *nilWord;

@end
