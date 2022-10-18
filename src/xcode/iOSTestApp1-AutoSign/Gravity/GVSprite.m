//
//  GVSprite.m
//  Gravity
//
//  Created by Meirav Shapira on 10/27/15.
//  Copyright © 2015 NOVN. All rights reserved.
//

#import "GVSprite.h"

@interface GVSprite ()

//@property (nonatomic,strong) UIImageView * secondaryView;

@end

@implementation GVSprite

-(instancetype)initWithImage:(UIImageView *) img{
    
    self = [super init];
    
    if(self){
        
        _imageView = img;
        _position = CGPointMake(0, 0);
    }
    
    return self;
}


-(void)setLoops:(BOOL)loops{
    _loops = loops;
    
    _secondaryView = [[UIImageView alloc]initWithImage:_imageView.image];
}

-(void)setPosition:(CGPoint)position{
    
    _position = position;
    
    UIImage * img =  _imageView.image;
    
    if(!img){
        img = [_imageView.animationImages objectAtIndex:0];
    }
    
    _imageView.frame = CGRectMake(position.x, position.y, img.size.width, img.size.height);
}



-(void)update:(double)timeDiff{
    
    if(_speed!=0){
        
        [self setPosition:CGPointMake(_position.x - _speed * timeDiff, _position.y)]; //speed is a pixel of a second
        
        if(_position.x < _imageView.image.size.width * (-1)){//finished drawing image
         
            [self setPosition : CGPointMake(_position.x + _imageView.image.size.width, _position.y)];
        }
        
        if(_secondaryView){
            _secondaryView.frame = CGRectMake(_imageView.frame.origin.x + _imageView.image.size.width,
                                              _imageView.frame.origin.y, _imageView.image.size.width, _imageView.image.size.height);
        }
    }
    
}
@end
