//
//  PlayingCard.m
//  Matchismo
//
//  Created by Rick Buczynski on 13-06-27.
//  Copyright (c) 2013 Buczynsoft. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard

- (int)match:(NSArray *)otherCards
{
    int score = 0;
    
    if (otherCards.count == 1){
        PlayingCard* otherCard = [otherCards lastObject];
        if ([otherCard.suit isEqualToString:self.suit]) {
            score = 1;
        } else if (otherCard.rank == self.rank) {
            score = 4;
        }
    } else if(otherCards.count == 2) {
        PlayingCard* otherCard = [otherCards lastObject];
        PlayingCard* yetAnotherCard = otherCards[0];
        
        if (self.rank == otherCard.rank && self.rank == yetAnotherCard.rank) {
            score = 48; // 3 same rank
        } else if ([otherCard.suit isEqualToString:self.suit] && [yetAnotherCard.suit isEqualToString:self.suit]) {
            score = 5; // 3 same suit
        } else if (self.rank == otherCard.rank ||
                   self.rank == yetAnotherCard.rank ||
                   yetAnotherCard.rank == otherCard.rank) {
            score = 4; // 2 same rank
        } else if ([otherCard.suit isEqualToString:self.suit] ||
                   [yetAnotherCard.suit isEqualToString:self.suit] ||
                   [yetAnotherCard.suit isEqualToString:otherCard.suit]) {
            score = 1; // 2 same suit
        }
        
    }
    
    
    return score;
}

-(NSString*)contents
{
    return [[PlayingCard rankStrings][self.rank] stringByAppendingString:self.suit];
}

@synthesize suit = _suit;

+ (NSArray*)validSuits
{
    static NSArray *validSuits = nil;
    if(!validSuits) validSuits = @[@"♥",@"♦",@"♠",@"♣"];
    return validSuits;
                                   
}

-(void)setSuit:(NSString *)suit
{
    if([[PlayingCard validSuits] containsObject:suit]){
        _suit = suit;
    }
}

-(NSString*)suit
{
    return _suit ? _suit : @"?";
}

+(NSArray*)rankStrings
{
    return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"];
}

+(NSUInteger)maxRank{return [self rankStrings].count-1;}

-(void)setRank:(NSUInteger)rank
{
    if(rank <= [PlayingCard maxRank]) {
        _rank = rank;
    }
}

-(void)swapWith:(PlayingCard *)otherCard
{
    PlayingCard *temp = [[PlayingCard alloc] init];
    
    temp.suit = self.suit;
    temp.rank = self.rank;
    temp.previousIndex = self.previousIndex;
    temp.erased = self.isErased;
    temp.destroyedByHandName = self.destroyedByHandName;
    
    self.suit = otherCard.suit;
    self.rank = otherCard.rank;
    self.previousIndex = otherCard.previousIndex;
    self.erased = otherCard.isErased;
    self.destroyedByHandName = otherCard.destroyedByHandName;
    
    otherCard.suit = temp.suit;
    otherCard.rank = temp.rank;
    otherCard.previousIndex = temp.previousIndex;
    otherCard.erased = temp.isErased;
    otherCard.destroyedByHandName = temp.destroyedByHandName;
}

@end
