//
//  PokerDropViewController.m
//  Poker Drop
//
//  Created by Rick Buczynski on 13-08-12.
//  Copyright (c) 2013 Rick Buczynski. All rights reserved.
//

#import "PokerDropViewController.h"
#import "PlayingCardDeck.h"
#import "PlayingCard.h"
#import "CardMatchingGame.h"

#import "AppSpecificValues.h"
#import "GameCenterManager.h"

#import <QuartzCore/QuartzCore.h>

@interface PokerDropViewController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (strong, nonatomic) CardMatchingGame *game;
@property (weak, nonatomic) IBOutlet UILabel *scoreLael;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *chainScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *chainHighScoreLabel;
@property (strong,nonatomic) NSMutableArray *buttonFrames; // SAVE ALL BUTTON FRAMES IN HERE

@property (nonatomic, strong) GameCenterManager *gameCenterManager;

@end

@implementation PokerDropViewController

BOOL selectCardLocked = NO;
BOOL deviceIsRotating = NO;

// need these to stop the "missed method" error
// in gamecentermanager
-(void)scoreReported:(NSError *)error {
    
}
-(void) processGameCenterAuth:(NSError *)error
{
    
}
-(void) reloadScoresComplete:(GKLeaderboard *)leaderBoard error:(NSError *)error
{
    
}
-(void) achievementSubmitted:(GKAchievement *)ach error:(NSError *)error
{
    
}
-(void) achievementResetResult:(NSError *)error
{
    
}
-(void) mappedPlayerIDToPlayer:(GKPlayer *)player error:(NSError *)error
{
    
}


-(void)submitHighScore
{
    if(self.game.highScore > 0)
    {
        [self.gameCenterManager reportScore:self.game.highScore forCategory:highestUpLeaderboardID];
    }
}

-(void)submitBestCombo
{
    if(self.game.chainHighScore > 0)
    {
        [self.gameCenterManager reportScore:self.game.chainHighScore forCategory:bestComboLeaderboardID];
    }
}

