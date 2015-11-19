//
//  ChessServer.h
//  Kibitz
//
//  Copyright 2014 William Entriken, licensed under the MIT license:
//  http://opensource.org/licenses/MIT
//
//  Based on Kibitz / ChessServer 2006 Klaus Thul
//

#import "ChessServer.h"

@implementation ChessServer

- (NSString *)description
{
    return self.serverName;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.serverName = [coder decodeObjectForKey:@"serverName"];
        self.serverAddress = [coder decodeObjectForKey:@"serverAddress"];
        self.serverPort = [coder decodeObjectForKey:@"serverPort"];
        self.userName = [coder decodeObjectForKey:@"userName"];
        self.userPassword = [coder decodeObjectForKey:@"userPassword"];
        self.initCommands = [coder decodeObjectForKey:@"initCommands"];
        self.useTimeseal = [coder decodeBoolForKey:@"useTimeseal"];
        self.connectAtStartup = [coder decodeBoolForKey:@"connectAtStartup"];
        self.issueSeek = [coder decodeBoolForKey:@"issueSeek"];
        self.seek = [coder decodeObjectForKey:@"seek"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject: self.serverName forKey: @"serverName"];
	[coder encodeObject: self.serverAddress forKey: @"serverAddress"];
	[coder encodeObject: self.serverPort forKey: @"serverPort"];
	[coder encodeObject: self.userName forKey: @"userName"];
	[coder encodeObject: self.userPassword forKey: @"userPassword"];
	[coder encodeObject: self.initCommands forKey: @"initCommands"];
	[coder encodeBool: self.useTimeseal forKey: @"useTimeseal"];
	[coder encodeBool: self.connectAtStartup forKey: @"connectAtStartup"];
	[coder encodeBool: self.issueSeek forKey: @"issueSeek"];
	[coder encodeObject: self.seek forKey: @"seek"];
}

@end
