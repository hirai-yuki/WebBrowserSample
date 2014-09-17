//
//  CLMWebBrowserViewController.h
//  WebBrowserSample
//
//  Created by hirai.yuki on 2014/09/06.
//  Copyright (c) 2014年 Classmethod, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

/**
 簡易 Web ブラウザーを表示する ViewController
 */
@interface CLMWebBrowserViewController : UIViewController

/**
 履歴一覧画面で選択された WKBackForwardListItem インスタンスをセットするためのプロパティ
 */
@property (strong, nonatomic) WKBackForwardListItem *backForwardListItem;

@end

