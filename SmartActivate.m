#import "SmartActivate.h"

NSDictionary *getProcessInfoForCreator(NSString *targetCreator) {
	/* find an applicarion process specified by theSignature(creator type) from runnning process.
		if target application can be found, get information of the process and return as a result
	*/
	OSErr err;
	ProcessSerialNumber psn = {kNoProcess, kNoProcess};
	NSDictionary *pDict;
	NSString *fileCreator;
	BOOL isFound = NO;
	
	err = GetNextProcess(&psn);
	while( err == noErr) {
		pDict = (NSDictionary *)ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask);
		fileCreator = [pDict objectForKey:@"FileCreator"];
		if (fileCreator != nil) {
			if ([fileCreator isEqualToString:targetCreator]){
				isFound = YES;
				break;
			}
		}
		[pDict release];
		err = GetNextProcess (&psn);
	}
	
	if (isFound) {
		return pDict;
	}
	else{
		//printf("NULL will be retruned\n");
		return nil;
	}
}

@implementation NSApplication (SmartActivate)

-(BOOL)smartActivate:(NSString *)targetCreator {
	//printf("start smartActivate\n");
	
	NSDictionary *pDict = getProcessInfoForCreator(targetCreator);
	if (pDict != nil) {
		//NSLog(@"will activate");
		//NSLog([pDict description]);
		ProcessSerialNumber psn;
		[[pDict objectForKey:@"PSN"] getValue:&psn];
		SetFrontProcessWithOptions(&psn,kSetFrontProcessFrontWindowOnly);
		[pDict release];
		return YES;
	}
	else {
		return NO;
	}
}

@end
