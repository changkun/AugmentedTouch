//
//  DataViewerViewController.m
//  TouchMotion
//
//  Created by 欧长坤 on 01/01/16.
//  Copyright © 2016 Changkun Ou. All rights reserved.
//

#import "DataViewerViewController.h"
#import "SQLiteTool.h"

@implementation DataViewerViewController

- (void)viewDidLoad {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger users = [SQLiteTool recordUserNumbers];
    return users;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = [NSString stringWithFormat:@"User %lu", (unsigned long)indexPath.row+1];
    return cell;
}
@end
