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
#define kQueueUnknown dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 8)

@interface MainTableViewController ()

#pragma mark - Properties

@property (nonatomic, strong) Photos *photo;
@property (nonatomic, strong) NSMutableArray *photosArray;
@property (nonatomic, strong) NSMutableDictionary *photosDictionary;
@property (nonatomic, strong) id json;

@end


@implementation MainTableViewController


#pragma mark - Initialization

- (void) viewDidLoad {
  [super viewDidLoad];

  dispatch_async(kQueueGlobal, ^{
    NSLog(@"1 of 3 - get data from network on background queue asynchronously");
    NSData *data = [NSData dataWithContentsOfURL:
                    kPhotosURL];
    // Remove below  per recommendation to not mix performSelector
    // with dispatch_async
    //[self performSelectorOnMainThread:@selector(fetchedData:)
    //                       withObject:data waitUntilDone:YES];
    NSLog(@"Asynchronous call executing now.");
    [self fetchedData:data];
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
      return [self.photosArray count];
}
 
 - (UITableViewCell *)tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   PhotoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoViewCell"forIndexPath:indexPath];
   self.photosDictionary = [self.photosArray objectAtIndex:indexPath.row];
   Photos *photo = [[Photos alloc] init];
   photo.albumId = [self.photosDictionary objectForKey:@"albumId"];
   photo.photoId = [self.photosDictionary objectForKey:@"id"];
   photo.title = [self.photosDictionary objectForKey:@"title"];
   
   photo.url = [self.photosDictionary objectForKey:@"url"];
   photo.thumbnailUrl = [self.photosDictionary objectForKey:@"thumbnailUrl"];
   
   UILabel *photoTitle = (UILabel *)[cell viewWithTag:10];
   photoTitle.text = photo.title;
   UILabel *photoUrl = (UILabel *)[cell viewWithTag:11];
   photoUrl.text = photo.thumbnailUrl;
   UILabel *photoId = (UILabel *)[cell viewWithTag:13];
   photoId.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
   
   NSURL *imageURL = [NSURL URLWithString:
              [[self.photosArray objectAtIndex:indexPath.row]
                              valueForKey:@"thumbnailUrl"]];
   
   NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
     if (data) {
       UIImage *image = [UIImage imageWithData:data];
       if (image) {
         
#pragma mark - GCD updating UI on main thread
         dispatch_async(kQueueMain, ^{
           PhotoViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
           //NSAssert([updateCell isKindOfClass:[UITableViewCell class]], NULL);
           if (updateCell)
             updateCell.photoImage.image = image;
             NSLog(@"3 of 3 - updateCell.photoImage.image on main queue asynchronously %ld", (long)indexPath.item);
         });
        }
     }
   }];
   [task resume];
   return cell;
 }

#pragma mark - Deep copy of a pass by reference object

- (id)copyWithZone:(NSZone *)zone {
  
  id copy = self.json;
  
  return copy;
}


#pragma mark - Asynchronous data serialization/parse in background

- (void)fetchedData:(NSData *)responseData {
  NSError *error;
  self.json = [NSJSONSerialization
                   JSONObjectWithData:responseData
                   options:kNilOptions
                   error:&error];

  self.photosArray = [self.json mutableCopyWithZone: nil];
  dispatch_async(kQueueMain, ^(void){
    //Run UI Updates
    NSLog(@"2 of 3 - [self.tableView reloadData] on main queue synchronously");
    [self.tableView reloadData];
  });
}


@end


