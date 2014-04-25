//
//  CellView.h
//  Reddit Scan
//
//  Created by Hector Rodriguez on 3/1/14.
//  Copyright (c) 2014 HectorRodriguz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "ViewController.h"

@interface CellView : UITableViewCell{
    ViewController *parent;
    Post* post;
}

- (void) setParent:(ViewController*)thisParent;
- (void) setPost:(Post*)thisPost;
@end
