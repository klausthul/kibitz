//
//  ChessServer.h
//  Kibitz
//
//  Copyright 2014 William Entriken, licensed under the MIT license:
//  http://opensource.org/licenses/MIT
//
//  Based on Kibitz / ChessServer 2006 Klaus Thul
//

#import "Seek.h"

@interface ChessServer : NSObject <NSCoding>
@property (strong, nonatomic) NSString *serverName;
@property (strong, nonatomic) NSString *serverAddress;
@property (strong, nonatomic) NSNumber *serverPort;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userPassword;
@property (strong, nonatomic) NSString *initCommands;
@property BOOL useTimeseal;
@property BOOL connectAtStartup;
@property BOOL issueSeek;
@property (strong, nonatomic) Seek *seek;
@end
