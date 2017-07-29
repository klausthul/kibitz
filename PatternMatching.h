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

#import "global.h"
#import <regex.h>
#define MAX_PATTERNS 100

struct ServerPattern {
	const char *pattern;
	SEL call;
	const char *arguments;
};

@interface PatternMatching : NSObject {
	int numPatterns;
	regex_t compiledPatterns[MAX_PATTERNS];
	SEL selectors[MAX_PATTERNS];
	const char *arguments[MAX_PATTERNS];
}

- (PatternMatching *) initWithPatterns: (const struct ServerPattern *) pattern NS_DESIGNATED_INITIALIZER;
- (NSInvocation *) parseLine: (const char *) line toTarget: (id) object;

@end

