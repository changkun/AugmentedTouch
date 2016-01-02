//
//  DataViewerViewController.m
//  TouchMotion
//
//  Created by 欧长坤 on 01/01/16.
//  Copyright © 2016 Changkun Ou. All rights reserved.
//

#import "DataViewerViewController.h"

@implementation DataViewerViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = @"123";
    return cell;
}
@end
