//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Rick Buczynski on 13-06-29.
//  Copyright (c) 2013 Buczynsoft. All rights reserved.
//

#import "CardMatchingGame.h"
#import "PlayingCard.h"
#import "PokerDropViewController.h"

@interface CardMatchingGame()
@property (strong, nonatomic) NSMutableArray *cards;
@property (nonatomic) int score;
@property (nonatomic) int highScore;
@property (nonatomic) int chainScore;
@property (nonatomic) int chainHighScore;
@end

@implementation CardMatchingGame

- (pokerEvaluator *)pokerHandEvaluator
{
    if (!_pokerHandEvaluator) _pokerHandEvaluator = [[pokerEvaluator alloc] init];
    return _pokerHandEvaluator;
}

- (NSMutableArray *) cards
{
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

- (id)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck
{
    self = [super init];
    
    if (self) {
        for (int i = 0; i < count; i++)
        {
            Card* card = [deck drawRandomCard];
            if (!card) {
                self = nil;
            } else {
                card.previousIndex = i;
                card.erased = NO;
                self.cards[i] = card;
            }
        }
    }
    
    self.deck=deck;
    
    self.highScoreChanged = NO;
    self.chainHighScoreChanged = NO;
    
    
    return self;
}

- (void)dealWithCardCount:(NSUInteger)cardCount usingDeck:(Deck *)deck
{
    for (int i = 0; i < cardCount; i++)
    {
        Card* card = [deck drawRandomCard];
        card.previousIndex = i;
        card.erased = NO;
        self.cards[i] = card;
    }
    self.score = 0;
    self.deck=deck;
}

- (Card *)cardAtIndex:(NSUInteger)index
{
    return (index < self.cards.count) ? self.cards[index] : nil;
}

- (NSUInteger)selectAndSwapAtIndex:(NSUInteger)index;
{
    Card *card = [self cardAtIndex:index];
    for (Card* otherCard in self.cards) {
        BOOL isValidSwap = NO;
        int myIndex = [self.cards indexOfObject:card];
        int otherIndex = [self.cards indexOfObject:otherCard];
        
        if (otherIndex == (myIndex - 1) && myIndex != 0 && myIndex != 5 && myIndex != 10 && myIndex != 15 && myIndex != 20) {
            isValidSwap = YES;
        } else if (otherIndex == (myIndex + 1) && myIndex != 4 && myIndex != 9 && myIndex != 14 && myIndex != 19 && myIndex != 24) {
            isValidSwap = YES;
        } else if (otherIndex == (myIndex + 5) ) {
            isValidSwap = YES;
        } else if (otherIndex == (myIndex - 5) ) {
            isValidSwap = YES;
        } else {
            isValidSwap = NO;
        }
        
        
        if (otherCard.isSwapable && isValidSwap) {
            card.swapable = NO;
            otherCard.swapable = NO;
            [(id)card swapWith:(id)otherCard];
            
            NSUInteger temp = card.previousIndex;
            card.previousIndex = otherCard.previousIndex;
            otherCard.previousIndex = temp;
            
            
            self.score -= 3;
            return otherIndex;
        } else if (otherCard.isSwapable && !isValidSwap) {
            card.swapable = YES;
            otherCard.swapable = NO;
            return 25;
        }
         
    }
    
    card.swapable = !card.isSwapable;
    
    return 25;
}

-(void)swapCardsWithIndex:(NSUInteger)i andIndex:(NSUInteger)j
{
    [(id)self.cards[i] swapWith:(id)self.cards[j]];
}

-(void)updateHighScore
{
    if (self.score > self.highScore) {
        self.highScore = self.score;
        [[NSUserDefaults standardUserDefaults] setInteger:self.highScore forKey:@"high_score"];
        self.highScoreChanged = YES;
    }
    
    if (self.chainScore > self.chainHighScore) {
        self.chainHighScore = self.chainScore;
        [[NSUserDefaults standardUserDefaults] setInteger:self.chainHighScore forKey:@"chain_high_score"];
        self.chainHighScoreChanged = YES;
    }
}

-(void)loadHighScore
{
    self.highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"high_score"];
    
    self.chainHighScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"chain_high_score"];
}

- (void)resetChainScore
{
    self.chainScore = 0;
}

#define SCORE_ROYAL_FLUSH 250
#define SCORE_STRAIGHT_FLUSH 50
#define SCORE_FOUR_KIND 25
#define SCORE_FULL_HOUSE 9
#define SCORE_FLUSH 6
#define SCORE_STRAIGHT 4
#define SCORE_THREE_KIND 3
#define SCORE_TWO_PAIR 2
#define SCORE_ONE_PAIR 1


