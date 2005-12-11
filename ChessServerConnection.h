// icsinterface
// $Id$

#import "global.h"
#import "Game.h"
#import "Seek.h"
#import "ChessServer.h"
#import "GameWindowController.h"

@interface ChessServerConnection : NSObject {
	id errorHandler;
	GameWindowController *serverMainWindow;
	Game *game;
	NSInputStream *serverIS;
	NSOutputStream *serverOS;
	char lineBuf[4096];
	int lastChar;
	ChessServer *currentServer;
	bool sendNamePassword, sendInit;
	NSMutableDictionary *seeks;
}

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

@end
