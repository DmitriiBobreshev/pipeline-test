//
//  GVHole.m
//  Gravity
//
//  Created by Meirav Shapira on 10/28/15.
//  Copyright © 2015 NOVN. All rights reserved.
//

#import "GVHole.h"

@implementation GVHole

-(instancetype)initWithLocation:(CGFloat) xLocation andWidth:(CGFloat)width{
    
    self= [super initWithLocation:xLocation];
    
    if(self){
        _width = width;
    }
    
    return  self;
    
}


@end
