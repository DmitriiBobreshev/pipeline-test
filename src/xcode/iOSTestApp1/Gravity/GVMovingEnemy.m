//
//  GVMovingEnemy.m
//  Gravity
//
//  Created by Meirav Shapira on 10/28/15.
//  Copyright © 2015 NOVN. All rights reserved.
//

#import "GVMovingEnemy.h"
#import <stdlib.h>

@interface GVMovingEnemy ()

@property (nonatomic,assign) BOOL isJumpingUp;

@end

@implementation GVMovingEnemy


-(instancetype)initWithImage:(UIImageView *) img{
    
    self = [super initWithImage:img];
    
    if(self){
        _isJumpingUp = YES;
    }
    
    return self;
    
}


-(void)update:(double)timeDiff{
    
    CGFloat upperBound = 20;
    CGFloat bottomBound = 450;
    
    if(super.speed!=0){
        
        CGFloat yPosition;
        
        if(_isJumpingUp){
             yPosition = super.position.y - (super.speed) * timeDiff;
        }
        else{
            yPosition = super.position.y + (super.speed) * timeDiff;
        }

        CGFloat xPosition = super.position.x - (super.speed/4) * timeDiff;

        if(super.position.y <= upperBound){
             yPosition = super.position.y + (super.speed) * timeDiff;
            _isJumpingUp = NO;
        }
        else if(super.position.y >= bottomBound){
            
            if(xPosition < -400){
                xPosition = 400;
                super.speed =  arc4random_uniform(400 - 100 + 1) + 100;

            }
             yPosition = super.position.y - (super.speed) * timeDiff;
            _isJumpingUp = YES;
        }
    
        [super setPosition:CGPointMake(xPosition, yPosition)]; //speed is a pixel of a second
    }

}

@end
