//
//  PlayingCard.h
//  Matchismo
//
//  Created by Rick Buczynski on 13-06-27.
//  Copyright (c) 2013 Buczynsoft. All rights reserved.
//

#import "Card.h"

@interface PlayingCard : Card

@property (strong, nonatomic) NSString *suit;
@property (nonatomic) NSUInteger rank;


+ (NSArray*)validSuits;
+ (NSUInteger) maxRank;
+ (NSArray*)rankStrings;

-(void)swapWith:(PlayingCard *)otherCard;

@end
