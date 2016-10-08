//
//  MainTableViewController.h
//  GenericAPITest
//
//  Created by Duncan Wallace on 3/8/16.
//  Copyright © 2016 Duncan Wallace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, NSCopying>

@property (nonatomic, strong) NSMutableArray *photos;

//Comment

@end
