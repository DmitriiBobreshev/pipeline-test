//
//  GVHole.h
//  Gravity
//
//  Created by Meirav Shapira on 10/28/15.
//  Copyright © 2015 NOVN. All rights reserved.
//

#import "GVEnemy.h"

@interface GVHole : GVEnemy

@property (nonatomic,assign,readonly) CGFloat width;

-(instancetype)initWithLocation:(CGFloat) xLocation andWidth:(CGFloat)width;


@end
