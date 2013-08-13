//
//  pokerEvaluator.m
//  Matchismo
//
//  Created by Rick Buczynski on 13-07-06.
//  Copyright (c) 2013 Buczynsoft. All rights reserved.
//

#import "pokerEvaluator.h"
#import "poker.h"
#import "PlayingCard.h"

@implementation pokerEvaluator

-(NSString *)pokerHandfromCards:(NSArray *)cards
{
    static char *value_str[] = {
        "",
        "Straight Flush",
        "Four of a Kind",
        "Full House",
        "Flush",
        "Straight",
        "Three of a Kind",
        "Two Pair",
        "One Pair",
        "High Card"
    };
    
    static int primes[] = { 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41 };
    
    int hand[5];
   
    int handIndex = 0;
    for (PlayingCard* card in cards)
    {
        int pokerRank = card.rank;
        pokerRank = (pokerRank == 1) ? 14 : pokerRank; // ace is high
        pokerRank-=2; // poker lib starts counting from 0 instead of 2
        
        //NSLog(@"rank: %d, suit: %@",pokerRank,card.suit);
        
        int suit;
        
        if ([card.suit isEqualToString:@"♥"]) {
            suit = HEART;
        } else if ([card.suit isEqualToString:@"♦"]) {
            suit = DIAMOND;
        } else if ([card.suit isEqualToString:@"♠"]) {
            suit = SPADE;
        } else if ([card.suit isEqualToString:@"♣"]) {
            suit = CLUB;
        } else {
            suit = 0;// something went wrong, should crash
            NSLog(@"bad suit");
            assert(0);
        }
        
        
        int j = pokerRank;
        hand[handIndex] = primes[j] | (j << 8) | suit | (1 << (16+j));
        handIndex++;
    }
    
    
    

    
    int i = eval_5hand( hand );
    int j = hand_rank(i);
    
    return [NSString stringWithFormat:@"%s", value_str[j]];
}

-(NSUInteger)highCardInHand:(NSArray *)hand
{
    NSUInteger maxRank = 0;
    for (PlayingCard* card in hand)
    {
        NSUInteger pokerRank = card.rank;
        pokerRank = (pokerRank == 1) ? 14 : pokerRank; // ace is high
        maxRank = MAX(maxRank, pokerRank);
    }
    
    return maxRank;
}

-(NSUInteger)rankOfPairInHand:(NSArray *)hand
{
    for (PlayingCard* card in hand)
    {
        for (PlayingCard* otherCard in hand)
        {
            if (otherCard.rank == card.rank && ![otherCard.suit isEqualToString:card.suit]) {
                return card.rank == 1 ? 14 : card.rank;
            }
        }
    }
    return 0;
}

@end
