//
//  ViewController.m
//  WKWebviewCustom
//
//  Created by apple on 17/2/22.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import "ViewController.h"
#import "CommenWebView.h"
#import "SecondViewController.h"

@interface ViewController ()
@property (nonatomic, strong) CommenWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CommenWebView *webView = [[CommenWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 2)];
    [webView requestUrlString:@"http:www.baidu.com"];
       [self.view addSubview:webView];
    self.webView = webView;

    
}
- (IBAction)click:(UIButton *)sender {
    SecondViewController *secondVC = [[SecondViewController alloc]init];
    [self presentViewController:secondVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
