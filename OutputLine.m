// iscinterface
// $Id: AppController.h 69 2005-12-19 07:36:40Z kthul $

#import "OutputLine.h"

@implementation OutputLine

+ (OutputLine *) newOutputLine: (NSString *) tx type: (enum OutputLineType) ty info: (int) i
{
	OutputLine *ol = [[[OutputLine alloc] init] autorelease];
	ol->text = [tx copy];
	ol->type = ty;
	ol->info = i;
	return ol;
}

- (NSString *) text
{
	return text;
}

- (int) info
{
	return info;
}

- (enum OutputLineType) type
{
	return type;
}

@end
