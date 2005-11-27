// icsinterface
// $id$

#import <Cocoa/Cocoa.h>
#import "Game.h"
#import "SeekGraph.h"
#import "ChessServer.h"
@class Game, ChessServer;

@interface ChessServerConnection : NSObject {
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
+ initWithChessServer: (ChessServer *) server;
- (id) init;
- (void) dealloc;

@end
