//
//  Gameplay.m
//  SlingshotAce
//
//  Created by Kodigo Systems on 6/17/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Bullet.h"

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    
    //box from which the user will draw bullets
    CCNode *_slingshotStart;
    CCNode *_slingshotStartB;
    CCPhysicsJoint *_slingshotSpring;
    CCPhysicsJoint *_slingshotSpringB;
    
    //glue to keep bullet attached to sling until release
    CCNode *_dragNode;
    CCPhysicsJoint *_dragSpring;
    
    Bullet *_currentBullet;
    
}

-(void) didLoadFromCCB {
    // tell this scene to accept touches
    
    CCLOG(@"didloadgameplay!");
    self.userInteractionEnabled = TRUE;
    
    _physicsNode.debugDraw = TRUE;
    
    _physicsNode.collisionDelegate = self;
    
    [_slingshotStart.physicsBody setCollisionMask:@[]];
    [_slingshotStartB.physicsBody setCollisionMask:@[]];
    [_dragNode.physicsBody setCollisionMask:@[]];

}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    //[self shootBullet];
    
    //[self shootBullet];
    CGPoint touchLocation = [touch locationInNode:_physicsNode];
    
    CCLOG(@"here is the location of the touch: x:%.2f y: %.2f", touchLocation.x, touchLocation.y);
    if(CGRectContainsPoint([_slingshotStart boundingBox], touchLocation)) {
        _currentBullet = [CCBReader load:@"Bullet"];
//        
//        _currentBullet = [CCBReader load:@"Bullet"];
        _dragNode.position = touchLocation;
        _currentBullet.position = touchLocation;
        [_physicsNode addChild:_currentBullet];
//        
        _slingshotSpring = [CCPhysicsJoint connectedSpringJointWithBodyA:_slingshotStart.physicsBody
                                                                   bodyB:_currentBullet.physicsBody
                                                                 anchorA:ccp(15,15)
                                                                 anchorB:ccp(0,0)
                                                              restLength:0
                                                               stiffness:500.f
                                                                 damping:40.f];
        _slingshotSpringB = [CCPhysicsJoint connectedSpringJointWithBodyA:_slingshotStartB.physicsBody
                                                                   bodyB:_currentBullet.physicsBody
                                                                 anchorA:ccp(15,15)
                                                                 anchorB:ccp(0,0)
                                                              restLength:0
                                                               stiffness:500.f
                                                                 damping:40.f];
//
        _dragSpring = [CCPhysicsJoint connectedSpringJointWithBodyA:_currentBullet.physicsBody
                                                                   bodyB:_dragNode.physicsBody
                                                                 anchorA:ccp(0,0)
                                                                 anchorB:ccp(0,0)
                                                               restLength:0.f
                                                               stiffness:10000.f
                                                                 damping:150.f];
        
    }
    
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
    //this should actually go in update
    if(_slingshotSpring != nil) {
        [_slingshotSpring invalidate];
        _slingshotSpring = nil;
    }
    
    if(_slingshotSpringB != nil) {
        [_slingshotSpringB invalidate];
        _slingshotSpringB = nil;
    }
}


//just a tester function for loading bullets
-(void) shootBullet {
    CCNode* bullet = [CCBReader load:@"Bullet"];
    
    bullet.position = _slingshotStart.position;
    
    //testing if
    //[bullet.physicsBody setCollisionMask:@[]];
    [_physicsNode addChild:bullet];
    
    CGPoint launchDirection = ccp(0,1);
    CGPoint force = ccpMult(launchDirection, 8000);
    [bullet.physicsBody applyForce:force];
}

//you can name the parameter for this method 'seal' due to late binding in objective C
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Bullet:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    CCLOG(@"collision with bullet!");
    
}

@end
