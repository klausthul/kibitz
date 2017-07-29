/*
	$Id$

	Copyright 2006 Klaus Thul (klaus.thul@mac.com)
	This file is part of Kibitz.

	Kibitz is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by 
	the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	Kibitz is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with Kibitz; if not, write to the 
	Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#import "Seek.h"

NSString *StyleNames[] = {
	@"Normal", @"Crazyhouse", @"Suicide", @"Wild"
};

@implementation Seek

/**
 * Create seek object from FICS-style seek adversitement string
 * Note, this is the "seekinfo" version documented at
 * http://www.freechess.org/Help/HelpFiles/iv_seekinfo.html
 *
 * @param seekInfo Seek advertisement string
 */
+ (Seek *) seekFromSeekInfo: (const char *) seekInfo
{
	Seek *s = [[Seek alloc] init];
	[s autorelease];
    
    NSString *seekInfoNS = @(seekInfo);
    NSArray *parts = [seekInfoNS componentsSeparatedByString:@" "];
    for (NSString *part in parts) {
        NSArray *keyVal = [part componentsSeparatedByString:@"="];
        if (keyVal.count != 2) {
            continue;
        }
        NSString *key = keyVal[0];
        NSString *value = keyVal[1];
        
        if ([key isEqualToString:@"w"]) {
            s->nameFrom = value;
            [s->nameFrom retain];
        } else if ([key isEqualToString:@"t"]) {
            s->timeStart = value.intValue;
        } else if ([key isEqualToString:@"i"]) {
            s->timeIncrement = value.intValue;
        } else if ([key isEqualToString:@"t"]) {
            if ([value isEqualToString:@"r"])
                s->rated = YES;
            else if ([value isEqualToString:@"u"])
                s->rated = NO;
        } else if ([key isEqualToString:@"c"]) {
            if ([value isEqualToString:@"?"])
                s->wantsColor = WANTS_BOTH;
            else if ([value isEqualToString:@"W"])
                s->wantsColor = WANTS_WHITE;
            else if ([value isEqualToString:@"B"])
                s->wantsColor = WANTS_BLACK;
        } else if ([key isEqualToString:@"a"]) {
            if ([value isEqualToString:@"t"])
                s->automatic = YES;
            else if ([value isEqualToString:@"f"])
                s->automatic = NO;
        } else if ([key isEqualToString:@"f"]) {
            if ([value isEqualToString:@"t"])
                s->formulaChecked = YES;
            else if ([value isEqualToString:@"f"])
                s->formulaChecked = NO;
        } else if ([key isEqualToString:@"ti"]) {
            s->title = strtol(value.UTF8String, NULL, 16);
        } else if ([key isEqualToString:@"rt"]) {
            s->ratingValue = value.intValue;
        } else if ([key isEqualToString:@"tp"]) {
            s->typeOfPlay = value;
            [s->typeOfPlay retain];
        } else if ([key isEqualToString:@"rr"]) {
            // TODO: implement Ratings range
        }
	}
	return s;
}

- (Seek *) init
{
	if ((self = [super init]) != nil) {
		timeStart = 5;
		timeIncrement = 0;
		rated = YES;
		wantsColor = WANTS_BOTH;
		playStyle = STYLE_NORMAL;
		automatic = YES;
		ratingRangeLow = 0;
		ratingRangeHigh = 9999;
		formulaChecked = NO;
	}
	return self;
}

+ (Seek *) defaultSeek
{
	return [[[Seek alloc] init] autorelease];
}


- (void) dealloc
{
	[nameFrom release];
	[typeOfPlay release];
	[wildStyle release];
	[super dealloc];
}

- (int) ratingValue
{
	return ratingValue;
}

- (NSString *) nameFrom
{
	return [[nameFrom retain] autorelease];
}

- (NSString *) typeOfPlay
{
	return [[typeOfPlay retain] autorelease];
}

- (void) setWildStyle: (NSString *) style
{
	[self willChangeValueForKey: @"description"];
	[wildStyle release];
	wildStyle = [style copy];
	[self didChangeValueForKey: @"description"];
}

- (NSString *) wildStyle
{
	return (wildStyle == nil) ? @"" : wildStyle;
}

- (BOOL) isWild
{
	return playStyle == STYLE_WILD;
}

- (NSString *) description
{
	NSString *style;
	if (playStyle == STYLE_WILD)
		style = [NSString stringWithFormat: @"Wild %@", [self wildStyle]];
	else
		style = StyleNames[playStyle];
	return [NSString stringWithFormat: @"%@: %d+%d, %s, %s%s (%d-%d%s)", style,
	 timeStart, timeIncrement,
	 (rated) ? "r" : "u", (automatic) ? "a" : "m",
	 (wantsColor == WANTS_BOTH) ? "" : ((wantsColor == WANTS_WHITE) ? ", w" : ", b"),
	 ratingRangeLow, ratingRangeHigh, (formulaChecked) ? ", f" : ""];
}

