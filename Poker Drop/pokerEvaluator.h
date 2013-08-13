//
//  pokerEvaluator.h
//  Matchismo
//
//  Created by Rick Buczynski on 13-07-06.
//  Copyright (c) 2013 Buczynsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface pokerEvaluator : NSObject

-(NSString *)pokerHandfromCards:(NSArray *)cards;
-(NSUInteger)highCardInHand:(NSArray *)hand;
-(NSUInteger)rankOfPairInHand:(NSArray *)hand;

@end
