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
	[wildStyle release];
	wildStyle = [style copy];
}

- (NSString *) wildStyle
{
	return [[wildStyle retain] autorelease];
}

- (BOOL) isWild
{
	return playStyle == STYLE_WILD;
}

- (NSString *) seekDescriptionLine
{
	printf("Hallo\n");
	NSString *style;
	if (playStyle == STYLE_WILD)
		style = [NSString stringWithFormat: @"Wild %@", wildStyle];
	else
		style = StyleNames[playStyle];
	return [NSString stringWithFormat: @"%@: %d+%d, %s, %s (%d-%d%s)", style,
	 timeStart, timeIncrement,
	 (rated) ? "rated" : "unrated", (automatic) ? "automatic" : "manual",
	 ratingRangeLow, ratingRangeHigh, (formulaChecked) ? ", formula" : ""];
}

@end
