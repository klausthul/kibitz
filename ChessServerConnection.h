// icsinterface
// $id$

#import "global.h"
#import "Game.h"
#import "SeekGraph.h"
#import "ChessServer.h"

@interface ChessServerConnection : NSObject {
	id errorHandler;
	id serverMainWindow;
	Game *game;
	SeekGraph *seekGraph;
	NSInputStream *serverIS;
	NSOutputStream *serverOS;
	char lineBuf[4096];
	int lastChar;
	ChessServer *currentServer;
	bool sendNamePassword, sendInit;
}

- (void) processServerOutput;
- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)event;
- (id) initWithChessServer: (ChessServer *) server;
- (id) init;
- (void) dealloc;
- (void) setErrorHandler: (id) eh;

@end

@interface NSObject(ChessServerConnectionErrorHandler)

- (void) handleStreamError: (NSError *) theError;

@end
