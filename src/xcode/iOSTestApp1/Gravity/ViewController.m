//
//  ViewController.m
//  Gravity
//
//  Created by Meirav Shapira on 10/27/15.
//  Copyright © 2015 NOVN. All rights reserved.
//

#import "ViewController.h"
#import "GVSprite.h"
#import "GVGameSurface.h"
#import "GVEnemy.h"
#import "GVEnemyLogic.h"
#import "GVMovingEnemy.h"
#import "GVFixedEnemy.h"

@interface ViewController ()

@property (nonatomic,strong) GVGameSurface * surface;
@property (nonatomic,strong) GVSprite * background;
@property (nonatomic,strong) GVSprite * midGround;
@property (nonatomic,strong) GVSprite * foregGround;
@property (nonatomic,strong) UIImageView *imageTop;
@property (nonatomic,strong) UIImageView *imageBottom;

@property (nonatomic,strong) NSTimer * timer;
@property (nonatomic,strong) NSTimer * fuzzyAnimationtimer;

@property (nonatomic,strong) GVSprite * spaceWalker;
@property (nonatomic,strong) UIButton * garvityButton;
@property (nonatomic,assign) double lastGameTime;
@property (nonatomic,strong) GVSprite * fuzzyBall;
@property (nonatomic,strong) UIButton * gameOver;
@property (nonatomic,assign) BOOL isWalkingBottom;
@property (nonatomic,strong) GVSprite * fixedMonster;

@property (nonatomic,assign) BOOL isGameOver;
@property (nonatomic,assign) BOOL isGravityChanging;
@property (nonatomic,assign) BOOL isFallingDown;

-(void)nextFrame;
-(void)gravityButtonClicked:(id)sender;
-(void)animationDone:(id)sender;
-(void)startOver:(id)sender;


@end

@implementation ViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self){
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isWalkingBottom = YES;

    _surface = [[GVGameSurface alloc]init];
    _surface.delegate = self;
    [self.view addSubview:_surface];
    
    UIImageView *backgrounview  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"spaceBackground_big"]];
    _background = [[GVSprite alloc]initWithImage:backgrounview];
    _background.speed = 10;
    _background.loops = YES;
    [_surface addSprite:_background toView:self.view];
    
    UIImageView *midgrounview  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"midground_big"]];
    _midGround = [[GVSprite alloc]initWithImage:midgrounview];
    _midGround.speed = 40;
    _midGround.loops = YES;
    _midGround.position = CGPointMake(0, 0);
    [_surface addSprite:_midGround toView:self.view];
    
    UIImageView *foregroundview  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"foreground_big"]];
    _foregGround = [[GVSprite alloc]initWithImage:foregroundview];
    _foregGround.speed = 280;
    _foregGround.loops = YES;
    _foregGround.position = CGPointMake(0, 0);
    [_surface addSprite:_foregGround toView:self.view];

    UIImageView * spaceWalkerView = [[UIImageView alloc]init];
    NSMutableArray * images = [NSMutableArray array];
    for (int i=1; i<9; i++) {
        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"spaceWalk_test %d",i]];
        [images addObject:image];
    }
    
    spaceWalkerView.animationImages = images;
    spaceWalkerView.animationDuration = 1.0/1.7;
    
    _spaceWalker= [[GVSprite alloc] initWithImage:spaceWalkerView];
    _spaceWalker.position = CGPointMake(25, 400);
    [_surface addSprite:_spaceWalker toView:self.view];
    [spaceWalkerView startAnimating];
    
    UIImageView *fuzzyBallView  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"fuzzy_ball"]];
    _fuzzyBall = [[GVMovingEnemy alloc]initWithImage:fuzzyBallView];
    _fuzzyBall.position = CGPointMake(400, 450);
    _fuzzyBall.speed = 150;
    [_surface addSprite:_fuzzyBall toView:self.view];

    UIImageView *fixedMonster  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"monster"]];
    _fixedMonster = [[GVFixedEnemy alloc]initWithImage:fixedMonster];
    _fixedMonster.position = CGPointMake(1800, 430);
    _fixedMonster.speed = 280;
    [_surface addSprite:_fixedMonster toView:self.view];
    
