// icsinterface
// $Id$

#import "global.h"

@interface Seek : NSObject {
	@public
	NSString *nameFrom;
	int title;
	int ratingValue;
	char ratingStatus;
	int timeStart;
	int timeIncrement;
	bool rated;
	char wantsColor;
	NSString *typeOfPlay;
	bool automatic;
	bool formulaChecked;
	int ratingRangeLow;
	int ratingRangeHigh;
}

+ (Seek *) seekFromSeekInfo: (const char *) seekInfo;
- (void) dealloc;

@end

