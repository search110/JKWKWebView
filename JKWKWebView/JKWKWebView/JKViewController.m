//
//  JKViewController.m
//  JKWKWebView
//
//  Created by XHKS on 2019/7/22.
//  Copyright © 2019 XHKS. All rights reserved.
//

#import "JKViewController.h"
#import <WebKit/WebKit.h>

@interface JKViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
// bg
@property(nullable,weak,nonatomic)UIView * bg;
// wkWebView
@property(nullable,weak,nonatomic)WKWebView * wkWebView;

@end

@implementation JKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor blackColor];
    UIView * bg = [UIView new];
    _bg = bg;
    bg.frame = self.view.bounds;
    bg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bg];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"WKJS"
                                                          ofType:@"html"];
    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    [self.wkWebView loadHTMLString:htmlCont baseURL:baseURL];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 用于处理JS调用原生的代理
    [self.wkWebView.configuration.userContentController addScriptMessageHandler:self name:@"jsToOcNoPrams"];
    [self.wkWebView.configuration.userContentController addScriptMessageHandler:self name:@"jsToOcWithPrams"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"jsToOcNoPrams"];
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"jsToOcWithPrams"];
    
    
}


-(WKWebView*)wkWebView
{
    if (!_wkWebView){
        WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
        // 网页设置
        WKPreferences * preference = [[WKPreferences alloc]init];
        preference.minimumFontSize = 40.f;
        preference.javaScriptEnabled = YES;
        preference.javaScriptCanOpenWindowsAutomatically = YES;
        configuration.preferences = preference;
        // 这个类主要用来做native与JavaScript的交互管理
        WKUserContentController * contentVC = [[WKUserContentController alloc]init];
        // js注入方法,注入一个alert方法,弹出一个对话框。
        NSString *javaScriptSource = @"alert(\"WKUserScript注入js\");";
        // 这个类就是用来创建注入JS的类(可以预先添加JS方法，供其他人员调用)
        // forMainFrameOnly:NO(全局窗口)，yes（只限主窗口)
        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:javaScriptSource injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [contentVC addUserScript:userScript];
        configuration.userContentController = contentVC;
        // 显示WKWebView
        WKWebView * wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
        wkWebView.UIDelegate = self;
        //wkWebView.navigationDelegate = self;
        _wkWebView = wkWebView;
        [self.bg addSubview:wkWebView];
    }
    return _wkWebView;
}

#pragma mark --- WKUIDelegate method
// 注入JS方法、供其他的开发人员调用
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"%s",__FUNCTION__);
    // 确定按钮
    UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    // alert弹出框
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark --- WKScriptMessageHandler JS调用OC方法
// 遵守WKScriptMessageHandler协议，代理是由WKUserContentControl设置
// 协议类专门用来处理监听JavaScript方法从而调用原生OC方法
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    // message中含有两个参数name和body
    NSLog(@"name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
    // 用message.body获得JS传出的参数体
    // 用message.body获得JS传出的参数体
    NSDictionary * parameter = message.body;
    if ([message.name isEqualToString:@"jsToOcNoPrams"]) {
    // 没有参数
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"js调用到了oc" message:@"不带参数" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }])];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if ([message.name isEqualToString:@"jsToOcWithPrams"]){
    // 有参数
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"js调用到了oc" message:parameter[@"params"] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }])];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
