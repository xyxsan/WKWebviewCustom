//
//  SecondViewController.m
//  WKWebviewCustom
//
//  Created by apple on 17/2/22.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import "SecondViewController.h"
#import "CommenWebView.h"
#import "deallocView.h"

@interface SecondViewController ()
@property (nonatomic, strong) CommenWebView *webView;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    CommenWebView *webView = [[CommenWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 2)];
    [webView loadLocalHTMLPathResource:@"index" ofType:@"html"];
    __weak __typeof__(self) weakself = self;
    [webView evaluteObjectiveCMethod:@"showMobile" completionHandler:^(id object) {
//        __strong __typeof__(weakself) strongSelf = weakself;
        [weakself showMsg:@"object暂时没数据"];
    }];
    [self.view addSubview:webView];
    self.webView = webView;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, self.view.frame.size.height - 60, 100, 50);
    [button setTitle:@"evalute" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blackColor];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitle:@"back" forState:UIControlStateNormal];
    backButton.frame = CGRectMake(self.view.frame.size.width - 100, self.view.frame.size.height - 60, 100, 50);
    backButton.backgroundColor = [UIColor blackColor];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    deallocView *dealloc = [[deallocView alloc]init];
    dealloc.frame = CGRectMake(0, 0, 10, 10);
    dealloc.backgroundColor = [UIColor redColor];
    [self.view addSubview:dealloc];
}

- (void)click{
    [self.webView evaluateJavaScriptMethod:@"alertSendMsg" parameter1:@"18870707070" parameter2:@"周末爬山真是件愉快的事情" completionHandler:^(id response, NSError *error) {
        NSLog(@"response = %@ , error = %@",response,error);
    }];

}
- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)showMsg:(NSString *)msg {
    [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}


- (void)viewDidDisappear:(BOOL)animated{
    self.webView = nil;
}
- (void)dealloc{

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
