// icsinterface
// $Id$

#import "global.h"
#import "Board.h"
#import "ChessView.h"

@interface Game : NSObject {
	Board *board;
	NSMutableArray *move_list;
	int cur_move, num_half_moves;
	int timeWhite, timeBlack;
	time_t lastTimeUpdate;
	enum RunningClock runningClock;
}

+ (NSString *) stringWithClock: (int) seconds;
- (int) pieceLine: (int) l row: (int) r;
- (Game *) init;
- (void) doMove: (ChessMove *) move;
- (void) undoMove;
- (int) goForeward;
- (IBAction) goForeward:(id) sender;
- (void) goBackward;
- (IBAction) goBackward:(id) sender;
- (void) goEnd;
- (IBAction) goEnd:(id) sender;
- (void) goStart;
- (IBAction) goStart:(id) sender;
- (void) printBoard;
- (void) printMoveList;
- (void) printGame;
- (int) numberOfRowsInTableView: (NSTableView *) aTableView;
- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (void) setBoardFromString: (char *) s flip: (int) flip;
- (void) setClocksWhite: (int) white black: (int) black running: (enum RunningClock) running;
- (enum ValidationResult) moveValidationFrom: (struct ChessField) from to: (struct ChessField) to;
- (void) updateClocks;

@end
