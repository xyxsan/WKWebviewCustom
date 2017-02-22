//
//  deallocView.m
//  WKWebviewCustom
//
//  Created by apple on 17/2/22.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import "deallocView.h"

@implementation deallocView
// 测试自定义view 会不会执行dealloc方法，事实证明会执行的
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)dealloc{
    
}
@end