//    _garvityButton = [[UIButton alloc]init];
//    [_garvityButton setTitle:@"Change Gravity" forState:UIControlStateNormal];
//    [_garvityButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    _garvityButton.backgroundColor = [UIColor whiteColor];
//    [_garvityButton addTarget:self action:@selector(gravityButtonClicked:) forControlEvents:UIControlEventTouchDown];
//    [self.view addSubview:_garvityButton];
    
    _gameOver =[[UIButton alloc]init];
    [_gameOver setBackgroundImage:[UIImage imageNamed:@"gameover"] forState:UIControlStateNormal];
    [_gameOver addTarget:self action:@selector(startOver:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_gameOver];
    _gameOver.hidden = YES;
    
    _lastGameTime = CACurrentMediaTime();
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1/60.0 target:self selector:@selector(nextFrame) userInfo:NULL repeats:YES];
}


-(void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    
    _surface.frame = self.view.frame;
    
//    CGSize textSize = [_garvityButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_garvityButton.titleLabel.font}];
//    _garvityButton.frame = CGRectMake(self.view.frame.size.width/2 - 75 ,525,150,30);
    
    UIImage * gameOverimg =  [UIImage imageNamed:@"gameover"];
    _gameOver.frame = CGRectMake(self.view.frame.size.width/2 - gameOverimg.size.width/2, self.view.frame.size.height/2 - gameOverimg.size.height/2, gameOverimg.size.width, gameOverimg.size.height);
//    CGRect screenRect = [[UIScreen mainScreen] bounds];

}

-(void)startOver:(id)sender{
    
    [_timer invalidate];

    [[GVEnemyLogic enemyLogicInstance]clearData];
    
    _isGravityChanging = NO;
    _isGameOver = NO;
    _isFallingDown = NO;
    
    _background.position = CGPointMake(0, 0);
    _midGround.position = CGPointMake(0, 0);
    _foregGround.position = CGPointMake(0, 0);
    _spaceWalker.position = CGPointMake(25, 400);
    _spaceWalker.imageView.transform = CGAffineTransformIdentity;
    _garvityButton.userInteractionEnabled = YES;
    _spaceWalker.imageView.alpha = 1.0;
    _fixedMonster.position = CGPointMake(1800, 430);
    
    _fuzzyBall.position = CGPointMake(400, 450);
    _foregGround.speed = 280;
    
    _gameOver.hidden= YES;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1/60.0 target:self selector:@selector(nextFrame) userInfo:NULL repeats:YES];

}

-(void)nextFrame{
    
    double currentTime = CACurrentMediaTime();
    
    double timeDiff = currentTime - _lastGameTime;
    _lastGameTime = currentTime;
    
    if(_isFallingDown){
        _foregGround.speed = _foregGround.speed/2;
    }
    
    [_surface tick : timeDiff];
    [_surface setNeedsDisplay];
    
    if(!_isGameOver && !_isGravityChanging){
        BOOL isEncounteredEnemy = [[GVEnemyLogic enemyLogicInstance] isEncounteredStaticEnemy:(_foregGround.imageView.frame.origin.x + 10 ) * -1 isBottom:_isWalkingBottom yLocation:_spaceWalker.imageView.frame.origin.y];
        if(isEncounteredEnemy){
            [self fallDown];
            _isGameOver= YES;
            return;
        }


        isEncounteredEnemy = [[GVEnemyLogic enemyLogicInstance]isEncounteredMovingEnemy:_spaceWalker movingEnemy:_fuzzyBall isBottomWalker:_isWalkingBottom];
        if(!isEncounteredEnemy){
            isEncounteredEnemy =  [[GVEnemyLogic enemyLogicInstance]isEncounteredFixedEnemy:_spaceWalker movingEnemy:_fixedMonster isBottomWalker:_isWalkingBottom];
        }
        if(isEncounteredEnemy){
            [self Boom:_spaceWalker];
            _isGameOver = YES;
            return;
        }
    }
    
}

