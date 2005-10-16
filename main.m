//
//  main.m
//  icsinterface
//
//  Created by Thul Klaus on 10/15/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "game.h"
#import <stdio.h>

int main(int argc, char *argv[])
{
	Game *g = [[Game alloc] init];
	FILE *f = fopen("/users/kthul/Desktop/test.game", "r");
	char s[256];
	
	while(fgets(s, 255, f) != NULL) {
		printf("%s\n", s);
		[g doMove: [ChessMove fromString: s]];
		[g printGame];
	}
    return NSApplicationMain(argc,  (const char **) argv);
}
