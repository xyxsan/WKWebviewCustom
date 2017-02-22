//
//  CommenWebView.m
//  WKWebviewCustom
//
//  Created by apple on 17/2/22.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import "CommenWebView.h"
#import <WebKit/WebKit.h>

/**
 @brief WeakScriptMessageDelegate目的是为了能在自定义webview中执行dealloc方法
 */
@interface WeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end

@implementation WeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate
{
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

- (void)dealloc{
    
}
@end

@interface CommenWebView()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKWebViewConfiguration *configuration;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSString *urlString;

@property (nonatomic, copy) void(^completionHandler)(id object);
@property (nonatomic, strong) UIViewController *fromVC;

@property (nonatomic, strong) NSString *methodName;

@end
@implementation CommenWebView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self loadSubviews];
    }
    return self;
}

- (void)loadSubviews{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]init];
    configuration.preferences = [[WKPreferences alloc]init];
    configuration.preferences.minimumFontSize = 10.f;
    self.configuration = configuration;
    configuration.processPool = [[WKProcessPool alloc]init];
    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) configuration:configuration];
    self.webView.scrollView.maximumZoomScale = 1.f;
    self.webView.scrollView.minimumZoomScale = 1.f;
    self.webView.scrollView.zoomScale = 1.f;
    self.webView.backgroundColor = [UIColor yellowColor];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self addSubview:self.webView];
    
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.frame = self.bounds;
    self.progressView.backgroundColor = [UIColor redColor];
    [self addSubview:self.progressView];
    // 添加KVO监听进度条
    [self.webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:nil];

}

- (void)requestUrlString:(NSString *)urlString{
    self.urlString = urlString;
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.f];
    [self.webView loadRequest:request];

}

- (void)loadLocalHTMLPathResource:(NSString *)name
                           ofType:(NSString *)ext{
    
    [self loadLocalHTMLPathResource:name ofType:ext fromVC:nil completionHandler:nil];
}

- (void)loadLocalHTMLPathResource:(NSString *)name
                           ofType:(NSString *)ext
                           fromVC:(UIViewController *)fromVC
                completionHandler:(void(^)(id object))completionHandler{
    
    self.fromVC = fromVC;
    NSURL *path = [[NSBundle mainBundle] URLForResource:name withExtension:ext];
    [self.webView loadRequest:[NSURLRequest requestWithURL:path]];
    if (completionHandler) {
        self.completionHandler = completionHandler;
    }
}

- (void)evaluateJavaScriptMethod:(NSString *)methodName
                      parameter1:(NSString *)parameter1
                      parameter2:(NSString *)parameter2
               completionHandler:(void(^)(id response, NSError *error))completionHandler{
    
    NSString *jsMethod = [NSString stringWithFormat:@"%@('%@','%@')",methodName,parameter1,parameter2];
    [self.webView evaluateJavaScript:jsMethod completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if (completionHandler) {
            completionHandler(response,error);
        }
    }];
}

- (void)evaluteObjectiveCMethod:(NSString *)methodName
              completionHandler:(void(^)(id object))completionHandler{
    
    self.methodName = methodName;
    WKUserContentController * userContentController =  self.configuration.userContentController;
    [userContentController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:methodName];
    if (completionHandler) {
        self.completionHandler = completionHandler;
    }

}


#pragma mark - observe progressView
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.webView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.webView.estimatedProgress animated:animated];
        
        // Once complete, fade out UIProgressView
        if(self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    self.progressView.hidden = NO;

}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    if (error) {
        NSLog(@"error = %@",error);
    }
}
#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
        self.completionHandler(@"dosometing");
    }]];
    
    [self.fromVC presentViewController:alert animated:YES completion:^{
        self.fromVC = nil;
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"confirm" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
        self.completionHandler(@"dosometing");
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
        self.completionHandler(@"dosometing");
    }]];
    [self.fromVC presentViewController:alert animated:YES completion:^{
        self.fromVC = nil;
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"textinput" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
        self.completionHandler(@"dosometing");
    }]];
    
    [self.fromVC presentViewController:alert animated:YES completion:^{
        self.fromVC = nil;
    }];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.name isEqualToString:self.methodName]) {
        self.completionHandler(message.body);
    }
}
#pragma mark - removc observe
- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:self.methodName];
    [self.webView setNavigationDelegate:nil];
    [self.webView setUIDelegate:nil];


}
@end
