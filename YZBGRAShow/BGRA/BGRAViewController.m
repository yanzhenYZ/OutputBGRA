//
//  BGRAViewController.m
//  YZBGRAShow
//
//  Created by yanzhen on 2021/3/1.
//

#import "BGRAViewController.h"

@interface BGRAViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *mainPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *showPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *outputPlayer;

@end

@implementation BGRAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UI
- (IBAction)exitVideo:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

@end
