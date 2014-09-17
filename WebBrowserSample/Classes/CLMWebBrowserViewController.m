//
//  CLMWebBrowserViewController.m
//  WebBrowserSample
//
//  Created by hirai.yuki on 2014/09/06.
//  Copyright (c) 2014年 Classmethod, Inc. All rights reserved.
//

#import "CLMWebBrowserViewController.h"
#import "CLMBackForwardListViewController.h"
#import <SGNavigationProgress/UINavigationController+SGProgress.h>

static NSString * const InitialURL = @"http://classmethod.jp";

@interface CLMWebBrowserViewController () <WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopButton;

@end

@implementation CLMWebBrowserViewController

#pragma mark - Lifecycle methods

- (void)loadView
{
    [super loadView];
    
    // WKWebView インスタンスの生成
    self.webView = [WKWebView new];
    
    // Auto Layout の設定
    // 画面いっぱいに WKWebView を表示するようにする
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:self.webView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.webView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1.0
                                                              constant:0]
                                ]];
    
    // デリゲートにこのビューコントローラを設定する
    self.webView.navigationDelegate = self;
    
    // フリップでの戻る・進むを有効にする
    self.webView.allowsBackForwardNavigationGestures = YES;
    
    // WKWebView インスタンスを画面に配置する
    [self.view insertSubview:self.webView atIndex:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // WKWebView インスタンスのプロパティの変更を監視する
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
    
    // 初回画面表示時にIntialURLで指定した Web ページを読み込む
    NSURL *url = [NSURL URLWithString:InitialURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)dealloc
{
    // WKWebView インスタンスのプロパティの変更を監視を解除する
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView removeObserver:self forKeyPath:@"loading"];
    [self.webView removeObserver:self forKeyPath:@"canGoBack"];
    [self.webView removeObserver:self forKeyPath:@"canGoForward"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // ツールバー > 戻るボタンにロングタップのジェスチャーを登録する
    UIView *backButtonView = [self.backButton valueForKey:@"view"];
    [backButtonView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressBackButton:)]];
    
    // ツールバー > 進むボタンにロングタップのジェスチャーを登録する
    UIView *forwardButtonView = [self.forwardButton valueForKey:@"view"];
    [forwardButtonView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressForwardButton:)]];
    
    // ツールバー > 進むボタンにロングタップのジェスチャーを登録する
    UIView *reloadButtonView = [self.reloadButton valueForKey:@"view"];
    [reloadButtonView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressReloadButton:)]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showBackListSegue"]) {
        // 履歴画面に「戻る」履歴一覧をセットする
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        CLMBackForwardListViewController *backListViewController = (CLMBackForwardListViewController *)navigationController.topViewController;
        backListViewController.list = [[self.webView.backForwardList.backList reverseObjectEnumerator] allObjects];
    } else if ([segue.identifier isEqualToString:@"showForwardListSegue"]) {
        // 履歴画面に「進む」履歴一覧をセットする
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        CLMBackForwardListViewController *forwardListViewController = (CLMBackForwardListViewController *)navigationController.topViewController;
        forwardListViewController.list = self.webView.backForwardList.forwardList;
    }
}

#pragma mark - NSKeyValueObserving methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        // estimatedProgressが変更されたら、プログレスバーを更新する
        [self.navigationController setSGProgressPercentage:self.webView.estimatedProgress * 100.0f];
    } else if ([keyPath isEqualToString:@"title"]) {
        // titleが変更されたら、ナビゲーションバーのタイトルを設定する
        self.title = self.webView.title;
    } else if ([keyPath isEqualToString:@"loading"]) {
        // loadingが変更されたら、ステータスバーのインジケーターの表示・非表示を切り替える
        [UIApplication sharedApplication].networkActivityIndicatorVisible = self.webView.loading;
        
        // リロードボタンと読み込み停止ボタンの有効・無効を切り替える
        self.reloadButton.enabled = !self.webView.loading;
        self.stopButton.enabled = self.webView.loading;
    } else if ([keyPath isEqualToString:@"canGoBack"]) {
        // canGoBackが変更されたら、「＜」ボタンの有効・無効を切り替える
        self.backButton.enabled = self.webView.canGoBack;
    } else if ([keyPath isEqualToString:@"canGoForward"]) {
        // canGoForwardが変更されたら、「＞」ボタンの有効・無効を切り替える
        self.forwardButton.enabled = self.webView.canGoForward;
    }
}

#pragma mark - Private methods

- (IBAction)didTapBackButton:(id)sender
{
    [self.webView goBack];
}

- (IBAction)didTapForwardButton:(id)sender
{
    [self.webView goForward];
}

- (void)didLongPressBackButton:(UILongPressGestureRecognizer *)gesutureRecognizer
{
    if (gesutureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self performSegueWithIdentifier:@"showBackListSegue" sender:self];
    }
}

- (void)didLongPressForwardButton:(UILongPressGestureRecognizer *)gesutureRecognizer
{
    if (gesutureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self performSegueWithIdentifier:@"showForwardListSegue" sender:self];
    }
}

- (IBAction)didTapReloadButton:(id)sender
{
    [self.webView reload];
}

- (void)didLongPressReloadButton:(UILongPressGestureRecognizer *)gesutureRecognizer
{
    if (gesutureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Reload" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.webView reload];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Reload from origin" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.webView reloadFromOrigin];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)didTapStopButton:(id)sender
{
    [self.webView stopLoading];
}

- (IBAction)unwindToWebBrowser:(UIStoryboardSegue *)segue
{
    if (self.backForwardListItem) {
        [self.webView goToBackForwardListItem:self.backForwardListItem];
        self.backForwardListItem = nil;
    }
}

#pragma mark - WKNavigationDelegate methods

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"%s", __FUNCTION__);
}

@end
