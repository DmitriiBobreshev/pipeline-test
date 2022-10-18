//
//  GVEnemy.m
//  Gravity
//
//  Created by Meirav Shapira on 10/28/15.
//  Copyright © 2015 NOVN. All rights reserved.
//

#import "GVEnemy.h"

@implementation GVEnemy

-(instancetype)initWithLocation:(CGFloat) xLocation{
    
    self = [super init];
    
    if(self){
        _xLocation = xLocation;
    }
    
    return self;
}

@end
