//
//  Bullet.h
//  SlingshotAce
//
//  Created by Kodigo Systems on 6/17/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"
#import "CCProtocols.h"

@interface Bullet : CCSprite

@property (nonatomic, assign) float life;
@property (nonatomic, assign) CGPoint prevPosition;
@property (nonatomic, assign) BOOL released;

@end
