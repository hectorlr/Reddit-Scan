//
//  ShareCard.h
//  Reddit Scan
//
//  Created by Hector Rodriguez on 3/1/14.
//  Copyright (c) 2014 HectorRodriguz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Post.h"

@class ViewController;


@interface ShareCard : UIView<MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>{
    ViewController *parent;
    Post *post;
}

- (void)setParent:(ViewController*)thisParent;
- (void)setPost:(Post*)thisPost;

@end
