//
//  poker.h
//  Matchismo
//
//  Created by Rick Buczynski on 13-07-06.
//  Copyright (c) 2013 Buczynsoft. All rights reserved.
//

#ifndef Matchismo_poker_h
#define Matchismo_poker_h

#define	STRAIGHT_FLUSH	1
#define	FOUR_OF_A_KIND	2
#define	FULL_HOUSE	3
#define	FLUSH		4
#define	STRAIGHT	5
#define	THREE_OF_A_KIND	6
#define	TWO_PAIR	7
#define	ONE_PAIR	8
#define	HIGH_CARD	9

#define	RANK(x)		((x >> 8) & 0xF)



void init_deck( int *deck );

int
hand_rank( short val );

short
eval_5hand( int *hand );


#define CLUB	0x8000
#define DIAMOND 0x4000
#define HEART   0x2000
#define SPADE   0x1000

#define Deuce	0
#define Trey	1
#define Four	2
#define Five	3
#define Six	4
#define Seven	5
#define Eight	6
#define Nine	7
#define Ten	8
#define Jack	9
#define Queen	10
#define King	11
#define Ace	12


#endif
