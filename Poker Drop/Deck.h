//
//  Deck.h
//  Matchismo
//
//  Created by Rick Buczynski on 13-06-27.
//  Copyright (c) 2013 Buczynsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface Deck : NSObject

- (void)addCard:(Card*)card atTop:(BOOL)atTop;
-(Card*)drawRandomCard;

@end