-(void)checkAchievements
{
    if (self.game.isAcheivementChanged) {
        for(NSString *achievement in [self.game.acheivementStatus allKeys] )
        {
            if ([self.game.acheivementStatus[achievement] isEqualToNumber:@YES])
            {
                [self.gameCenterManager submitAchievement:achievement percentComplete:100];
            }
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    deviceIsRotating = YES;
    selectCardLocked = YES;
    
    for (UIButton* cardButton in self.cardButtons)
    {
        [cardButton.layer removeAllAnimations];
    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    for (UIButton *button in self.cardButtons)
    {
        [self.view sendSubviewToBack:button];
        
        [self.buttonFrames insertObject:[[NSValue valueWithCGRect:button.frame] copy] atIndex:[self.cardButtons indexOfObject:button]];
    }
    
    deviceIsRotating = NO;
    selectCardLocked = NO;
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 1) {
        // chose yes
        [self.game dealWithCardCount:self.cardButtons.count usingDeck:[[PlayingCardDeck alloc] init]];
        [self updateUI];
    } else {
        // cancel
        //[self.gameCenterManager resetAchievements];
    }
}

- (IBAction)reDeal {
    if(!selectCardLocked && !deviceIsRotating)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"New Game"
                              message:@"Do you want to reset your game?"
                              delegate: self
                              cancelButtonTitle:@"No"
                              otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}



-(NSMutableArray *)buttonFrames
{
    if (!_buttonFrames) _buttonFrames = [[NSMutableArray alloc] init];
    
    return _buttonFrames;
}

-(CardMatchingGame *)game
{
    if (!_game) _game = [[CardMatchingGame alloc] initWithCardCount:self.cardButtons.count
                                                          usingDeck:[[PlayingCardDeck alloc] init]];
    
    return _game;
}

-(void)setCardButtons:(NSArray *)cardButtons
{
    _cardButtons = cardButtons;
    
    [self updateUI];
    
}

-(void) sortCardButtons
{
    self.cardButtons = [self.cardButtons sortedArrayUsingComparator:^NSComparisonResult(id label1, id label2) {
        if ([label1 frame].origin.y < [label2 frame].origin.y) return NSOrderedAscending;
        else if ([label1 frame].origin.y > [label2 frame].origin.y) return NSOrderedDescending;
        else if ([label1 frame].origin.x < [label2 frame].origin.x) return NSOrderedAscending;
        else if ([label1 frame].origin.x > [label2 frame].origin.x) return NSOrderedDescending;
        else return NSOrderedSame;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self sortCardButtons];
    
    for (UIButton *button in self.cardButtons)
    {
        [self.view sendSubviewToBack:button];
        
        [self.buttonFrames insertObject:[[NSValue valueWithCGRect:button.frame] copy] atIndex:[self.cardButtons indexOfObject:button]];
        //NSLog(@"%@",[NSValue valueWithCGRect:button.frame]);
    }
    
    if ([GameCenterManager isGameCenterAvailable]) {
        self.gameCenterManager = [[GameCenterManager alloc] init];
        [self.gameCenterManager setDelegate:self];
        [self.gameCenterManager authenticateLocalUser];
    } else {
        // The current device does not support Game Center.
    }
    
    [self.game loadHighScore];
    
    [self updateUI];
    
}

-(void)highlightCardAtIndex:(int)index withColor:(UIColor *)color
{
    if(index >= 0 && index < 25)
    {
        [[self.cardButtons[index] layer] setCornerRadius:8.0f];
        [[self.cardButtons[index] layer] setMasksToBounds:YES];
        [[self.cardButtons[index] layer] setBorderColor:color.CGColor];
        [[self.cardButtons[index] layer] setBorderWidth:5.0f];
    }
}

#define GAIN_SCORE_TEXT [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0]
#define LOSE_SCORE_TEXT [UIColor colorWithRed:0.6 green:0.0 blue:0.0 alpha:1.0]

-(void)updateUI
{
    for (UIButton *cardButton in self.cardButtons)
    {
        [[cardButton layer] setBorderWidth:0.0f];
    }
    
    
    for (UIButton *cardButton in self.cardButtons)
    {
        Card *card = [self.game cardAtIndex:[self.cardButtons indexOfObject:cardButton]];
        [cardButton setTitle:card.contents forState:UIControlStateNormal];
        [cardButton setTitle:card.contents forState:UIControlStateSelected];
        
        [self setTextColorForButton:cardButton];
        
        cardButton.selected = card.isSwapable;
        if (card.isSwapable) {
            int selectedIndex = [self.cardButtons indexOfObject:cardButton];
            
            int left = selectedIndex - 1;
            int top = selectedIndex - 5;
            int bottum = selectedIndex + 5;
            int right = selectedIndex + 1;
            
            BOOL doLeft = YES;
            BOOL doRight = YES;
            
            
            if (selectedIndex == 0 || selectedIndex == 5 || selectedIndex == 10 || selectedIndex == 15 || selectedIndex == 20) {
                doLeft = NO;
            }
            if (selectedIndex == 4 || selectedIndex == 9 || selectedIndex == 14 || selectedIndex == 19 || selectedIndex == 14) {
                doRight = NO;
            }
            
            [self highlightCardAtIndex:selectedIndex withColor:[UIColor blueColor]];
            
            if (doLeft) [self highlightCardAtIndex:left withColor:[UIColor greenColor]];
            if (doRight) [self highlightCardAtIndex:right withColor:[UIColor greenColor]];
            
            [self highlightCardAtIndex:top withColor:[UIColor greenColor]];
            [self highlightCardAtIndex:bottum withColor:[UIColor greenColor]];
        }
        
    }
    
    
    if (self.game.score == 0) {
        self.scoreLael.text = [NSString stringWithFormat:@"Cash: $%d", self.game.score];
        [self.scoreLael setTextColor:[UIColor blackColor]];
        
    } else if (self.game.score > 0) {
        self.scoreLael.text = [NSString stringWithFormat:@"Cash: $%d", self.game.score];
        [self.scoreLael setTextColor:GAIN_SCORE_TEXT];
        
    } else {
        self.scoreLael.text = [NSString stringWithFormat:@"Cash: -$%d", -1*self.game.score];
        [self.scoreLael setTextColor:LOSE_SCORE_TEXT];
    }
    
    if (self.game.highScore == 0) {
        self.highScoreLabel.text = [NSString stringWithFormat:@"Highest up: $%d", self.game.highScore];
        [self.highScoreLabel setTextColor:[UIColor blackColor]];
        
    } else {
        self.highScoreLabel.text = [NSString stringWithFormat:@"Highest up: $%d", self.game.highScore];
        [self.highScoreLabel setTextColor:GAIN_SCORE_TEXT];
        
    }
    
    if (self.game.chainScore == 0) {
        self.chainScoreLabel.text = [NSString stringWithFormat:@"Combo: $%d", self.game.chainScore];
        [self.chainScoreLabel setTextColor:[UIColor blackColor]];
        
    } else {
        self.chainScoreLabel.text = [NSString stringWithFormat:@"Combo: $%d", self.game.chainScore];
        [self.chainScoreLabel setTextColor:GAIN_SCORE_TEXT];
        
    }
    
    if (self.game.chainHighScore == 0) {
        self.chainHighScoreLabel.text = [NSString stringWithFormat:@"Best Combo: $%d", self.game.chainHighScore];
        [self.chainHighScoreLabel setTextColor:[UIColor blackColor]];
        
    } else {
        self.chainHighScoreLabel.text = [NSString stringWithFormat:@"Best Combo: $%d", self.game.chainHighScore];
        [self.chainHighScoreLabel setTextColor:GAIN_SCORE_TEXT];
        
    }
    
    if (self.game.isHighScoreChanged) {
        [self submitHighScore];
        self.game.highScoreChanged = NO;
    }
    
    if (self.game.isChainHighScoreChanged) {
        [self submitBestCombo];
        self.game.chainHighScoreChanged = NO;
    }
    
    [self checkAchievements];
}

-(NSArray* )determineRowfromIndex:(int)index
{
    
    
    int start = (index/5) * 5;
    //NSLog(@"id: %d, start: %d",index,start);
    
    return @[[self.game cardAtIndex:start],
             [self.game cardAtIndex:start+1],
             [self.game cardAtIndex:start+2],
             [self.game cardAtIndex:start+3],
             [self.game cardAtIndex:start+4],
             ];
}

-(NSArray* )determineColumnfromIndex:(int)index
{
    
    
    int start = index % 5;
    //NSLog(@"id: %d, start: %d",index,start);
    
    return @[[self.game cardAtIndex:start],
             [self.game cardAtIndex:start+1*5],
             [self.game cardAtIndex:start+2*5],
             [self.game cardAtIndex:start+3*5],
             [self.game cardAtIndex:start+4*5],
             ];
}

#define CARD_SHIFT_TIME 1.7
#define CARD_FADE_TIME 1.0

- (void)fadeButtonWithContents:(NSString*)contents index:(NSUInteger)index
{
    
    UIButton* fadeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:fadeButton];
    [self.view sendSubviewToBack:fadeButton];
    
    [fadeButton setTitle:contents forState:UIControlStateNormal];
    fadeButton.titleLabel.font = [[self.cardButtons lastObject] titleLabel].font;
    fadeButton.frame = [self.buttonFrames[index] CGRectValue];
    fadeButton.transform = CGAffineTransformMakeScale(1.0,1.0);
    fadeButton.alpha = 1.0f;
    
    [self setTextColorForButton:fadeButton];
    
    [UIView animateWithDuration:CARD_FADE_TIME
                     animations:^{fadeButton.alpha = 0.0f;fadeButton.transform = CGAffineTransformMakeScale(0.0,0.0);}
                     completion:^(BOOL finished){ [fadeButton removeFromSuperview]; }];
    
}

-(void)displayHandText:(NSString *)handText forRowAtIndex:(NSUInteger)index
{
    UILabel* fadingText = [[UILabel alloc] init];
    [self.view addSubview:fadingText];
    [self.view bringSubviewToFront:fadingText];
    
    fadingText.text = handText;
    
    CGRect myFrame = [self.buttonFrames[index] CGRectValue];
    myFrame.size.width = [self.buttonFrames[index+4] CGRectValue].origin.x
    + [self.buttonFrames[index+4] CGRectValue].size.width
    - [self.buttonFrames[index] CGRectValue].origin.x;
    
    fadingText.frame = myFrame;
    fadingText.textAlignment = NSTextAlignmentCenter;
    fadingText.alpha = 1.0f;
    fadingText.backgroundColor = [UIColor clearColor];
    fadingText.font = [[self.cardButtons lastObject] titleLabel].font;
    fadingText.textColor = GAIN_SCORE_TEXT;
    
    [UIView animateWithDuration:CARD_FADE_TIME
                     animations:^{
                         fadingText.alpha = 0.0f;
                         //fadingText.transform = CGAffineTransformMakeScale(0.0,0.0);
                     }
                     completion:^(BOOL finished){ [fadingText removeFromSuperview]; }];
}

-(void)displayHandText:(NSString *)handText forColumnAtIndex:(NSUInteger)index
{
    
    UILabel* fadingText = [[UILabel alloc] init];
    [self.view addSubview:fadingText];
    [self.view bringSubviewToFront:fadingText];
    
    fadingText.text = handText;
    
    CGRect myFrame = [self.buttonFrames[index+10] CGRectValue];
    
    myFrame.size.width = [self.buttonFrames[20] CGRectValue].origin.y
    + [self.buttonFrames[20] CGRectValue].size.height
    - [self.buttonFrames[0] CGRectValue].origin.y;
    
    myFrame.size.height = [self.buttonFrames[20] CGRectValue].size.width;
    
    myFrame.origin.x += [self.buttonFrames[20] CGRectValue].size.width/2 - myFrame.size.width/2;
    myFrame.origin.y += [self.buttonFrames[20] CGRectValue].size.height/2 - myFrame.size.height/2;
    
    fadingText.frame = myFrame;
    fadingText.textAlignment = NSTextAlignmentCenter;
    fadingText.alpha = 1.0f;
    fadingText.backgroundColor = [UIColor clearColor];
    fadingText.font = [[self.cardButtons lastObject] titleLabel].font;
    fadingText.textColor = GAIN_SCORE_TEXT;
    
    [fadingText setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    
    [UIView animateWithDuration:CARD_FADE_TIME
                     animations:^{
                         fadingText.alpha = 0.0f;
                         //fadingText.transform = CGAffineTransformMakeScale(0.0,0.0);
                     }
                     completion:^(BOOL finished){ [fadingText removeFromSuperview]; }];
}



-(void)shiftRows;
{
    BOOL alreadySetupChaining = NO;
    
    for (int i=24; i>=0; i--)
    {
        if ([self.game cardAtIndex:i].previousIndex != i || [self.game cardAtIndex:i].isErased)
        {
            UIButton *button = self.cardButtons[i];
            
            if ([self.game cardAtIndex:i].isErased)
            {
                [self.game cardAtIndex:i].erased = NO;
                
                int previousIndex = [(PlayingCard*)[self.game cardAtIndex:i] previousIndex];
                UIButton *prevButton = self.cardButtons[previousIndex];
                [self fadeButtonWithContents:prevButton.titleLabel.text index:previousIndex];
                
                if (previousIndex%5 == 0) {
                    NSString* handText = [(PlayingCard*)[self.game cardAtIndex:i] destroyedByHandName];
                    [self displayHandText:handText forRowAtIndex:previousIndex];
                }
                
                CGRect bottumRightButton = [[self.buttonFrames lastObject] CGRectValue];
                
                CGRect aboveScreen;
                aboveScreen = [self.buttonFrames[[self.cardButtons indexOfObject:button]] CGRectValue];
                aboveScreen.origin.y -= bottumRightButton.origin.y+bottumRightButton.size.height;
                button.frame = aboveScreen;
            } else {
                button.frame = [self.buttonFrames[[self.game cardAtIndex:i].previousIndex] CGRectValue];
            }
            
            if (alreadySetupChaining)
            {
                [UIView animateWithDuration:CARD_SHIFT_TIME
                                 animations:^{button.frame = [self.buttonFrames[i] CGRectValue];}
                                 completion:^(BOOL finished) {}];
            } else {
                selectCardLocked = YES;
                [UIView animateWithDuration:CARD_SHIFT_TIME
                                 animations:^{button.frame = [self.buttonFrames[i] CGRectValue];}
                                 completion:^(BOOL finished) {
                                     if(!deviceIsRotating)
                                     {
                                         selectCardLocked = NO;
                                         [self.game analyzeColumns];
                                         [self shiftColumns];
                                         [self updateUI];
                                     }
                                 }];
                alreadySetupChaining = YES;
            }
            
            [self.game cardAtIndex:i].previousIndex = i;
        }
    }
}

-(void)shiftColumns;
{
    BOOL alreadySetupChaining = NO;
    
    for (int i=24; i>=0; i--)
    {
        if ([self.game cardAtIndex:i].isErased)
        {
            [self.game cardAtIndex:i].erased = NO;
            
            UIButton *button = self.cardButtons[i];
            
            [self fadeButtonWithContents:button.titleLabel.text index:i];
            
            if (i%5 == i) {
                NSString* handText = [(PlayingCard*)[self.game cardAtIndex:i] destroyedByHandName];
                [self displayHandText:handText forColumnAtIndex:i];
            }
            
            
            CGRect bottumRightButton = [[self.buttonFrames lastObject] CGRectValue];
            
            CGRect aboveScreen;
            aboveScreen = [self.buttonFrames[[self.cardButtons indexOfObject:button]] CGRectValue];
            aboveScreen.origin.y -= bottumRightButton.origin.y+bottumRightButton.size.height;
            button.frame = aboveScreen;
            
            
            if (alreadySetupChaining)
            {
                [UIView animateWithDuration:CARD_SHIFT_TIME
                                 animations:^{button.frame = [self.buttonFrames[i] CGRectValue];}
                                 completion:^(BOOL finished) {}];
            } else {
                selectCardLocked = YES;
                [UIView animateWithDuration:CARD_SHIFT_TIME
                                 animations:^{button.frame = [self.buttonFrames[i] CGRectValue];}
                                 completion:^(BOOL finished) {
                                     if(!deviceIsRotating)
                                     {
                                         selectCardLocked = NO;
                                         [self.game analyzeRows];
                                         [self shiftRows];
                                         [self updateUI];
                                     }
                                 }];
                alreadySetupChaining = YES;
            }
            
            [self.game cardAtIndex:i].previousIndex = i;
            
        }
    }
}

-(void)setTextColorForButton:(UIButton*)button
{
    NSString* contents = button.titleLabel.text;
    if ([contents rangeOfString:@"♥"].location != NSNotFound || [contents rangeOfString:@"♦"].location != NSNotFound) {
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    } else {
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    }
}

#define CARD_SWAP_TIME 0.8

-(void)fadePenaltyForSwappingFromIndex:(NSUInteger)myIndex to:(NSUInteger)otherIndex
{
    UILabel* fadingText = [[UILabel alloc] init];
    [self.view addSubview:fadingText];
    [self.view bringSubviewToFront:fadingText];
    
    fadingText.text = @"-3";
    fadingText.textColor = LOSE_SCORE_TEXT;
    
    CGRect myFrame = [self.buttonFrames[myIndex] CGRectValue];
    myFrame.origin.x = (myFrame.origin.x + [self.buttonFrames[otherIndex] CGRectValue].origin.x)/2;
    myFrame.origin.y = (myFrame.origin.y + [self.buttonFrames[otherIndex] CGRectValue].origin.y)/2;
    
    fadingText.frame = myFrame;
    fadingText.textAlignment = NSTextAlignmentCenter;
    fadingText.alpha = 1.0f;
    fadingText.backgroundColor = [UIColor clearColor];
    
    [UIView animateWithDuration:CARD_SWAP_TIME
                     animations:^{
                         fadingText.alpha = 0.0f;
                         //fadingText.transform = CGAffineTransformMakeScale(0.0,0.0);
                     }
                     completion:^(BOOL finished){ [fadingText removeFromSuperview]; }];
}

-(void)animateSwappingFromIndex:(NSUInteger)myIndex to:(NSUInteger)otherIndex
{
    [self fadePenaltyForSwappingFromIndex:myIndex to:otherIndex];
    
    UIButton* myButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:myButton];
    [self.view sendSubviewToBack:myButton];
    [myButton setTitle:[[self.cardButtons[myIndex] titleLabel] text] forState:UIControlStateNormal];
    myButton.titleLabel.font = [[self.cardButtons lastObject] titleLabel].font;
    myButton.frame = [self.buttonFrames[myIndex] CGRectValue];
    myButton.transform = CGAffineTransformMakeScale(1.0,1.0);
    myButton.alpha = 1.0f;
    
    UIButton* otherButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:otherButton];
    [self.view sendSubviewToBack:otherButton];
    [otherButton setTitle:[[self.cardButtons[otherIndex] titleLabel] text] forState:UIControlStateNormal];
    otherButton.titleLabel.font = [[self.cardButtons lastObject] titleLabel].font;
    otherButton.frame = [self.buttonFrames[otherIndex] CGRectValue];
    otherButton.transform = CGAffineTransformMakeScale(1.0,1.0);
    otherButton.alpha = 1.0f;
    
    [self setTextColorForButton:myButton];
    [self setTextColorForButton:otherButton];
    
    [self.cardButtons[myIndex] setAlpha:0];
    [self.cardButtons[otherIndex] setAlpha:0];
    
    selectCardLocked = YES;
    [UIView animateWithDuration:CARD_SWAP_TIME
                     animations:^{
                         myButton.frame = [self.buttonFrames[otherIndex] CGRectValue];
                         otherButton.frame = [self.buttonFrames[myIndex] CGRectValue];
                     }
                     completion:^(BOOL finished) {
                         
                         if (!deviceIsRotating)
                         {
                             selectCardLocked = NO;
                             
                             if (otherIndex == myIndex + 5 || otherIndex == myIndex - 5) {
                                 // kill rows
                                 [self.game analyzeTwoRowsAtIndex:MIN(myIndex, otherIndex)];
                                 [self shiftRows];
                             } else if (otherIndex == myIndex + 1 || otherIndex == myIndex - 1) {
                                 // killl columns
                                 [self.game analyzeTwoColumnsAtIndex:MIN(myIndex, otherIndex)];
                                 [self shiftColumns];
                             }
                         } else {
                             [self.game swapCardsWithIndex:myIndex andIndex:otherIndex];
                             for (int i=24; i>=0; i--)
                             {
                                 [self.game cardAtIndex:i].previousIndex = i;
                             }
                         }
                         
                         [self.cardButtons[myIndex] setAlpha:1];
                         [self.cardButtons[otherIndex] setAlpha:1];
                         [myButton removeFromSuperview];
                         [otherButton removeFromSuperview];
                         
                         [self updateUI];
                     }];
}

- (IBAction)selectCard:(UIButton *)sender {
    
    if (!selectCardLocked)
    {
        [self.game resetChainScore];
        
        NSUInteger myIndex = [self.cardButtons indexOfObject:sender];
        NSUInteger otherIndex = [self.game selectAndSwapAtIndex:myIndex];
        //NSLog(@"myIdex: %d    otherIndex: %d",myIndex,otherIndex);
        
        if(otherIndex < 25) {
            [self animateSwappingFromIndex:myIndex to:otherIndex];
        }
        
        
        [self updateUI];
    }
    
    
}



@end
