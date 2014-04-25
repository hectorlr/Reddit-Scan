//
//  Posts.h
//  Reddit Scan
//
//  Created by Hector Rodriguez on 3/1/14.
//  Copyright (c) 2014 HectorRodriguz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject{
    NSString *title;
    NSString *author;
    NSString *thumbnailURL;
    NSString *postUrl;
    
}
@property (copy) NSString *title;
@property (copy) NSString *author;
@property (copy) NSString *thumbnailURL;
@property (copy) NSString *postUrl;

- (id)initWithTitle:(NSString*)thisTitle author:(NSString*)thisAuthor thumbnailURL:(NSString*)thisThumbnail postlURL:(NSString*)thisPostUrl;

@end
