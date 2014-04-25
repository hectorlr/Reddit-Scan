//
//  Posts.m
//  Reddit Scan
//
//  Created by Hector Rodriguez on 3/1/14.
//  Copyright (c) 2014 HectorRodriguz. All rights reserved.
//

#import "Post.h"

@implementation Post

@synthesize title;
@synthesize author;
@synthesize thumbnailURL;
@synthesize postUrl;

- (id)initWithTitle:(NSString*)thisTitle author:(NSString*)thisAuthor thumbnailURL:(NSString*)thisThumbnail postlURL:(NSString*)thisPostUrl{
    if ((self = [super init])) {
        self.title = thisTitle;
        self.author = thisAuthor;
        self.thumbnailURL = thisThumbnail;
        self.postUrl = thisPostUrl;
    }
    return self;
}

@end
