#import "SmartActivate.h"

CFDictionaryRef getProcessInfoForCreator(CFStringRef targetCreator) {
	/* find an applicarion process specified by theSignature(creator type) from runnning process.
		if target application can be found, get information of the process and return as a result
	*/
	//printf("start getProcessInfoForCreator\n");
	OSErr err;
	ProcessSerialNumber psn = {kNoProcess, kNoProcess};
	CFDictionaryRef pDict;
	CFStringRef fileCreator;
	CFComparisonResult isSameSignature;
	Boolean isFound = false;
	
	err = GetNextProcess(&psn);
	while( err == noErr) {
		pDict = ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask);
		fileCreator = CFDictionaryGetValue (pDict,CFSTR("FileCreator"));
		if (fileCreator != NULL) {
			isSameSignature = CFStringCompare (fileCreator,targetCreator,0);
			//printf("compare success\n");
			if (isSameSignature == kCFCompareEqualTo) {
				//printf("target is found\n");
				isFound = true;
				break;
			}
		}
		//show(CFSTR("Dictionary: %@"), pDict);
		CFRelease(pDict);
		err = GetNextProcess (&psn);
	}
	
	if (isFound) {
		return pDict;
	}
	else{
		//printf("NULL will be retruned\n");
		return NULL;
	}
}

@implementation NSApplication (SmartActivate)

-(BOOL)smartActivate:(NSString *)targetCreator {
	//printf("start smartActivate\n");
	
	CFDictionaryRef pDict = getProcessInfoForCreator((CFStringRef)targetCreator);
	if (pDict != NULL) {
		//printf("will activate\n");
		ProcessSerialNumber psn;
		CFNumberGetValue(CFDictionaryGetValue(pDict,CFSTR("PSN")),
				kCFNumberLongLongType,&psn);
		SetFrontProcessWithOptions(&psn,kSetFrontProcessFrontWindowOnly);
		CFRelease(pDict);
		return YES;
	}
	else {
		return NO;
	}
}

@end
