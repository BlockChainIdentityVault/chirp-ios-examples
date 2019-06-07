/*------------------------------------------------------------------------------
 *
 *  ViewController.h
 *
 *  For full information on usage and licensing, see https://chirp.io/
 *
 *  Copyright © 2011-2019, Asio Ltd.
 *  All rights reserved.
 *
 *----------------------------------------------------------------------------*/

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate> {
    NSInteger digits;
    NSInteger period;
    NSTimeInterval timestamp;
    NSString * secret;
}

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UITextField *PINLabel;
@property (weak, nonatomic) IBOutlet UITextField *secretTextField;
@property (weak, nonatomic) IBOutlet UITextField *expiryTextField;
@property (weak, nonatomic) IBOutlet UITextField *digitsTextField;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

- (IBAction)sendButtonPressed: (id)sender;

@end

