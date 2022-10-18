//
//  ViewController.h
//  Gravity
//
//  Created by Meirav Shapira on 10/27/15.
//  Copyright © 2015 NOVN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVGameSurface.h"



@interface ViewController : UIViewController <GVGameSurfaceDelegate>

-(void)changeGravity:(void (^)(BOOL isFinished))completion;

@end

