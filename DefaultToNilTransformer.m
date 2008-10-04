#import "DefaultToNilTransformer.h"


@implementation DefaultToNilTransformer

static NSPopUpButton *popupMenu = nil;

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (void)setPopupMenu:(NSPopUpButton *)aPopupMenu
{
	popupMenu = aPopupMenu;
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
	if ([popupMenu indexOfSelectedItem] == 0) {
		return nil;
	}

	return value;	
}

@end