-(void)Boom:(GVSprite *)walker{
    
    NSMutableArray * poofs = [NSMutableArray array];
    for (int i =1 ; i<6; i++) {
        UIImage * poofImg = [UIImage imageNamed:[NSString stringWithFormat:@"poof %d",i]];
        [poofs addObject:poofImg];
    }
    
    UIImage * poofImg = [UIImage imageNamed:[NSString stringWithFormat:@"poof %d",1]];
    UIImageView * poofimages = [[UIImageView alloc]initWithFrame:CGRectMake(walker.imageView.frame.origin.x - 15, walker.imageView.frame.origin.y, poofImg.size.width, poofImg.size.height)];
    poofimages.animationImages = poofs;
    poofimages.animationRepeatCount = 1;
    poofimages.animationDuration = 0.7;
    [self.view addSubview:poofimages];
    [poofimages startAnimating];
    walker.imageView.alpha = 0;
    [self performSelector:@selector(animationDone:) withObject:nil afterDelay:0.8];
    _garvityButton.userInteractionEnabled = NO;

}

-(void)animationDone:(id)sender{
    
    _gameOver.hidden = NO;
}

-(void)fallDown{
    
    _garvityButton.userInteractionEnabled = NO;
    _isFallingDown = YES;

    [UIView animateWithDuration:1.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        if(!_isWalkingBottom){
            _spaceWalker.imageView.frame = CGRectMake(_spaceWalker.imageView.frame.origin.x  , - _spaceWalker.imageView.frame.size.height , _spaceWalker.imageView.frame.size.width,  _spaceWalker.imageView.frame.size.height);
        }
        else{
            _spaceWalker.imageView.frame = CGRectMake(_spaceWalker.imageView.frame.origin.x , self.view.frame.size.height + 10 , _spaceWalker.imageView.frame.size.width,  _spaceWalker.imageView.frame.size.height);
        }
        
    } completion:^(BOOL finished){
        [self animationDone:self];

    }];
    

}


-(void)changeGravity:(void (^)(BOOL isFinished))completion{

    _isGravityChanging = YES;
    _garvityButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        if(_isWalkingBottom){
            _spaceWalker.imageView.frame = CGRectMake(25,30, _spaceWalker.imageView.frame.size.width, _spaceWalker.imageView.frame.size.height);
            _spaceWalker.imageView.transform = CGAffineTransformMakeScale(1,-1); //Flipped
            _isWalkingBottom = NO;
        }
        else{
            _spaceWalker.imageView.frame = CGRectMake(25,400, _spaceWalker.imageView.frame.size.width, _spaceWalker.imageView.frame.size.height);
            _spaceWalker.imageView.transform = CGAffineTransformMakeScale(1,1); //Flipped
            _isWalkingBottom = YES;

        }
    
    } completion:^(BOOL finished){
        _isGravityChanging = NO;
        _garvityButton.userInteractionEnabled = YES;
        if(completion){
            completion(YES);
        }
    }];
    
    
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)beginFuzyyAnimation
{
    if (_fuzzyAnimationtimer) {
        [_fuzzyAnimationtimer invalidate];
    }
    
    _fuzzyAnimationtimer = [NSTimer scheduledTimerWithTimeInterval:2.45
                                                       target:self
                                                     selector:@selector(fuzzyBallAnimation)
                                                     userInfo:nil
                                                      repeats:YES];
    
    [_fuzzyAnimationtimer fire];
}

- (void)endFuzzyAnimation
{
    [_fuzzyAnimationtimer invalidate];
    _fuzzyAnimationtimer = nil;
}



@end
