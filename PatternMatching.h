// icsinterface
// $Id$

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

- (PatternMatching *) initWithPatterns: (struct ServerPattern *) pattern;
- (NSInvocation *) parseLine: (const char *) line toTarget: (id) object;

@end

