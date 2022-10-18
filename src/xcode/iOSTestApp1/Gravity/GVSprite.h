//
//  GVSprite.h
//  Gravity
//
//  Created by Meirav Shapira on 10/27/15.
//  Copyright © 2015 NOVN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface GVSprite : NSObject

@property (nonatomic,assign) BOOL loops;
@property (nonatomic,assign) CGPoint position;
@property (nonatomic,assign) float speed;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIImageView * secondaryView;



-(void)update:(double)timeDiff;
-(instancetype)initWithImage:(UIImageView *) img;

@end
