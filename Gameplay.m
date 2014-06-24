//
//  Gameplay.m
//  SlingshotAce
//
//  Created by Kodigo Systems on 6/17/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Bullet.h"
#import "FirstMob.h"
#import "CCActionInterval.h"

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    
    //box from which the user will draw bullets
    CCNode *_slingshotStart;
    CCPhysicsJoint *_slingshotSpring;
    
    //glue to keep bullet attached to sling until release
    CCNode *_dragNode;
    CCPhysicsJoint *_dragSpring;
    
    Bullet *_loadedBullet;
    NSMutableArray *_currentBullets;
    
}

-(void) didLoadFromCCB {
    // tell this scene to accept touches
    
    CCLOG(@"didloadgameplay!");
    self.userInteractionEnabled = TRUE;
    
    //_physicsNode.debugDraw = TRUE;
    
    _physicsNode.collisionDelegate = self;
    
    [_slingshotStart.physicsBody setCollisionMask:@[]];
    [_dragNode.physicsBody setCollisionMask:@[]];

    _currentBullets = [[NSMutableArray alloc] init];
    
    [self schedule:@selector(addMonster:) interval:2.0];
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    //[self shootBullet];
    
    //[self shootBullet];
    CGPoint touchLocation = [touch locationInNode:_physicsNode];
    //CGFloat xDisp = ;
    //CGFloat yDisp = _slingshotStart.position.y - touchLocation.y;
    CGFloat magnitude = [self pythagLengthWithSideX:_slingshotStart.position.x - touchLocation.x
                                              sideY:_slingshotStart.position.y - touchLocation.y];//sqrt(pow(xDisp, 2.0) + pow(yDisp, 2.0));
    CGPoint shootVect = ccp((_slingshotStart.position.x - touchLocation.x)/magnitude, (_slingshotStart.position.y - touchLocation.y)/magnitude);
    
    [self shootBullet:shootVect];
    CCLOG(@"here is the location of the touch: x:%.2f y: %.2f", touchLocation.x, touchLocation.y);
//    if(CGRectContainsPoint([_slingshotStart boundingBox], touchLocation) && (_loadedBullet == nil || _loadedBullet.released)) {
//        _loadedBullet = [CCBReader load:@"Bullet"];
//        _loadedBullet.released = NO;
//        _dragNode.position = touchLocation;
//        _loadedBullet.position = touchLocation;
//        _loadedBullet.physicsBody.collisionMask = @[];
//        [_physicsNode addChild:_loadedBullet];
////        
//        _slingshotSpring = [CCPhysicsJoint connectedSpringJointWithBodyA:_slingshotStart.physicsBody
//                                                                   bodyB:_loadedBullet.physicsBody
//                                                                 anchorA:ccp(30,30)
//                                                                 anchorB:ccp(0,0)
//                                                              restLength:0
//                                                               stiffness:5.f
//                                                                 damping:0.f];
////
////        _dragSpring = [CCPhysicsJoint connectedSpringJointWithBodyA:_currentBullet.physicsBody
////                                                                   bodyB:_dragNode.physicsBody
////                                                                 anchorA:ccp(0,0)
////                                                                 anchorB:ccp(0,0)
////                                                               restLength:0.f
////                                                               stiffness:10000.f
////                                                                 damping:150.f];
//        _dragSpring = [CCPhysicsJoint connectedPivotJointWithBodyA:_loadedBullet.physicsBody
//                                                             bodyB:_dragNode.physicsBody
//                                                           anchorA:ccp(0,0)];
//        
//    }
//    
}

- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    // whenever touches move, update the position of the mouseJointNode to the touch position
    CGPoint touchLocation = [touch locationInNode:_physicsNode];
    _dragNode.position = touchLocation;
}



-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self releaseSlingshot];
}

-(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self releaseSlingshot];
}

-(void)releaseSlingshot {
    if(_dragSpring != nil ) {
        [_dragSpring invalidate];
        _dragSpring = nil;
    }
}

-(void)releaseBullet {
    if(_slingshotSpring != nil) {
        [_slingshotSpring invalidate];
        _slingshotSpring = nil;
    }
    if(_dragSpring != nil ) {
        [_dragSpring invalidate];
        _dragSpring = nil;
    }
    
    _loadedBullet.released = YES;
}




- (void)update:(CCTime)delta
{
    //check if the loaded bullet exists; if does, check if it's position calls for us to release the bullet from spring
    if (_loadedBullet != nil) {
        //NSLog(@"Loaded bullet pos x/y: %.2f/%.2f", _loadedBullet.position.x, _loadedBullet.position.y);
        if(_loadedBullet.position.y > _slingshotStart.position.y + 15.f && _dragSpring == nil) {
            [self releaseBullet];
            _loadedBullet.prevPosition = _loadedBullet.position;
            CCColor* color = [CCColor colorWithCcColor4f:ccc4f(1.0, 0.0, 0.0, 1.0)];
            CCActionTintTo * colorAction = [CCActionTintTo actionWithDuration:2.0 color:color];
            [_loadedBullet runAction:colorAction];
            [_currentBullets addObject:_loadedBullet];
            _loadedBullet = nil;
        }
    }
    
    [self updateBulletsWithTime:delta];
    
    //CCLOG(@"n bullets: %i", [_currentBullets count]);
    //CCLOG(@"delta: %f", delta);
}

-(void)updateBulletsWithTime:(CCTime) delta {
    for (int i = 0; i < [_currentBullets count]; i++) {
        Bullet * currentBullet = _currentBullets[i];
        currentBullet.life -= delta;
        //[self emitSmokeTrailForBullet:currentBullet];
        if(currentBullet.life < 0.0) {
            [self bulletExplosionWithBullet:currentBullet];
        }
        currentBullet.prevPosition = currentBullet.position;
    }
}

