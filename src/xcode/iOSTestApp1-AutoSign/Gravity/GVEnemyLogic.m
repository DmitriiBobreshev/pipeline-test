//
//  GVEnemyLogic.m
//  Gravity
//
//  Created by Meirav Shapira on 10/28/15.
//  Copyright © 2015 NOVN. All rights reserved.
//

#import "GVEnemyLogic.h"
#import "GVEnemy.h"
#import "GVHole.h"
#import "GVSprite.h"

@interface GVEnemyLogic ()

@property (nonatomic,strong) NSMutableArray * bottomeEnemies;
@property (nonatomic,strong) NSMutableArray * topEnemies;
@property (nonatomic,assign) NSUInteger currentBottmEnemyIndex;
@property (nonatomic,assign) NSUInteger currentTopEnemyIndex;


@end
@implementation GVEnemyLogic

+(instancetype)enemyLogicInstance{
    
    static GVEnemyLogic *enemyLogicInstance = nil;

    if(enemyLogicInstance == nil){
        @synchronized(self) {
            if(enemyLogicInstance == nil){
                enemyLogicInstance = [[GVEnemyLogic alloc]init];
            }
            
            enemyLogicInstance.bottomeEnemies = [NSMutableArray array];
            
            GVEnemy * holeEnemy = [[GVHole alloc]initWithLocation:1424 - 50 andWidth:1648-1424 - 50];
            [enemyLogicInstance.bottomeEnemies addObject:holeEnemy];
            
            GVEnemy * holeEnemy2 = [[GVHole alloc]initWithLocation:2033 - 50 andWidth:2174-2033 -50];
            [enemyLogicInstance.bottomeEnemies addObject:holeEnemy2];
            
            GVEnemy * holeEnemy3 = [[GVHole alloc]initWithLocation:3584-50 andWidth:3757-3584 - 50];
            [enemyLogicInstance.bottomeEnemies addObject:holeEnemy3];
            
            GVEnemy * holeEnemy4 = [[GVHole alloc]initWithLocation:6129 -50 andWidth:6255-6129 - 50];
            [enemyLogicInstance.bottomeEnemies addObject:holeEnemy4];
            
            GVEnemy * holeEnemy5 = [[GVHole alloc]initWithLocation:7681 - 50 andWidth:7775-7681 - 50];
            [enemyLogicInstance.bottomeEnemies addObject:holeEnemy5];




            enemyLogicInstance.currentBottmEnemyIndex = 0;
            
            enemyLogicInstance.topEnemies = [NSMutableArray array];
            
            GVEnemy * holeEnemyTop = [[GVHole alloc]initWithLocation:638  andWidth:926-638 ];
            [enemyLogicInstance.topEnemies addObject:holeEnemyTop];
            
            GVEnemy * holeEnemyTop2 = [[GVHole alloc]initWithLocation:2658  andWidth:3070-2658 ];
            [enemyLogicInstance.topEnemies addObject:holeEnemyTop2];
            
            GVEnemy * holeEnemyTop3 = [[GVHole alloc]initWithLocation:4445 andWidth:4559-4445 ];
            [enemyLogicInstance.topEnemies addObject:holeEnemyTop3];

            GVEnemy * holeEnemyTop4 = [[GVHole alloc]initWithLocation:5344  andWidth:5533-5344];
            [enemyLogicInstance.topEnemies addObject:holeEnemyTop4];

            GVEnemy * holeEnemyTop5 = [[GVHole alloc]initWithLocation:6832   andWidth:7136-6832];
            [enemyLogicInstance.topEnemies addObject:holeEnemyTop5];

        
            enemyLogicInstance.currentTopEnemyIndex = 0;
        }
    }
    
    return enemyLogicInstance;
}

-(void)cleraData{
    
}

