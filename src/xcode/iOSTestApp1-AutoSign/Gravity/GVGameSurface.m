//
//  GVGameSurface.m
//  Gravity
//
//  Created by Meirav Shapira on 10/27/15.
//  Copyright © 2015 NOVN. All rights reserved.
//

#import "GVGameSurface.h"


@interface GVGameSurface ()

@property (nonatomic,strong) NSMutableArray * sprites;

@end

@implementation GVGameSurface

-(instancetype)init{
    
    self = [super init];
    
    if(self){
        
        _sprites = [NSMutableArray array];
        
    }
    
    return self;
}


-(void)addSprite:(GVSprite *)sprite toView:(UIView *)view{
    
    [_sprites addObject:sprite];
    [view addSubview:sprite.imageView];
    if(sprite.loops){
        [view addSubview:sprite.secondaryView];
    }
}

-(void)tick:(double)timeDiff{
    
    for (GVSprite * sprite in _sprites) {
        [sprite update : timeDiff];
    }
}

-(void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event
{
    [self touchBeginRecursive:[[event allTouches] count]];
}

-(void)touchBeginRecursive:(NSUInteger)index{
    if(index == 0){
        return;
    }
    index -=1;

    [_delegate changeGravity:^(BOOL isFinished) {
        [self touchBeginRecursive:index];
    }];
}
@end
