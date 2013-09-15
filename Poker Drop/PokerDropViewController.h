//
//  PokerDropViewController.h
//  Poker Drop
//
//  Created by Rick Buczynski on 13-08-12.
//  Copyright (c) 2013 Rick Buczynski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "GameCenterManager.h"
@class GameCenterManager;

// may need to add GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate
// probably needed for showing leaders or acheivements in the app

@interface PokerDropViewController : UIViewController <UIActionSheetDelegate, GameCenterManagerDelegate> 

@end
