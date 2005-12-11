// icsinterface
// $Id$

#import <ctype.h>
#import "Game.h"
#import "Board.h"

int pieceFromChar(char c)
{
	const char *pieces = "-PNBRQK  pnbrqk";
	int p;
	
	for (p = 0; pieces[p]; p++) {
		if (pieces[p] == c)
			return p;
	} 
	return 0; 
}

@implementation Game

- (Game *) init
{
	if (self = [super init]) {
		board = [[Board alloc] init];
		[board startPosition];
		move_list = [[NSMutableArray alloc] initWithCapacity: 500];
		num_half_moves = 0;
		cur_move = 0;
	}
	return self;
}

- (void) dealloc
{
	[board release];
	[move_list release];
	[super dealloc];
}

- (void) doMove: (ChessMove *) move 
{
	ChessMoveStore *cms;

	[self goEnd];
	cms = [board doMove: move];
	cur_move++;
	[move_list insertObject: cms atIndex: num_half_moves++];
	[tableView reloadData];
	[chessView setNeedsDisplay:YES];
}

- (void) undoMove
{
	[self goEnd];
	if (num_half_moves > 0) {
		[self goBackward];
		--cur_move;
		[move_list removeObjectAtIndex: --num_half_moves];
	}
	[tableView reloadData];
	[chessView setNeedsDisplay:YES];
}

- (int) goForeward
{
	if (cur_move < num_half_moves) {
		[board doMove: [move_list objectAtIndex: cur_move++]];
		[chessView setNeedsDisplay:YES];
		if (cur_move == num_half_moves - 1) {
//			[tableView deselectAll: self];
			return 0;
		} else
			return 1;
	} else {
		return -1;
	}
}

- (void) goBackward
{
	if (cur_move > 0)
		[board undoMove: [move_list objectAtIndex: --cur_move]];
	[chessView setNeedsDisplay:YES];
}

- (void) goEnd
{
	while ([self goForeward] == 1)
		;
}

- (void) goStart
{
	while (cur_move > 0)
		[self goBackward];
	[tableView selectRow: cur_move / 2 byExtendingSelection: FALSE];
}

- (void) goMove: (int) n
{
	if (n >= num_half_moves)
		n = num_half_moves - 1; 
	if (n < 0)
		n = 0;
	while (cur_move < n)
		[self goForeward];
	while (cur_move > n)
		[self goBackward];
}

- (IBAction) goForeward: (id) sender
{
	[self goForeward];
	[tableView selectRow: cur_move / 2 byExtendingSelection: FALSE];
}

- (IBAction) goBackward: (id) sender
{
	[self goBackward];
	[tableView selectRow: cur_move / 2 byExtendingSelection: FALSE];
}

- (IBAction) goStart: (id) sender
{
	[self goStart];
	[tableView selectRow: cur_move / 2 byExtendingSelection: FALSE];
}

- (IBAction) goEnd: (id) sender
{
	[self goEnd];
	[tableView selectRow: cur_move / 2 byExtendingSelection: FALSE];
}

- (void) printBoard
{
	[board printBoard];
}

- (void) printMoveList
{
	int i;
	
	for (i = 0; i < num_half_moves; i++) {
		printf("%d%c. ", i/2 + 1, (i % 2 == 0) ? 'w' : 'b');
		[[move_list objectAtIndex: i] printMove];
	}
}

- (void) printGame
{
	[self printMoveList];
	[self printBoard];
	printf("At %d of %d.\n", cur_move, num_half_moves);
}
/*
- (void) awakeFromNib
{
	FILE *f = fopen("/users/kthul/Desktop/test.game", "r");
	char s[256];
	
	while(fgets(s, 255, f) != NULL)
		[self doMove: [ChessMove fromString: s]];
	[tableView reloadData];
}
*/
- (int) numberOfRowsInTableView: (NSTableView *) aTableView
{
	return (num_half_moves + 1)/2;
}

- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSString *x = [aTableColumn identifier];
	int i = -1;
	if ([x compare: @"2"] == 0)
		i = rowIndex * 2;
	else if ([x compare: @"3"] == 0)
		i = rowIndex * 2 + 1;
	if ((i >= 0) && (i < num_half_moves))
		return [[move_list objectAtIndex: i] asCoordinates];
	if ([x compare: @"1"] == 0)
		return [NSNumber numberWithInt: rowIndex + 1];
	return @"...";
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self goMove: [tableView selectedRow] * 2];
}

- (int) pieceLine: (int) l row: (int) r
{
	return [board pieceLine: l row: r];
}

- (void) setBoardFromString: (char *) s flip: (int) flip
{
	[board setBoardFromString: s flip: (int) flip];
	[chessView setNeedsDisplay:YES];
}

- (void) setClocksWhite: (int) white black: (int) black running: (enum RunningClock) running
{
	timeWhite = white;
	timeBlack = black;
	lastTimeUpdate = time(NULL);
	[self updateClocks];
	runningClock = running;
}

- (void) updateClocks
{
	int tw = timeWhite, tb = timeBlack;
	
	if (runningClock == WHITE_CLOCK_RUNS) {
		tw -= (int) difftime(time(NULL), lastTimeUpdate);
		if (tw < 0)
			tw = 0;
	} else if (runningClock == BLACK_CLOCK_RUNS) {
		tb -= (int) difftime(time(NULL), lastTimeUpdate);
		if (tb < 0)
			tb = 0;
	}
	[upperClock setStringValue:[Game stringWithClock: tb]];
	[upperClock setNeedsDisplay:YES];
	[lowerClock setStringValue:[Game stringWithClock: tw]];
	[lowerClock setNeedsDisplay:YES];
}

+ (NSString *) stringWithClock: (int) seconds
{
	int minutes, hours;
	char string[10];
	minutes = seconds / 60;
	seconds -= minutes * 60;
	hours = minutes / 60;
	minutes -= hours * 60;
	string[0] = hours % 10 + '0';
	string[1] = ':';
	string[2] = minutes / 10 + '0';
	string[3] = minutes % 10 + '0';
	string[4] = ':';
	string[5] = seconds / 10 + '0';
	string[6] = seconds % 10 + '0';
	string[7] = '.';
	string[8] = '0';
	string[9] = 0;
	return [NSString stringWithCString: string];
}

- (ValidationResult) moveValidationFrom: (struct ChessField) from to: (struct ChessField) to
{
	if (((to.row == 1) || (to.row == 8)) && GETPIECE([board pieceOnField:from]) == PAWN)
		return REQUIRES_PROMOTION;
	return VALID;
}

@end
