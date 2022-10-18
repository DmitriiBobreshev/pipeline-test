//
//  GVEnemy.h
//  Gravity
//
//  Created by Meirav Shapira on 10/28/15.
//  Copyright © 2015 NOVN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GVEnemyType)
{
    GVEnemyTypeHole
};

@interface GVEnemy : NSObject

-(instancetype)initWithLocation:(CGFloat) xLocation;

@property (nonatomic,assign,readonly) CGFloat xLocation;

@end