- (BOOL)isGoodPokerHand:(NSArray *)hand
{
    NSString* handType = [self.pokerHandEvaluator pokerHandfromCards:hand];
    BOOL isGoodHand;
    
    NSUInteger handScore = 0;
    if ([handType isEqualToString:@"Straight Flush"]) {
        if ([self.pokerHandEvaluator highCardInHand:hand] == 14) {
            handScore=SCORE_ROYAL_FLUSH;
            isGoodHand = YES;
        } else {
            handScore=SCORE_STRAIGHT_FLUSH;
            isGoodHand = YES;
        }
    } else if ([handType isEqualToString:@"Four of a Kind"]) {
        handScore=SCORE_FOUR_KIND;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Full House"]) {
        handScore=SCORE_FULL_HOUSE;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Flush"]) {
        handScore=SCORE_FLUSH;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Straight"]) {
        handScore=SCORE_STRAIGHT;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Three of a Kind"]) {
        handScore=SCORE_THREE_KIND;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Two Pair"]) {
        handScore=SCORE_TWO_PAIR;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"One Pair"]) {
        handScore=SCORE_ONE_PAIR;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"High Card"]) {
        handScore=0;
        isGoodHand = NO;
    }
    else {
        isGoodHand = NO;
    }
    
    self.score += handScore;
    self.chainScore += handScore;
    
    [self updateHighScore];
    
    return isGoodHand;
    
}

- (BOOL)isGoodPokerHandChain:(NSArray *)hand
{
    NSString* handType = [self.pokerHandEvaluator pokerHandfromCards:hand];
    BOOL isGoodHand;
    
    
    NSUInteger handScore = 0;
    if ([handType isEqualToString:@"Straight Flush"]) {
        if ([self.pokerHandEvaluator highCardInHand:hand] == 14) {
            handScore = SCORE_ROYAL_FLUSH;
            isGoodHand = YES;
        } else {
            handScore = SCORE_STRAIGHT_FLUSH;
            isGoodHand = YES;
        }
    } else if ([handType isEqualToString:@"Four of a Kind"]) {
        handScore = SCORE_FOUR_KIND;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Full House"]) {
        handScore = SCORE_FULL_HOUSE;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Flush"]) {
        handScore = SCORE_FLUSH;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Straight"]) {
        handScore = SCORE_STRAIGHT;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Three of a Kind"]) {
        handScore = SCORE_THREE_KIND;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Two Pair"]) {
        handScore = SCORE_TWO_PAIR;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"One Pair"]) {
        if ([self.pokerHandEvaluator rankOfPairInHand:hand] > 10) {
            handScore = 0;
            isGoodHand = NO;
        } else {
            handScore = 0;
            isGoodHand = NO;
        }
    } else if ([handType isEqualToString:@"High Card"]) {
        handScore = 0;
        isGoodHand = NO;
    }
    else {
        isGoodHand = NO;
    }
    
    self.score += handScore;
    self.chainScore += handScore;
    
    [self updateHighScore];
    
    return isGoodHand;
}


- (void)killRowAtIndex:(NSUInteger)index withHandName:(NSString *)handName
{
    NSUInteger rowStart = (index/5) * 5;
    
    if (rowStart>=5)
    {
        for (int i=rowStart-1; i>=0; i--)
        {
            [self swapCardsWithIndex:i andIndex:i+5];
        }
    }
    
    for (int i=0; i<5; i++)
    {
        PlayingCard* myCard = (PlayingCard *)self.cards[i];
        [self addCardWithRank:myCard.rank withSuit:myCard.suit];
        
        self.cards[i] = [self.deck drawRandomCard];
        
        [self.cards[i] setErased:YES];
        [self.cards[i] setPreviousIndex:(i+rowStart)];
        [self.cards[i] setDestroyedByHandName:handName];
    }
}

- (void)killColumnAtIndex:(NSUInteger)index withHandName:(NSString *)handName
{
    NSUInteger columnStart = (index%5);
    
    for (int i=0; i<5; i++)
    {
        PlayingCard* myCard = (PlayingCard *)self.cards[columnStart+i*5];
        [self addCardWithRank:myCard.rank withSuit:myCard.suit];
        
        
        self.cards[columnStart+i*5] = [self.deck drawRandomCard];
        
        [self.cards[columnStart+i*5] setErased:YES];
        [self.cards[columnStart+i*5] setPreviousIndex:(25)];
        [self.cards[columnStart+i*5] setDestroyedByHandName:handName];
    }
}