-(BOOL)isEncounteredFixedEnemy:(GVSprite *)walker movingEnemy:(GVSprite *)movingEnemy isBottomWalker:(BOOL)isBottomWalker{
    
    CGFloat enemyXLocation = movingEnemy.imageView.frame.origin.x;
    CGFloat walkerXEndLocatoin = walker.imageView.frame.origin.x + walker.imageView.frame.size.width;
    CGFloat enemyXendLocation = movingEnemy.imageView.frame.origin.x + movingEnemy.imageView.frame.size.width;
    CGFloat walkerXLocation = walker.imageView.frame.origin.x ;


    
    CGFloat enemyYLocation = movingEnemy.imageView.frame.origin.y;
    CGFloat walkerYLocation = walker.imageView.frame.origin.y ;
    CGFloat enemyYendLocation = movingEnemy.imageView.frame.origin.y - movingEnemy.imageView.frame.size.height;
    CGFloat walkerYEndLocatoin = walker.imageView.frame.origin.y - walker.imageView.frame.size.height;


    if((enemyXLocation <= walkerXEndLocatoin && walkerXEndLocatoin <= enemyXendLocation) || (enemyXLocation <= walkerXLocation && enemyXendLocation >= walkerXLocation)){
        if(isBottomWalker){
            if(walkerYLocation <= enemyYLocation){
                return YES;
            }
        }
        else{
            if(walkerYLocation >= enemyYLocation){
                    return YES;
                }
        }
    }
    return NO;
}

-(BOOL)isEncounteredMovingEnemy:(GVSprite *)walker movingEnemy:(GVSprite *)movingEnemy isBottomWalker:(BOOL)isBottomWalker{
    
    CGFloat enemyXLocation = movingEnemy.imageView.frame.origin.x;
    CGFloat walkerXLocation = walker.imageView.frame.origin.x ;
    CGFloat enemyXendLocation = movingEnemy.imageView.frame.origin.x + movingEnemy.imageView.frame.size.width;
    CGFloat walkerXEndLocatoin = walker.imageView.frame.origin.x + walker.imageView.frame.size.width;
    
    CGFloat enemyYLocation = movingEnemy.imageView.frame.origin.y;
    CGFloat walkerYLocation = walker.imageView.frame.origin.y ;
    CGFloat enemyYendLocation = movingEnemy.imageView.frame.origin.y - movingEnemy.imageView.frame.size.height;
    CGFloat walkerYEndLocatoin = walker.imageView.frame.origin.y - walker.imageView.frame.size.height;
    
    if((enemyXLocation > walkerXLocation && enemyXLocation < walkerXEndLocatoin)|| (enemyXendLocation > walkerXLocation &&  enemyXendLocation < walkerXEndLocatoin))
       {
           if(isBottomWalker){
               if (enemyYLocation < walkerYLocation && enemyYLocation > walkerYEndLocatoin){
                return YES;
               }
           }
           else if(enemyYLocation > walkerYLocation && enemyYLocation < walkerYEndLocatoin * (-1)){
               return YES;
           }
       }
    
    return NO;
}

-(void)clearData{
    
    _currentBottmEnemyIndex = 0;
    _currentTopEnemyIndex = 0;
    
}
-(BOOL)isEncounteredStaticEnemy:(CGFloat)xLocation isBottom:(BOOL)isBottom yLocation:(CGFloat)yLocation{

    GVEnemy * currentEnemy = [_bottomeEnemies objectAtIndex:_currentBottmEnemyIndex];
    
    if(!isBottom){
        currentEnemy = [_topEnemies objectAtIndex:_currentTopEnemyIndex];
    }
    
    CGFloat width = currentEnemy.xLocation;
    
    if([currentEnemy isKindOfClass:[GVHole class]]){
        width  += ((GVHole*)currentEnemy).width;
    }
    
    if(xLocation > currentEnemy.xLocation &&  xLocation < width){
        if(isBottom &&  yLocation == kBottomLine){
            return YES;
        }
        else if(!isBottom && yLocation == kTopLine){
            return  YES;
        }
    }
    
    if(xLocation > width){ //walker passed this hole
        
        if(isBottom){
            _currentBottmEnemyIndex++;
            if(_currentBottmEnemyIndex == _bottomeEnemies.count){
                _currentBottmEnemyIndex = 0;
            }
        }
        else{
            _currentTopEnemyIndex++;
            if(_currentTopEnemyIndex == _topEnemies.count){
                _currentTopEnemyIndex = 0;
            }
        }
    }
    
    return NO;
}

@end
