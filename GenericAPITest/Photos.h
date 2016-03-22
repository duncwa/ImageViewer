//
//  Photos.h
//  GenericAPITest
//
//  Created by Duncan Wallace on 3/8/16.
//  Copyright © 2016 Duncan Wallace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photos : NSObject

@property (nonatomic, copy) NSString *albumId;
@property (nonatomic, copy) NSString *photoId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *thumbnailUrl;

@end