- (void)addCardWithRank:(NSUInteger)rank withSuit:(NSString*)suit
{
    PlayingCard* card = [[PlayingCard alloc] init];
    
    card.rank = rank;
    card.suit = suit;
    
   // NSLog(@"add card with rank: %d and suit: %@",card.rank,card.suit);
    
    [self.deck addCard:card atTop:YES];
}

-(NSString *)getScoreFromHandName:(NSString *)handType
{
    
    NSUInteger handScore = 0;
    if ([handType isEqualToString:@"Royal Flush"]) {
        handScore = SCORE_ROYAL_FLUSH;
    } else if ([handType isEqualToString:@"Straight Flush"]) {
        handScore = SCORE_STRAIGHT_FLUSH;
    } else if ([handType isEqualToString:@"Four of a Kind"]) {
        handScore = SCORE_FOUR_KIND;
    } else if ([handType isEqualToString:@"Full House"]) {
        handScore=SCORE_FULL_HOUSE;
    } else if ([handType isEqualToString:@"Flush"]) {
        handScore=SCORE_FLUSH;
    } else if ([handType isEqualToString:@"Straight"]) {
        handScore=SCORE_STRAIGHT;
    } else if ([handType isEqualToString:@"Three of a Kind"]) {
        handScore=SCORE_THREE_KIND;
    } else if ([handType isEqualToString:@"Two Pair"]) {
        handScore=SCORE_TWO_PAIR;
    } else if ([handType isEqualToString:@"One Pair"]) {
        handScore=SCORE_ONE_PAIR;
    }
    
    return [NSString stringWithFormat:@"    +%d",handScore];
}


-(NSString *)getHandNameFromHand:(NSArray *)hand
{
    if ([[self.pokerHandEvaluator pokerHandfromCards:hand] isEqualToString:@"Straight Flush"]
        && [self.pokerHandEvaluator highCardInHand:hand] == 14) {
        return @"Royal Flush";
    } else {
        return [self.pokerHandEvaluator pokerHandfromCards:hand];
    }
}

-(NSString *)getHandNameWithScoreFromHand:(NSArray *)hand
{
    NSString* handNameWithScore = [self getHandNameFromHand:hand];
    handNameWithScore = [handNameWithScore stringByAppendingString:[self getScoreFromHandName:[self getHandNameFromHand:hand]]];
    return handNameWithScore;
}

-(void)analyzeRows
{
    for (int i=0; i<=20; i+=5)
    {
        NSRange handRange;
        handRange.location = i;
        handRange.length = 5;
        NSArray* hand = [self.cards subarrayWithRange:handRange];
        
        if ([self isGoodPokerHandChain:hand]) {
            [self killRowAtIndex:i withHandName:[self getHandNameWithScoreFromHand:hand]];
        }
    }
    
}

-(void)analyzeColumns
{
    for (int i=0; i<5; i++)
    {
        NSArray* hand =  @[self.cards[i],self.cards[i+5],self.cards[i+10],self.cards[i+15],self.cards[i+20]];
        
        if ([self isGoodPokerHandChain:hand]) {
            [self killColumnAtIndex:i withHandName:[self getHandNameWithScoreFromHand:hand]];
        }
    }
    
}

-(void)analyzeTwoRowsAtIndex:(NSUInteger)index
{
    NSUInteger rowStart = (index/5) * 5;
    
    for (int i=rowStart; i<=rowStart+5; i+=5)
    {
        NSRange handRange;
        handRange.location = i;
        handRange.length = 5;
        NSArray* hand = [self.cards subarrayWithRange:handRange];
        
        if ([self isGoodPokerHand:hand]) {
            [self killRowAtIndex:i withHandName:[self getHandNameWithScoreFromHand:hand]];
        }
    }
    
}


-(void)analyzeTwoColumnsAtIndex:(NSUInteger)index
{
    NSUInteger columnStart = (index%5);
    
    for (int i=columnStart; i<=columnStart+1; i++)
    {
        NSArray* hand =  @[self.cards[i],self.cards[i+5],self.cards[i+10],self.cards[i+15],self.cards[i+20]];
        
        if ([self isGoodPokerHand:hand]) {
            [self killColumnAtIndex:i withHandName:[self getHandNameWithScoreFromHand:hand]];
        }
    }
    
}

@end
