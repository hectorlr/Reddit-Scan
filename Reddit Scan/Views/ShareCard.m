//
//  ShareCard.m
//  Reddit Scan
//
//  Created by Hector Rodriguez on 3/1/14.
//  Copyright (c) 2014 HectorRodriguz. All rights reserved.
//

#import "ShareCard.h"
#import "ViewController.h"

@implementation ShareCard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)setParent:(ViewController*)thisParent
{
    parent = thisParent;
}

- (void)setPost:(Post*)thisPost
{
    post = thisPost;
}

- (void) addSubviews
{
    //Set the background image and resize the view to match the dimensions of the image
    UIImage* background = [UIImage imageNamed:@"shareCard.png"];
    UIImageView* backgroundView = [[UIImageView alloc] initWithImage:background];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, backgroundView.frame.size.width, backgroundView.frame.size.height);
    
    //Add an invisible button over the top right corner to close the view
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-30, 0, 30, 30)];
    closeButton.backgroundColor = [UIColor clearColor];
    [closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    float yOffset = 70;
    
    //Add a button using the provided image for emailing the post
    UIButton *emailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, yOffset, self.frame.size.width, 50)];
    [emailButton setImage:[UIImage imageNamed:@"email.png"] forState:UIControlStateNormal];
    [emailButton addTarget:self action:@selector(emailButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    yOffset+=emailButton.frame.size.height+15;
    
    //Add a button using the provided image for sending an sms message using the post
    UIButton *smsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, yOffset, self.frame.size.width, 50)];
    [smsButton setImage:[UIImage imageNamed:@"sms.png"] forState:UIControlStateNormal];
    [smsButton addTarget:self action:@selector(smsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:closeButton];
    [self addSubview:backgroundView];
    [self addSubview:emailButton];
    [self addSubview:smsButton];
}

//Hide the view using animation
- (void) closeButtonTapped
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         [UIView setAnimationCurve:UIViewAnimationCurveLinear];
         self.frame=CGRectMake(parent.view.frame.size.width, parent.view.frame.size.height, self.frame.size.width, self.frame.size.height);
         
     }
                     completion:^(BOOL b)
     {
         [parent.dimmer removeFromSuperview];
     }
     ];
    
}

//When the sms button is tapped, create a message and show the view
- (void)smsButtonTapped{
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"Check out this epic Reddit post: %@\n\n%@", post.title, post.postUrl];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setBody:message];
    
    [self closeButtonTapped];
    // Present message view controller on screen
    [parent presentViewController:messageController animated:YES completion:nil];
}

//Handle the return from the sms window
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [parent dismissViewControllerAnimated:YES completion:nil];
}

//When the email button is tapped, create an email and show the email view
- (void)emailButtonTapped {
    // Email Subject
    NSString *emailTitle = @"Check out this epic Reddit post!";
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"%@\n\n%@", post.title, post.postUrl];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    
    [self closeButtonTapped];
    
    // Present mail view controller on screen
    [parent presentViewController:mc animated:YES completion:NULL];
    
}

//Handle the return from the email view
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [parent dismissViewControllerAnimated:YES completion:NULL];
}

@end
