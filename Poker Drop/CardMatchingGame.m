//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Rick Buczynski on 13-06-29.
//  Copyright (c) 2013 Buczynsoft. All rights reserved.
//

#import "CardMatchingGame.h"
#import "PlayingCard.h"

@interface CardMatchingGame()
@property (strong, nonatomic) NSMutableArray *cards;
@property (nonatomic) int score;
@property (nonatomic) int highScore;
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
    
    self.matchMode = 2;
    
    
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
            
            // remove this later when I want cards to animate swapping
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
    self.highScore = MAX(self.highScore, self.score);
    [[NSUserDefaults standardUserDefaults] setInteger:self.highScore forKey:@"high_score"];
}

-(void)loadHighScore
{
    self.highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"high_score"];
}

- (BOOL)isGoodPokerHand:(NSArray *)hand
{
    NSString* handType = [self.pokerHandEvaluator pokerHandfromCards:hand];
    BOOL isGoodHand;
        
    if ([handType isEqualToString:@"Straight Flush"]) {
        if ([self.pokerHandEvaluator highCardInHand:hand] == 14) {
            self.score+=800;
            isGoodHand = YES;
        } else {
            self.score+=50;
            isGoodHand = YES;
        }
    } else if ([handType isEqualToString:@"Four of a Kind"]) {
        self.score+=25;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Full House"]) {
        self.score+=9;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Flush"]) {
        self.score+=6;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Straight"]) {
        self.score+=4;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Three of a Kind"]) {
        self.score+=3;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Two Pair"]) {
        self.score+=2;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"One Pair"]) {
        self.score+=1;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"High Card"]) {
        self.score+=0;
        isGoodHand = NO;
    }
    else {
        isGoodHand = NO;
    }
    
    [self updateHighScore];
    return isGoodHand;
    
}

- (BOOL)isGoodPokerHandChain:(NSArray *)hand
{
    NSString* handType = [self.pokerHandEvaluator pokerHandfromCards:hand];
    BOOL isGoodHand;
    
    if ([handType isEqualToString:@"Straight Flush"]) {
        if ([self.pokerHandEvaluator highCardInHand:hand] == 14) {
            self.score+=800;
            isGoodHand = YES;
        } else {
            self.score+=50;
            isGoodHand = YES;
        }
    } else if ([handType isEqualToString:@"Four of a Kind"]) {
        self.score+=25;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Full House"]) {
        self.score+=9;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Flush"]) {
        self.score+=6;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Straight"]) {
        self.score+=4;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Three of a Kind"]) {
        self.score+=3;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"Two Pair"]) {
        self.score+=2;
        isGoodHand = YES;
    } else if ([handType isEqualToString:@"One Pair"]) {
        if ([self.pokerHandEvaluator rankOfPairInHand:hand] > 10) {
            self.score+=0;
            isGoodHand = NO;
        } else {
            self.score+=0;
            isGoodHand = NO;
        }
    } else if ([handType isEqualToString:@"High Card"]) {
        self.score+=0;
        isGoodHand = NO;
    }
    else {
        isGoodHand = NO;
    }
    
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


-(NSString *)getHandNameFromHand:(NSArray *)hand
{
    if ([[self.pokerHandEvaluator pokerHandfromCards:hand] isEqualToString:@"Straight Flush"]
        && [self.pokerHandEvaluator highCardInHand:hand] == 14) {
        return @"Royal Flush";
    } else {
        return [self.pokerHandEvaluator pokerHandfromCards:hand];
    }
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
            [self killRowAtIndex:i withHandName:[self getHandNameFromHand:hand]];
        }
    }
    
}

-(void)analyzeColumns
{
    for (int i=0; i<5; i++)
    {
        NSArray* hand =  @[self.cards[i],self.cards[i+5],self.cards[i+10],self.cards[i+15],self.cards[i+20]];
        
        if ([self isGoodPokerHandChain:hand]) {
            [self killColumnAtIndex:i withHandName:[self getHandNameFromHand:hand]];
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
            [self killRowAtIndex:i withHandName:[self getHandNameFromHand:hand]];
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
            [self killColumnAtIndex:i withHandName:[self getHandNameFromHand:hand]];
        }
    }
    
}

@end
