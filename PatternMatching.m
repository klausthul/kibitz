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

#import "PatternMatching.h"
#define NUM_PATTERNS 20

@implementation PatternMatching

- (PatternMatching *) initWithPatterns: (const struct ServerPattern *) pattern
{
	if ((self = [super init]) != nil) {
		const struct ServerPattern *sp;
		regex_t *cp;
		int i;
	
		for (i = 0, sp = pattern, cp = compiledPatterns; sp->pattern != 0; i++, sp++, cp++) {
			if (regcomp(cp, sp->pattern, REG_EXTENDED) != 0) {
				NSLog(@"Error compiling patterns\n");
				exit(-1);
			}
			selectors[i] = sp->call;
			arguments[i] = sp->arguments;
		}
		numPatterns = i;
	}
	return self;
}

- (NSInvocation *) parseLine: (const char *) line toTarget: (id) object
{
	int i, arg;
	regex_t *cp;
	regmatch_t matches[20];
		
	for (i = 0, cp = compiledPatterns; i < numPatterns; i++, cp++) {
		if (regexec(cp, line, 20, matches, 0) == 0) {
			const char *ar;
			NSMethodSignature *sign = [object methodSignatureForSelector: selectors[i]];
			NSInvocation *invoc = [NSInvocation invocationWithMethodSignature: sign];
			[invoc setTarget: object];
			[invoc setSelector: selectors[i]];
			if ((ar = arguments[i])) {
				NSString *s1 = [NSString stringWithUTF8String: line];
				for (arg = 2; *ar; ar++, arg++) {
					int x = *ar - '0';
					if (x < 0 || x >= 20 || matches[x].rm_so < 0)
						return nil;
					else {
						id s2 = [s1 substringWithRange: (NSRange) { matches[x].rm_so, matches[x].rm_eo -  matches[x].rm_so }];
						switch (*(ar + 1)) {
						  case 'I':
							s2 = [NSNumber numberWithInt: [s2 intValue]];
						    ar++;
							break;
						  default:
						    break;
						}
						[invoc setArgument: &s2 atIndex: arg];
					}
				}
			}
			return invoc;
		}
	}
	return nil;
}

@end
