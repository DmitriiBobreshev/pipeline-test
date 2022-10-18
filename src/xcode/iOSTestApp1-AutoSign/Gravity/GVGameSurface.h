//
//  GVGameSurface.h
//  Gravity
//
//  Created by Meirav Shapira on 10/27/15.
//  Copyright © 2015 NOVN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVSprite.h"

@protocol GVGameSurfaceDelegate <NSObject>

-(void)changeGravity:(void (^)(BOOL isFinished))completion;

@end

@interface GVGameSurface : UIView


-(void)addSprite:(GVSprite *)sprite toView:(UIView *)view;
-(void)tick:(double)timeDiff;

@property (nonatomic, weak) id<GVGameSurfaceDelegate> delegate;


@end
