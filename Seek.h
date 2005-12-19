// icsinterface
// $Id$

#import "global.h"

@interface Seek : NSObject {
	NSString *nameFrom;
	int title;
	int ratingValue;
	char ratingStatus;
	int timeStart;
	int timeIncrement;
	bool rated;
	enum WantsColor wantsColor;
	NSString *typeOfPlay;
	bool automatic;
	bool formulaChecked;
	int ratingRangeLow;
	int ratingRangeHigh;
	enum PlayStyle playStyle;
	NSString *wildStyle;
}

+ (Seek *) seekFromSeekInfo: (const char *) seekInfo;
- (void) dealloc;
- (int) ratingValue;
- (NSString *) nameFrom;
- (NSString *) typeOfPlay;
- (void) setWildStyle: (NSString *) style;
- (NSString *) wildStyle;
- (NSString *) seekDescriptionLine;
- (void) setTimeStart: (int) t;
- (void) setTimeIncrement: (int) t;
- (void) setRated: (bool) r;
- (void) setWantsColor: (enum WantsColor) c;
- (void) setAutomatic: (bool) a;
- (void) setFormulaChecked: (bool) c;
- (void) setRatingRangeLow: (int) r;
- (void) setRatingRangeHigh: (int) r;
- (void) setPlayStyle: (enum PlayStyle) s;
- (NSString *) seekCommand;

@end