-(void)bulletExplosionWithBullet:(Bullet*)bullet {
    if(bullet != nil) {
        CGPoint explosionPosition = bullet.position;
        [_currentBullets removeObject: bullet];
        [bullet removeFromParent];
        CCParticleSystem * explosion = [CCBReader load:@"BulletExplosion"];
        [explosion setAutoRemoveOnFinish:YES];
        explosion.position = explosionPosition;
        [_physicsNode addChild:explosion];
        explosion.physicsBody.collisionType = @"Explosion";
    }
}

-(void)emitSmokeTrailForBullet:(Bullet *)bullet {
    CCNode * smoke = [CCBReader load:@"SmokeTrail"];
    //[smoke setAutoRemoveOnFinish:YES];
    [self addChild:smoke];
    smoke.position = bullet.prevPosition;
}

- (CGFloat)pythagLengthWithSideX:(CGFloat)x sideY:(CGFloat)y {
    
    return (CGFloat) sqrt(pow(x, 2.0) + pow(y, 2.0));
}

- (void)addMonster:(CCTime) dt
{
    //NSLog(@"addMonster!");
    CCNode *monster = [CCBReader load:@"FirstMob"];
    
    // 1
    int minX = monster.contentSize.width / 2;
    int maxX = self.contentSize.width - monster.contentSize.width / 2;
    int rangeX = maxX - minX;
    int randomStartX = (arc4random() % rangeX) + minX;
    int randomEndX = (arc4random() % rangeX) + minX;
    
    //NSLog(@"start and end positions: %i/%i", randomStartX, randomEndX);
    // 2
    monster.position = CGPointMake(randomStartX, self.contentSize.height + monster.contentSize.height/2);
    
    monster.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, monster.contentSize} cornerRadius:0];
    monster.physicsBody.collisionGroup = @"monsterGroup";
    monster.physicsBody.collisionType = @"monsterCollision";
    monster.physicsBody.affectedByGravity = NO;
    monster.physicsBody.allowsRotation = NO;
    [_physicsNode addChild:monster];
    
    // 3
    int minDuration = 15.0;
    int maxDuration = 17.0;
    int rangeDuration = maxDuration - minDuration;
    int randomDuration = (arc4random() % rangeDuration) + minDuration;
    
    // 4
    CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(randomEndX, -monster.contentSize.height/2)];
    CCAction *actionRemove = [CCActionRemove action];
    [monster runAction:[CCActionSequence actionWithArray:@[actionMove, actionRemove]]];
}



//just a tester function for loading bullets
-(void) shootBullet:(CGPoint) direction {
    CCNode* bullet = [CCBReader load:@"Bullet"];
    
    bullet.position = _slingshotStart.position;
    
    //[bullet.physicsBody setCollisionMask:@[]];
    [_physicsNode addChild:bullet];
    
    //CGPoint launchDirection = ccp(0,1);
    CGPoint force = ccpMult(direction, 8000);
    [bullet.physicsBody applyForce:force];
}

//COLLISION HANDLING
//you can name the parameter for this method 'seal' due to late binding in objective C
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Bullet:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    CCLOG(@"collision with bullet!");
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Explosion:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    //CCLOG(@"collision with EXPLOSION!");
    if([nodeB isKindOfClass:[FirstMob class]]) {
        FirstMob * mob = nodeB;
        if(!mob.onFire) {
            CCLOG(@"mob is now on fire!");
            mob.onFire = YES;
            [self setMobOnFire:mob];
        }
    }
}

-(void)setMobOnFire:(FirstMob *)mob {
    int minX = mob.position.x - 40;
    int maxX = mob.position.x + 40;
    int minY = mob.position.y - 20;
    int maxY = mob.position.y + 20;
    int rangeX = maxX - minX;
    int rangeY = maxY - minY;
    NSMutableArray * actionArray = [[NSMutableArray alloc] init];
    //NSMutableArray * actionArrayB = [[NSMutableArray alloc] init];
    for(int i = 0; i < 6; i++) {
        int randomX = arc4random() % rangeX + minX;
        int randomY = arc4random() % rangeY + minY;
        CCActionMoveTo * moveAction = [CCActionMoveTo actionWithDuration:0.4 position:ccp(randomX, randomY)];
        //CCActionMoveTo * moveActionB = [CCActionMoveTo actionWithDuration:0.4 position:ccp(randomX, randomY)];
        [actionArray addObject:moveAction];
        //[actionArrayB addObject:moveActionB];
    }
    CCActionFadeOut * fadeAction = [CCActionFadeOut actionWithDuration:0.4];
    //CCActionFadeOut * fadeActionB = [CCActionFadeOut actionWithDuration:0.4];
    [actionArray addObject:fadeAction];
    //[actionArrayB addObject:fadeActionB];
    [actionArray addObject:[CCActionRemove action]];
    //[actionArrayB addObject:[CCActionRemove action]];
    CCActionSequence * sequenceAction = [CCActionSequence actionWithArray:actionArray];
    //CCActionSequence * sequenceActionB = [CCActionSequence actionWithArray:actionArrayB];
    CCParticleSystem * fire = [CCBReader load:@"OnFire"];
    [mob addChild:fire];
    fire.position = ccp(17.f,0.f);
    //make it so this mob can set other mobs on fire
    mob.physicsBody.collisionType = @"Explosion";
    mob.physicsBody.collisionGroup = @"";
    [mob runAction:sequenceAction];
    //[fire runAction:sequenceActionB];
}

@end
