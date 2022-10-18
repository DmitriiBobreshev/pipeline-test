//
//  GVEnemyLogic.h
//  Gravity
//
//  Created by Meirav Shapira on 10/28/15.
//  Copyright © 2015 NOVN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GVSprite.h"

static const CGFloat kTopLine = 30;
static const CGFloat kBottomLine = 400;

@interface GVEnemyLogic : NSObject

+(instancetype)enemyLogicInstance;

-(BOOL)isEncounteredStaticEnemy:(CGFloat)xLocation isBottom:(BOOL)isBottom yLocation:(CGFloat)yLocation;
-(BOOL)isEncounteredMovingEnemy:(GVSprite *)walker movingEnemy:(GVSprite *)movingEnemy isBottomWalker:(BOOL)isBottomWalker;
-(BOOL)isEncounteredFixedEnemy:(GVSprite *)walker movingEnemy:(GVSprite *)movingEnemy isBottomWalker:(BOOL)isBottomWalker;
-(void)clearData;

@end
