//
//  CLMBackForwardListViewController.m
//  WebBrowserSample
//
//  Created by hirai.yuki on 2014/09/06.
//  Copyright (c) 2014年 Classmethod, Inc. All rights reserved.
//

#import "CLMBackForwardListViewController.h"
#import "CLMWebBrowserViewController.h"
#import <WebKit/WebKit.h>

@implementation CLMBackForwardListViewController

#pragma mark - Lifecycle methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"unwindToWebBrowserWhileSelectingItem"]) {
        // 選択した WKBackForwardListItem インスタンスを Web ブラウザー画面に渡す
        CLMWebBrowserViewController *webBrowserViewController = (CLMWebBrowserViewController *)segue.destinationViewController;
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        WKBackForwardListItem *item = self.list[indexPath.row];
        webBrowserViewController.backForwardListItem = item;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    WKBackForwardListItem *item = self.list[indexPath.row];
    
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = [item.URL absoluteString];
    
    return cell;
}

@end
