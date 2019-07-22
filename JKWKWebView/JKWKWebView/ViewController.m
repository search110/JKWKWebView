//
//  ViewController.m
//  JKWKWebView
//
//  Created by XHKS on 2019/7/19.
//  Copyright © 2019 XHKS. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "JKViewController.h"

@interface ViewController ()<WKUIDelegate,WKScriptMessageHandler>

@property(nullable,weak,nonatomic)WKWebView * webView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, self.view.bounds.size.width, 30.f);
    btn.center = self.view.center;
    [btn setTitle:@"开始WKWebView" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startWKWebView) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [self.view addSubview:btn];
}

-(void)startWKWebView
{
    JKViewController * jk = [[JKViewController alloc]init];
    [self.navigationController pushViewController:jk animated:YES];
}

-(void)loadWKWebViewMethod
{
    NSString *urlStr = @"http://www.chinadaily.com.cn";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
    //OC调用JS  changeColor()是JS方法名，completionHandler是异步回调block
    NSString *jsString = [NSString stringWithFormat:@"changeColor('%@')", @"Js参数"];
    [_webView evaluateJavaScript:jsString completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSLog(@"改变HTML的背景色");
    }];
}


- (WKWebView *)webView
{
    if (!_webView) {
        // WKWebView的配置
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        // 这个类主要用来做native与JavaScript的交互管理
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        [userContentController addScriptMessageHandler:self  name:@"jsToOcNoPrams"];
        [userContentController addScriptMessageHandler:self  name:@"jsToOcWithPrams"];
        // js注入，注入一个alert方法，页面加载完毕弹出一个对话框。
        NSString *javaScriptSource = @"alert(\"WKUserScript注入js\");";
        // NSString *javaScriptSource = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:javaScriptSource injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];// forMainFrameOnly:NO(全局窗口)，yes（只限主窗口）
        [userContentController addUserScript:userScript];
        // 配置userContentController
        configuration.userContentController = userContentController;
        // 显示WKWebView
        WKWebView * wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
        wkWebView.UIDelegate = self;
        _webView = wkWebView;
    }
    return _webView;
}

#pragma mark --- alert 弹出框
// JavaScript页面注入弹框的提示回调处理
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"%s",__FUNCTION__);
    // 确定按钮
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    // alert弹出框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 注意：遵守WKScriptMessageHandler协议，代理是由WKUserContentControl设置
#pragma mark --- WKScriptMessageHandler JS调用OC方法
// 协议类专门用来处理监听JavaScript方法从而调用原生OC方法
// 通过接收JS传出消息的name进行捕捉的回调方法
// window.webkit.messageHandlers.方法名.postMessage(参数);
// 注意：参数不能为空，有且只有一个参数，如不传参数写postMessage(null)
/*
 // 传null
 window.webkit.messageHandlers.方法名.postMessage(null);
 // 传字典
 window.webkit.messageHandlers.方法名.postMessage({name:'小明',gender:'男'});
 // 传字符串
 window.webkit.messageHandlers.方法名.postMessage('hello');
 // 传数组
 window.webkit.messageHandlers.方法名.postMessage(['小明','小华','小亮']);
 */
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    // message中含有两个参数name和body
    NSLog(@"name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
    // 用message.body获得JS传出的参数体
    // 用message.body获得JS传出的参数体
    NSDictionary * parameter = message.body;
    // JS调用OC
    if ([message.name isEqualToString:@"jsToOcNoPrams"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"js调用到了oc" message:@"不带参数" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }])];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if ([message.name isEqualToString:@"jsToOcWithPrams"]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"js调用到了oc" message:parameter[@"params"] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }])];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}



@end
