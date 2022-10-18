//
//  GVFixedEnemy.m
//  Gravity
//
//  Created by Meirav Shapira on 10/28/15.
//  Copyright © 2015 NOVN. All rights reserved.
//

#import "GVFixedEnemy.h"

@implementation GVFixedEnemy

-(void)update:(double)timeDiff{
    
    if(super.speed!=0){
        
        [self setPosition:CGPointMake(super.position.x - super.speed * timeDiff, super.position.y)]; //speed is a pixel of a second
        
        if(super.position.x < -500 ){//finished drawing image
            
            [self setPosition : CGPointMake(4000, super.position.y)];
        }
    }
}

@end
