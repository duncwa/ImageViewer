//
//  PhotoViewCell.h
//  GenericAPITest
//
//  Created by Duncan Wallace on 3/8/16.
//  Copyright © 2016 Duncan Wallace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *photoImage;
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *url;

@end
