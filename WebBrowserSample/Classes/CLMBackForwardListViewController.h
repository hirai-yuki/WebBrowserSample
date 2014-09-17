//
//  CLMBackForwardListViewController.h
//  WebBrowserSample
//
//  Created by hirai.yuki on 2014/09/06.
//  Copyright (c) 2014年 Classmethod, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 履歴一覧を表示するための ViewController
 */
@interface CLMBackForwardListViewController : UITableViewController

/**
 表示する履歴一覧
 */
@property (strong, nonatomic) NSArray *list;

@end
