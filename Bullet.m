//
//  Bullet.m
//  SlingshotAce
//
//  Created by Kodigo Systems on 6/17/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet

- (void)didLoadFromCCB {
    CCLOG(@"Bullet didLoadFromCCB!");
    self.physicsBody.collisionType = @"Bullet";
}

@end
