//
//  ViewController.h
//  Reddit Scan
//
//  Created by Hector Rodriguez on 3/1/14.
//  Copyright (c) 2014 HectorRodriguz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareCard.h"

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>{
    UISearchBar *searchBar;
    NSMutableArray *results;
    UITableView *postsTableView;
    ShareCard *shareCard;
    NSCache *imageCache;
    UIRefreshControl *refreshControl;
    UIView *dimmer;
}

@property (copy) NSCache *imageCache;
@property UIView *dimmer;

@end
