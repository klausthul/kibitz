/*
	$Id$

	Copyright 2006 Klaus Thul (klaus.thul@mac.com)
	This file is part of kibitz.

	kibitz is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by 
	the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	kibitz is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with kibitz; if not, write to the 
	Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#import "global.h"

@interface Seek : NSObject <NSCoding> {
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
- (id) initWithCoder: (NSCoder *) coder;
- (void) encodeWithCoder: (NSCoder *) coder;

@end

