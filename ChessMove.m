// icsinterface
// $Id$

#import "ChessMove.h"
#import "Board.h"

@implementation ChessMove

+ (ChessMove *) moveFromStyle12: (NSArray *) data
{
	ChessMove *cm = [[ChessMove alloc] init];
	if (cm != nil) {
		cm->movePrint = [[data objectAtIndex: 29] retain];
		cm->timeUsed = [[data objectAtIndex: 28] retain];
		cm->positionAfter = [[Board boardFromStyle12: data] retain];
	}
	return [cm autorelease];
}

- (void) print
{
	[positionAfter print];
	NSLog(movePrint);
	NSLog(timeUsed);
}

- (Board *) positionAfter
{
	return [[positionAfter retain] autorelease];
}

/*
+ (ChessMove *) fromString: (const char *) s {
	int p, i;
	ChessMove *m = [[ChessMove alloc] init];
	
	m->from = tolower(s[0]) - 'a' + (tolower(s[1]) - '1') * 8;
	m->to = tolower(s[2]) - 'a' + (tolower(s[3]) - '1') * 8;
	m->promotion = 0;
	if (isalnum(p = s[4])) {
	    p = toupper(p);
		for (i = 2; i <= QUEEN; i++)
			if ("  KBRQ"[i] == p) {
				m->promotion = i;
				break;
			}
	}
	return [m autorelease];
}

+ (ChessMove *) fromFieldsfrom: (struct ChessField) from to: (struct ChessField) to 
{
	ChessMove *m = [[ChessMove alloc] init];
	
	m->from = from.line + from.row * 8 - 9;
	m->to = to.line + to.row * 8 - 9;
	m->promotion = 0;
	return [m autorelease];
}

- (NSString *) asCoordinates
{
	char buffer[256];
	sprintf(buffer, "%c%c-%c%c%c\n", from % 8 + 'a', from / 8 + '1', to % 8 + 'a', to / 8 + '1', "  KBRQ"[promotion]);
	return [NSString stringWithUTF8String: buffer];
}

- (void) printMove 
{
	printf("%c%c-%c%c%c\n", from % 8 + 'a', from / 8 + '1', to % 8 + 'a', to / 8 + '1', "  KBRQ"[promotion]);
}
*/

@end
