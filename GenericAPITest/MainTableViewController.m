//
//  MainTableViewController.m
//  GenericAPITest
//
//  Created by Duncan Wallace on 3/8/16.
//  Copyright © 2016 Duncan Wallace. All rights reserved.
//

#import "MainTableViewController.h"
#import "Photos.h"
#import "PhotoViewCell.h"

#define kQueueGlobal dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kQueueMain dispatch_get_main_queue()
#define kPhotosURL [NSURL URLWithString: @"http://jsonplaceholder.typicode.com/photos"]

@interface MainTableViewController ()

@end


@implementation MainTableViewController

#pragma mark - Properties

Photos *photo;
NSMutableArray *photosArray;
NSMutableDictionary *photosDictionary;

#pragma mark - Initialization

- (void) viewDidLoad {
  [super viewDidLoad];

  dispatch_async(kQueueGlobal, ^{
    NSData *data = [NSData dataWithContentsOfURL:
                    kPhotosURL];
    [self performSelectorOnMainThread:@selector(fetchedData:)
                           withObject:data waitUntilDone:YES];
  });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
      return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
      return [photosArray count];
}
 
 - (UITableViewCell *)tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   PhotoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoViewCell"forIndexPath:indexPath];
   photosDictionary = [photosArray objectAtIndex:indexPath.row];
   Photos *photo = [[Photos alloc] init];
   photo.albumId = [photosDictionary objectForKey:@"albumId"];
   photo.photoId = [photosDictionary objectForKey:@"id"];
   photo.title = [photosDictionary objectForKey:@"title"];
   photo.url = [photosDictionary objectForKey:@"url"];
   photo.thumbnailUrl = [photosDictionary objectForKey:@"thumbnailUrl"];
   
   UILabel *photoTitle = (UILabel *)[cell viewWithTag:10];
   photoTitle.text = photo.title;
   UILabel *photoUrl = (UILabel *)[cell viewWithTag:11];
   photoUrl.text = photo.thumbnailUrl;

   NSURL *imageURL = [NSURL URLWithString:
              [[photosArray objectAtIndex:indexPath.row]
                              valueForKey:@"thumbnailUrl"]];
   
   NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
     if (data) {
       UIImage *image = [UIImage imageWithData:data];
       if (image) {
         
#pragma mark - GCD updating UI on main thread
         
         dispatch_async(kQueueMain, ^{
           PhotoViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
           if (updateCell)
             updateCell.photoImage.image = image;
         });
       }
     }
   }];
   
   [task resume];
   return cell;
}

#pragma mark - Asynchronous data fetch in background

- (void)fetchedData:(NSData *)responseData {
  NSError *error;
  NSArray *json = [NSJSONSerialization
                   JSONObjectWithData:responseData
                   options:kNilOptions
                   error:&error];

  photosArray = [NSMutableArray arrayWithArray:json];

  [self.tableView reloadData];
}


@end


