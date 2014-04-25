//
//  CellView.m
//  Reddit Scan
//
//  Created by Hector Rodriguez on 3/1/14.
//  Copyright (c) 2014 HectorRodriguz. All rights reserved.
//

#import "CellView.h"
#import "Post.h"

@implementation CellView


- (void) setPost:(Post*)thisPost{
    post = thisPost;
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self addSubviews];
}

- (void) addSubviews
{
    float yOffset = 5;
    float xOffset = 20;
    
    //Image associated with post
    UIImageView *thumbnailView = [[UIImageView alloc]initWithFrame:CGRectMake(xOffset, yOffset, 50, 50)];
    
    //Get image from either cache or asynchronously
    [self setImageWithURL:post.thumbnailURL forUIImageView:thumbnailView];
    
    xOffset += thumbnailView.frame.size.width + 5;
    float width = self.frame.size.width - xOffset;
    
    //Add the lable for the author using the provided font
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, width, 22)];
    authorLabel.text = post.author;
    authorLabel.textColor = [UIColor colorWithRed:54.0f/255.0f green:145.0f/255.0f blue:255.0f/255.0f alpha:1];
    authorLabel.font = [UIFont fontWithName:@"bebasneue" size:22];
    
    yOffset += authorLabel.frame.size.height+5;
    
    //Set the size for the title frame
    CGSize maximumLabelSize = CGSizeMake(width-15,9999);
    CGRect textRect = [post.title  boundingRectWithSize:maximumLabelSize
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}
                                                context:nil];
    CGSize expectedLabelSize = textRect.size;
    
    //Add the title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, expectedLabelSize.width, expectedLabelSize.height)];
    titleLabel.text = post.title;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.numberOfLines = 0;
    
    [self addSubview:thumbnailView];
    [self addSubview:authorLabel];
    [self addSubview:titleLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

//Set the parent UIViewController for
- (void)setParent:(ViewController*)thisParent
{
    parent = thisParent;
}

//Pull the images from a cache if possible.
//If not, asynchronously load image and store it in cache
- (void) setImageWithURL:(NSString *)url forUIImageView: (UIImageView *)thumbnailView;
{
    if([parent.imageCache objectForKey:url]){
        UIImage *thumbnail = (UIImage *)[parent.imageCache objectForKey:url];
        thumbnailView.image = thumbnail;
        
        
        //Shadow is added to the UIImageView
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:thumbnailView.bounds];
        thumbnailView.layer.masksToBounds = NO;
        thumbnailView.layer.shadowColor = [UIColor blackColor].CGColor;
        thumbnailView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
        thumbnailView.layer.shadowOpacity = 0.5f;
        thumbnailView.layer.shadowPath = shadowPath.CGPath;
    }else{
        //Asynchronously load images
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *thumbnail = [UIImage imageWithData:data];
                if (thumbnail) {
                    [parent.imageCache setObject:thumbnail forKey:url];
                    thumbnailView.image = thumbnail;
                }
            });
        });
    }
    
}



@end
