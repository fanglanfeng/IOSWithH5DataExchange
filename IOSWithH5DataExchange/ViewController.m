//
//  ViewController.m
//  IOS与h5交互测试
//
//  Created by admin on 16/4/26.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "ViewController.h"
#import "WebViewJavascriptBridge.h"
#import "NSArray+Log.h"

@interface ViewController ()<UIWebViewDelegate>

@property(nonatomic,strong) WebViewJavascriptBridge *bridge;

@end

@implementation ViewController


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (_bridge) { return; }
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    
    [WebViewJavascriptBridge enableLogging];
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    
    //先注册__这个是当触发JS中操作的时候，会回调到IOS中
    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(@"注册当JS触发事件的时候，回到IOS中");
        NSLog(@"%s,JS传递过来的数据data =%@",__func__,data);
    }];
    
    //这个是初始化js里面需要的操作，可以传递给JS数据，也可以不操作
    //iosPassData  协议号的字段
    [_bridge callHandler:@"testJavascriptHandler" data:@{ @"iosPassData":@"这里可以设置从IOS传递给JS的《初始化》的值【IOS中数据】😊" }];
    [self renderButtons:webView];
    [self loadExamplePage:webView];
}


/**
 *  在IOS界面中创建两个按钮
 *  @param webView 创建的webview
 */
- (void)renderButtons:(UIWebView*)webView {
    
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"在IOS中点击与js进行数据交互" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:callbackButton aboveSubview:webView];
    callbackButton.frame = CGRectMake(10, 400, 200, 35);
    callbackButton.titleLabel.font = font;
    
    UIButton* reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reloadButton setTitle:@"点击重载webView" forState:UIControlStateNormal];
    [reloadButton addTarget:webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:reloadButton aboveSubview:webView];
    reloadButton.frame = CGRectMake(210, 400, 100, 35);
    reloadButton.titleLabel.font = font;
}

/**
 *  触发IOS中的事件通知给JS文件
 */
- (void)callHandler:(id)sender {
    
    /**
     *  iosPassData: 协议好的字段
     *  jsPassData:  协议好的字段
     *  以上两个是分别在IOS中和JS中协议好的方法，需要设置为一样的，方便获取数据
     */
    id data = @{ @"iosPassData": @"这里可以设置从IOS传递给JS的数据_【IOS中数据】😊"};
    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        //response NSDictionary 类型的数据
        NSLog(@"%s,JS返回给IOS的数据内容为:responded%@",__func__, response[@"jsPassData"]);
    }];
}
/**
 *  初始化webview
 */
- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"webViewBridge" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
