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
    CCNode *_slingshotStartA;
    CCNode *_slingshotStartB;
    //spring is created between start and pouch when user drags
    CCPhysicsJoint *_slingshotSpringA;
    CCPhysicsJoint *_slingshotSpringB;
    //glue to keep bullet attached to sling until release
    CCPhysicsJoint *_bulletGlue;
    CCNode *_slingshotPouch;
    CCNode *_dragNode;
    CCPhysicsJoint *_dragSpring;
    
    Bullet *_currentBullet;
    
}

-(void) didLoadFromCCB {
    // tell this scene to accept touches
    
    CCLOG(@"didloadgameplay!");
    self.userInteractionEnabled = TRUE;
    
    _physicsNode.debugDraw = TRUE;
    
    [_slingshotStartA.physicsBody setCollisionType:@"Slingshot"];
    [_slingshotStartB.physicsBody setCollisionType:@"Slingshot"];
    [_slingshotPouch.physicsBody setCollisionType:@"Slingshot"];
    [_dragNode.physicsBody setCollisionMask:@[]];
    
    _slingshotSpringA = [CCPhysicsJoint connectedSpringJointWithBodyA:_slingshotPouch.physicsBody
                                                               bodyB:_slingshotStartA.physicsBody
                                                             anchorA:ccp(0,0)
                                                             anchorB:ccp(0,0)
                                                          restLength:20.f
                                                           stiffness:500.f
                                                             damping:40.f];
    _slingshotSpringB = [CCPhysicsJoint connectedSpringJointWithBodyA:_slingshotPouch.physicsBody
                                                                bodyB:_slingshotStartB.physicsBody
                                                              anchorA:ccp(30,0)
                                                              anchorB:ccp(0,0)
                                                           restLength:20.f
                                                            stiffness:500.f
                                                              damping:40.f];

}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    //[self shootBullet];
    CGPoint touchLocation = [touch locationInNode:_physicsNode];
    CCLOG(@"here is the location of the touch: x:%.2f y: %.2f", touchLocation.x, touchLocation.y);
    if(CGRectContainsPoint([_slingshotPouch boundingBox], touchLocation)) {
        _dragNode.position = touchLocation;
        _dragSpring = [CCPhysicsJoint connectedSpringJointWithBodyA:_slingshotPouch.physicsBody
                                                                   bodyB:_dragNode.physicsBody
                                                                 anchorA:ccp(0,0)
                                                                 anchorB:ccp(0,0)
                                                               restLength:0.f
                                                               stiffness:3000.f
                                                                 damping:150.f];

    
        //position the bullet on the pouch
        //_currentBullet = [CCBReader load:@"Bullet"];
        //CGPoint bulletPosition = [_slingshotPouch convertToWorldSpace:ccp(0,6)];
        //_currentBullet.position = [_physicsNode convertToNodeSpace:bulletPosition];
        
        //add current bullet, and don't let it collide with slingshot
        //[_physicsNode addChild:_currentBullet];
        //[_currentBullet.physicsBody setCollisionType:@"Slingshot"];
        
        //keep the bullet attached to the sling
        //_bulletGlue = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentBullet.physicsBody
        //                                                     bodyB:_slingshotPouch.physicsBody
        //                                                   anchorA:_currentBullet.anchorPointInPoints];
    }
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
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


//just a tester function for loading bullets
-(void) shootBullet {
    CCNode* bullet = [CCBReader load:@"Bullet"];
    
    bullet.position = _slingshotStartA.position;
    
    //testing if
    [bullet.physicsBody setCollisionMask:@[]];
    [_physicsNode addChild:bullet];
    
    CGPoint launchDirection = ccp(0,1);
    CGPoint force = ccpMult(launchDirection, 8000);
    [bullet.physicsBody applyForce:force];
}

@end
