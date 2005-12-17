// icsinterface
// $Id$

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
