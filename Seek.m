// icsinterface
// $Id$

#import "Seek.h"

NSString *StyleNames[] = {
	@"Normal", @"Crazyhouse", @"Suicide", @"Wild"
};

@implementation Seek

+ (Seek *) seekFromSeekInfo: (const char *) seekInfo
{
	const char *cp, *key, *value;
	int key_length, value_length;
	Seek *s = [[Seek alloc] init];
	[s autorelease];
	
	for (cp = seekInfo; *cp;) {
		if (!isalpha(*cp)) {
			cp++;
			continue;
		}
		key = cp;
		while (*(++cp) != '=') {
			if (!(*cp))
				goto error;
		}
		key_length = cp - key;
		value = ++cp;
		if (!(*cp)) {
			NSLog(@"Input ends after =\n");
			goto error;
		}
		while (*cp && !isspace(*cp))
			cp++;
		value_length = cp - value;
		
		if (key_length == 1) {
			switch (*key) {
			  case 'w':
				s->nameFrom = [NSString stringWithCString:value length:value_length];
				[s->nameFrom retain];
				break;
			  case 't':
				s->timeStart = atoi(value);
				break;
			  case 'i':
				s->timeIncrement = atoi(value);
				break;				
			  case 'r':
				switch (*value) {
				  case 'r':
				    s->rated = YES;
					break;
				  case 'u':
				    s->rated = NO;
					break;
				}
				break;
			  case 'c':
				switch (tolower(*value)) {
				  case '?':
				    s->wantsColor = WANTS_BOTH;
					break;
				  case 'b':
				    s->wantsColor = WANTS_BLACK;
					break;
				  case 'w':
				    s->wantsColor = WANTS_WHITE;
					break;
				}
				break;
			  case 'a':
				switch (*value) {
				  case 't':
				    s->automatic = YES;
					break;
				  case 'f':
				    s->automatic = NO;
					break;
				}
				break;
			  case 'f':
				switch (*value) {
				  case 't':
				    s->formulaChecked = YES;
					break;
				  case 'f':
				    s->formulaChecked = NO;
					break;
				}
				break;
			  default:
				goto unknown_key;
			}
		} else if (key_length == 2) {
			if (strncmp(key, "ti", 2) == 0) {
				s->title = (*value - '0')*16 + (*(value + 1) - '0');
			} else if (strncmp(key, "rt", 2) == 0) {
				s->ratingValue = atoi(value);
			} else if (strncmp(key, "tp", 2) == 0) {
				s->typeOfPlay = [NSString stringWithCString:value length:value_length];
				[s->typeOfPlay retain];
			} else if (strncmp(key, "rr", 2) == 0) {
// !!!! for later !!!
			} else
				goto unknown_key;

		}
		continue;
	  unknown_key:;
		NSLog(@"Unknown key in seek string\n");
		continue;
	}
	return s;
  error:;
	return nil;
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
	Seek *s = [[[Seek alloc] init] autorelease];
	if (s != nil) {
		s->timeStart = 5;
		s->timeIncrement = 0;
		s->rated = YES;
		s->wantsColor = WANTS_BOTH;
		s->playStyle = STYLE_NORMAL;
		s->automatic = YES;
		s->ratingRangeLow = 0;
		s->ratingRangeHigh = 9999;
		s->formulaChecked = NO;
	}
	return s;
}


- (void) dealloc
{
	[nameFrom release];
	[typeOfPlay release];
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
	[self willChangeValueForKey: @"seekDescriptionLine"];
	[wildStyle release];
	wildStyle = [style copy];
	[self didChangeValueForKey: @"seekDescriptionLine"];
}

- (NSString *) wildStyle
{
	return (wildStyle == nil) ? @"" : wildStyle;
}

- (BOOL) isWild
{
	return playStyle == STYLE_WILD;
}

- (NSString *) seekDescriptionLine
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
	[self willChangeValueForKey: @"seekDescriptionLine"];
	timeStart = t;
	[self didChangeValueForKey: @"seekDescriptionLine"];
}

- (void) setTimeIncrement: (int) t
{
	[self willChangeValueForKey: @"seekDescriptionLine"];
	timeIncrement = t;
	[self didChangeValueForKey: @"seekDescriptionLine"];
}

- (void) setRated: (bool) r
{
	[self willChangeValueForKey: @"seekDescriptionLine"];
	rated = r;
	[self didChangeValueForKey: @"seekDescriptionLine"];
}

- (void) setWantsColor: (enum WantsColor) c
{
	[self willChangeValueForKey: @"seekDescriptionLine"];
	wantsColor = c;
	[self didChangeValueForKey: @"seekDescriptionLine"];
}

- (void) setAutomatic: (bool) a
{
	[self willChangeValueForKey: @"seekDescriptionLine"];
	automatic = a;
	[self didChangeValueForKey: @"seekDescriptionLine"];
}

- (void) setFormulaChecked: (bool) c
{
	[self willChangeValueForKey: @"seekDescriptionLine"];
	formulaChecked = c;
	[self didChangeValueForKey: @"seekDescriptionLine"];
}

- (void) setRatingRangeLow: (int) r
{
	[self willChangeValueForKey: @"seekDescriptionLine"];
	ratingRangeLow = r;
	[self didChangeValueForKey: @"seekDescriptionLine"];
}

- (void) setRatingRangeHigh: (int) r
{
	[self willChangeValueForKey: @"seekDescriptionLine"];
	ratingRangeHigh = r;
	[self didChangeValueForKey: @"seekDescriptionLine"];
}

- (void) setPlayStyle: (enum PlayStyle) s
{
	[self willChangeValueForKey: @"isWild"];
	[self willChangeValueForKey: @"seekDescriptionLine"];
	playStyle = s;
	[self didChangeValueForKey: @"isWild"];
	[self didChangeValueForKey: @"seekDescriptionLine"];
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

@end