- (void) setTimeStart: (int) t
{
	[self willChangeValueForKey: @"description"];
	timeStart = t;
	[self didChangeValueForKey: @"description"];
}

- (void) setTimeIncrement: (int) t
{
	[self willChangeValueForKey: @"description"];
	timeIncrement = t;
	[self didChangeValueForKey: @"description"];
}

- (void) setRated: (bool) r
{
	[self willChangeValueForKey: @"description"];
	rated = r;
	[self didChangeValueForKey: @"description"];
}

- (void) setWantsColor: (enum WantsColor) c
{
	[self willChangeValueForKey: @"description"];
	wantsColor = c;
	[self didChangeValueForKey: @"description"];
}

- (void) setAutomatic: (bool) a
{
	[self willChangeValueForKey: @"description"];
	automatic = a;
	[self didChangeValueForKey: @"description"];
}

- (void) setFormulaChecked: (bool) c
{
	[self willChangeValueForKey: @"description"];
	formulaChecked = c;
	[self didChangeValueForKey: @"description"];
}

- (void) setRatingRangeLow: (int) r
{
	[self willChangeValueForKey: @"description"];
	ratingRangeLow = r;
	[self didChangeValueForKey: @"description"];
}

- (void) setRatingRangeHigh: (int) r
{
	[self willChangeValueForKey: @"description"];
	ratingRangeHigh = r;
	[self didChangeValueForKey: @"description"];
}

- (void) setPlayStyle: (enum PlayStyle) s
{
	[self willChangeValueForKey: @"isWild"];
	[self willChangeValueForKey: @"description"];
	playStyle = s;
	[self didChangeValueForKey: @"isWild"];
	[self didChangeValueForKey: @"description"];
}

- (NSString *) seekCommand
{
	NSString *style;
	switch (playStyle) {
	  case STYLE_WILD:
		style = [NSString stringWithFormat: @"Wild %@ ", [self wildStyle]];
		break;
	  case STYLE_CRAZYHOUSE:
	    style = @"crazyhouse ";
		break;
	  case STYLE_SUICIDE:
	    style = @"suicide ";
		break;
	  default:
		style = @"";
	}
	return [NSString stringWithFormat: @"seek %d %d %s %s %@ %s %s %d-%d", 
	 timeStart, timeIncrement, rated ? "rated" : "unrated", 
	 (wantsColor == WANTS_BOTH) ? "" : ((wantsColor == WANTS_WHITE) ? "white" : "black"), 
	 style, automatic ? "auto" : "manual", formulaChecked ? "formula" : "", 
	 ratingRangeLow, ratingRangeHigh];
}

- (instancetype) initWithCoder: (NSCoder *) coder
{
	if ((self = [super init]) != nil) {
		[self setTimeStart: [coder decodeIntForKey: @"timeStart"]];
		[self setTimeIncrement: [coder decodeIntForKey: @"timeIncrement"]];
		[self setRated: [coder decodeBoolForKey: @"rated"]];
		[self setWantsColor: [coder decodeIntForKey: @"wantsColor"]];
		[self setAutomatic: [coder decodeBoolForKey: @"automatic"]];
		[self setFormulaChecked: [coder decodeBoolForKey: @"formulaChecked"]];
		[self setRatingRangeLow: [coder decodeIntForKey: @"ratingRangeLow"]];
		[self setRatingRangeHigh: [coder decodeIntForKey: @"ratingRangeHigh"]];
		[self setPlayStyle: [coder decodeIntForKey: @"playStyle"]];
		[self setWildStyle: [coder decodeObjectForKey: @"wildStyle"]];	
	}
	return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
	[coder encodeInt: timeStart forKey: @"timeStart"];
	[coder encodeInt: timeIncrement forKey: @"timeIncrement"];
	[coder encodeBool: rated forKey: @"rated"];
	[coder encodeInt: wantsColor forKey: @"wantsColor"];
	[coder encodeBool: automatic forKey: @"automatic"];
	[coder encodeBool: formulaChecked forKey: @"formulaChecked"];
	[coder encodeInt: ratingRangeLow forKey: @"ratingRangeLow"];
	[coder encodeInt: ratingRangeHigh forKey: @"ratingRangeHigh"];
	[coder encodeInt: playStyle forKey: @"playStyle"];
	[coder encodeObject: wildStyle forKey: @"wildStyle"];
}

@end
