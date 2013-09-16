//
//  CardMatchingGame.h
//  Matchismo
//
//  Created by Rick Buczynski on 13-06-29.
//  Copyright (c) 2013 Buczynsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deck.h"
#import "pokerEvaluator.h"

@interface CardMatchingGame : NSObject

- (id)initWithCardCount:(NSUInteger)cardCount
              usingDeck:(Deck *)deck;


- (NSUInteger)selectAndSwapAtIndex:(NSUInteger)index;

- (Card *)cardAtIndex:(NSUInteger)index;

- (void)dealWithCardCount:(NSUInteger)cardCount
                usingDeck:(Deck *)deck;



-(void)analyzeRows;
-(void)analyzeColumns;

-(void)analyzeTwoRowsAtIndex:(NSUInteger)index;
-(void)analyzeTwoColumnsAtIndex:(NSUInteger)index;

-(void)swapCardsWithIndex:(NSUInteger)i andIndex:(NSUInteger)j;

-(void)loadHighScore;
-(void)resetChainScore;

@property (nonatomic, readonly) int score;
@property (nonatomic, readonly) int highScore;
@property (nonatomic, readonly) int chainScore;
@property (nonatomic, readonly) int chainHighScore;
@property (nonatomic, getter = isHighScoreChanged) bool highScoreChanged;
@property (nonatomic, getter = isChainHighScoreChanged) bool chainHighScoreChanged;

@property (strong, nonatomic) NSString *flipResult;
@property (nonatomic) int matchMode;
@property (strong, nonatomic) pokerEvaluator *pokerHandEvaluator;
@property (strong,nonatomic) Deck *deck;



@end
