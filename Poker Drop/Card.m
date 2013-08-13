//
//  Card.m
//  Matchismo
//
//  Created by Rick Buczynski on 13-06-27.
//  Copyright (c) 2013 Buczynsoft. All rights reserved.
//

#import "Card.h"

@implementation Card

-(int)match:(NSArray*)otherCards
{
    int score = 0;
    
    for (Card* card in otherCards){
        if([card.contents isEqualToString:self.contents]){
            score = 1;
        }
    }
    
    return score;
}

@end
