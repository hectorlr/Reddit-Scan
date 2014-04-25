//
//  ViewController.m
//  Reddit Scan
//
//  Created by Hector Rodriguez on 3/1/14.
//  Copyright (c) 2014 HectorRodriguz. All rights reserved.
//

#import "ViewController.h"
#import "CellView.h"
#import "Post.h"
#import "ShareCard.h"

@interface ViewController ()
@end

@implementation ViewController

@synthesize imageCache;
@synthesize dimmer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Start with a fresh image cache when the view loads
	imageCache = [[NSCache alloc] init];
    [self addViews];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
}

- (void) addViews
{
    int yOffset = 20;
    float width = self.view.frame.size.width;
    
    //Overlay Image
    UIImageView *overlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, width, self.view.frame.size.height-yOffset)];
    overlay.image = [UIImage imageNamed:@"overlay.png"];
    
    //Black search bar initialized with 'funny'
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, yOffset, width, 40)];
    [searchBar setDelegate:self];
    searchBar.barStyle = UIBarStyleBlack;
    searchBar.text = @"funny";
    
    yOffset+=searchBar.frame.size.height;
    
    //UITableView with keyboard dismiss on drag
    postsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, yOffset, width-20, self.view.frame.size.height-yOffset)];
    [postsTableView setDelegate:self];
    [postsTableView setDataSource:self];
    postsTableView.backgroundColor = [UIColor clearColor];
    postsTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    //Initialize results
    [self getResultsAndLoadTableView];
    
    //Pull to refresh
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(getResultsAndLoadTableView) forControlEvents:UIControlEventValueChanged];
    [postsTableView addSubview:refreshControl];
    
    //Share card initialized off screen
    float ratio = 402.0f/566.0f;
    float height = ratio * (width-50.0f);
    shareCard = [[ShareCard alloc] initWithFrame:CGRectMake(self.view.frame.size.width, self.view.frame.size.height, width-50, height)];
    [shareCard setParent:self];
    
    [self.view addSubview:overlay];
    [self.view addSubview:searchBar];
    [self.view addSubview:postsTableView];
    [self.view addSubview:shareCard];
}

//Handles search button tapped action
- (void)searchBarSearchButtonClicked:(UISearchBar *)intstanceSearchBar {
    [self getResultsAndLoadTableView];
    [self hideKeyboard];
}

//The
- (void)getResultsAndLoadTableView{
    results = [[NSMutableArray alloc] init];
    NSString *subreddit = searchBar.text;
    
    BOOL validString = [self validateString:subreddit];
    
    if (validString) {
        
        NSString *urlAsString = [NSString stringWithFormat:@"http://www.reddit.com/r/%@/.json", subreddit];
        NSURL *url = [[NSURL alloc] initWithString:urlAsString];
        
        //Asynchronously load posts
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            
            NSData *data = [NSData dataWithContentsOfURL:url];
            if(data){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *myError = nil;
                    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
                    if(res){
                        NSArray *posts = [[res objectForKey:@"data"] objectForKey:@"children"];
                        for(NSDictionary *child in posts) {
                            
                            //We have a post, lets create an object and add it to the array of results
                            NSDictionary *item = [child objectForKey:@"data"];
                            NSString *title = [item objectForKey:@"title"];
                            NSString *author = [item objectForKey:@"author"];
                            NSString *thumbnailURL = [item objectForKey:@"thumbnail"];
                            NSString *permalink = [item objectForKey:@"permalink"];
                            
                            permalink = [NSString stringWithFormat:@"%@%@", @"www.reddit.com", permalink];
                            
                            
                            Post *post = [[Post alloc] initWithTitle:title author:author thumbnailURL:thumbnailURL postlURL:permalink];
                            [results addObject:post];
                        }
                        
                        [postsTableView reloadData];
                        [refreshControl endRefreshing];
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self retrievedNothingAlertWithTitle:@"Nothing Here" andMessage:@"Maybe this isn't a Subreddit, try again."];
                        });
                    }
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self retrievedNothingAlertWithTitle:@"Nothing Here" andMessage:@"Maybe this isn't a Subreddit, try again."];
                });
            }
        });
        
    }else{
        [self retrievedNothingAlertWithTitle:@"Invalid Subreddit Name" andMessage:@"Must contain letters, numbers, or '_'.\nMust not start with '_'.\nMust not be longer than 21 characters."];
    }
}

//Only letters, numbers, '_' as long as '_' is not
//the first character, and less than or equal to 22 character
//https://github.com/reddit/reddit/blob/master/r2/r2/lib/validator/validator.py#L526
- (BOOL)validateString:(NSString *)string
{
    NSString *pattern = @"[A-Za-z0-9][A-za-z0-9_]{2,20}";
    
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [test evaluateWithObject:string];
}

//Used when the search result returns nothing
- (void) retrievedNothingAlertWithTitle:(NSString *)title andMessage:(NSString *) message
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(title, nil) message:NSLocalizedString(message, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    
    [postsTableView reloadData];
    [refreshControl endRefreshing];
}

- (void)hideKeyboard{
    [searchBar resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Cell";
    
    Post *post = (Post*)[results objectAtIndex:indexPath.row];
    
    CellView *cell = [[CellView alloc] init];
    [cell setParent:self];
    [cell setPost:post];
    
    if (cell == nil) {
        cell = [[CellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    return cell;
}

//Dynamically set the heigt for the table row based on content
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // check here, if it is one of the cells, that needs to be resized
    // to the size of the contained UITextView
    Post *post = (Post*)[results objectAtIndex:indexPath.row];
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width-85,9999);
    CGRect textRect = [post.title  boundingRectWithSize:maximumLabelSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}
                                         context:nil];
    CGSize expectedLabelSize = textRect.size;
    
    return expectedLabelSize.height + 50;
}

///When a post is touched, show the share card
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showShareCard];
    Post *post = (Post*)[results objectAtIndex:indexPath.row];
    [shareCard setPost:post];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Make the status bar white
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//Animate the share card into the view
- (void) showShareCard
{
    dimmer = [[UIView alloc] initWithFrame:self.view.frame];
    dimmer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dimmer"]];
    dimmer.alpha = 0.95f;
    [self.view addSubview:dimmer];

    [self.view bringSubviewToFront:shareCard];
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         [UIView setAnimationCurve:UIViewAnimationCurveLinear];
         
         float xOffsetShareCard = (self.view.frame.size.width - shareCard.frame.size.width)/2;
         float yOffsetShareCard = (self.view.frame.size.height - shareCard.frame.size.height)/2;
         
         shareCard.frame = CGRectMake(xOffsetShareCard, yOffsetShareCard, shareCard.frame.size.width, shareCard.frame.size.height);
         
     }
                     completion:^(BOOL b)
     {
     }
     ];
}
@end
