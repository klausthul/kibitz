// iscinterface
// $Id: AppController.h 69 2005-12-19 07:36:40Z kthul $

#import "global.h"

@interface OutputLine : NSObject {
	NSString *text;
	enum OutputLineType type;
	int info;
}

+ (OutputLine *) newOutputLine: (NSString *) tx type: (enum OutputLineType) ty info: (int) i;
- (NSString *) text;
- (int) info;
- (enum OutputLineType) type;

@end
