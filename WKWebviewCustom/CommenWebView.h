//
//  CommenWebView.h
//  WKWebviewCustom
//
//  Created by apple on 17/2/22.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommenWebView : UIView

- (void)requestUrlString:(NSString *)urlString;

/**
 @brief 加载本地HTML
 */
- (void)loadLocalHTMLPathResource:(NSString *)name
                           ofType:(NSString *)ext;
/**
 @brief 加载本地HTML,拦截js的alert、confirm和prompt,并调用oc方法
 */
- (void)loadLocalHTMLPathResource:(NSString *)name
                           ofType:(NSString *)ext
                           fromVC:(UIViewController *)fromVC
                completionHandler:(void(^)(id object))completionHandler;

/**
 @brief oc调用js方法

 @param methodName js方法名
 @param parameter1 参数1
 @param parameter2 参数2
 @param completionHandler 回调信息
 */
- (void)evaluateJavaScriptMethod:(NSString *)methodName
                      parameter1:(NSString *)parameter1
                      parameter2:(NSString *)parameter2
               completionHandler:(void(^)(id response, NSError *error))completionHandler;

/**
 @brief js调用oc方法

 @param methodName oc方法名
 @param completionHandler 回调信息
 */
- (void)evaluteObjectiveCMethod:(NSString *)methodName
              completionHandler:(void(^)(id object))
                  completionHandler;

@end
