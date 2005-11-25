#import <Cocoa/Cocoa.h>
#import <ChessField.h>

@interface ChessMove : NSObject {
  @public
	char from, to, promotion;
}

+ (ChessMove *) fromString: (const char *) s;
+ (ChessMove *) fromFieldsfrom: (ChessField) from to: (ChessField) to; 
- (void) printMove;
- (NSString *) asCoordinates;
@end

