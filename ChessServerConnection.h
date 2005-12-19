// icsinterface
// $Id$

#import "global.h"
#import "Game.h"
#import "Seek.h"
#import "ChessServer.h"
#import "GameWindowController.h"
#import "PatternMatching.h"

@interface ChessServerConnection : NSObject {
	id <ChessServerErrorHandler> errorHandler;
	GameWindowController *serverMainWindow;
	NSInputStream *serverIS;
	NSOutputStream *serverOS;
	char lineBuf[4096];
	int lastChar;
	ChessServer *currentServer;
	bool sendNamePassword, sendInit;
	NSMutableDictionary *seeks;
	NSMutableDictionary *activeGames;
	int storedGameCounter;
	PatternMatching *patternMatcher;
}

- (void) serverGameEnd: (NSNumber *) game result: (NSString *) result reason: (NSString *) reason;
- (void) serverIllegalMove: (NSString *) why;
- (void) processServerOutput;
- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)event;
- (id) initWithChessServer: (ChessServer *) server;
- (id) init;
- (void) dealloc;
- (void) setErrorHandler: (id) eh;
- (void) write: (unsigned char *) data maxLength: (int) i;
- (void) newSeekFromServer: (int) num description: (const char *) seekInfo;
- (void) removeSeekFromServer: (int) num;
- (int) numSeeks;
- (id) dataForSeekTable: (NSString *) x row:(int)rowIndex;
- (void) userMoveFrom: (struct ChessField) from to: (struct ChessField) to;
- (void) userMoveFrom: (struct ChessField) from to: (struct ChessField) to promotion: (int) promotionPiece;
- (void) removeAllSeeks;
- (NSString *) description;
- (void) sendSeek: (Seek *) s;
- (void) sendToServer: (NSString *) s;

@end
