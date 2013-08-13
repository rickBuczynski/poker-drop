//
//  Card.h
//  Matchismo
//
//  Created by Rick Buczynski on 13-06-27.
//  Copyright (c) 2013 Buczynsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject

@property NSUInteger previousIndex;
@property (strong,nonatomic) NSString* contents;
@property (nonatomic, getter = isFaceUp) BOOL faceUp;
@property (nonatomic, getter = isUnplayable) BOOL unplayable;
@property (nonatomic, getter = isSwapable) BOOL swapable;
@property (nonatomic, getter = isErased) BOOL erased;
@property (strong,nonatomic) NSString *destroyedByHandName;

-(int)match:(NSArray *)otherCards;


@end
