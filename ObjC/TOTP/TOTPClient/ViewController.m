/*------------------------------------------------------------------------------
 *
 *  ViewController.m
 *
 *  For full information on usage and licensing, see https://chirp.io/
 *
 *  Copyright © 2011-2019, Asio Ltd.
 *  All rights reserved.
 *
 *----------------------------------------------------------------------------*/

#import "AppDelegate.h"
#import "ViewController.h"
#import <ChirpConnect/ChirpConnect.h>
#import "Classes/TOTPGenerator.h"
#import "Classes/MF_Base32Additions.h"
#import "Credentials.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    self.secretTextField.delegate = self;
    self.expiryTextField.delegate = self;
    self.digitsTextField.delegate = self;

    self.secretTextField.text = CHIRP_APP_KEY;
    self.expiryTextField.text = @"30";
    self.digitsTextField.text = @"6";

    [self updateUI];

    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
}

- (IBAction)sendButtonPressed:(id)sender
{
    NSString *chirpPIN = self.PINLabel.text;
    NSData *data = [self encodeMessage:chirpPIN];

    ChirpConnect *connect = ((AppDelegate *)[UIApplication sharedApplication].delegate).connect;
    [connect send:data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateUI
{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:timeZone];
    NSString *dateString = [dateFormatter stringFromDate:now];

    long timestamp = (long)[now timeIntervalSince1970];
    if(timestamp % [self.expiryTextField.text integerValue] != 0){
        timestamp -= timestamp % [self.expiryTextField.text integerValue];
    }

    self.dateLabel.text = dateString;
    self.timestampLabel.text = [NSString stringWithFormat:@"%ld",timestamp];

    [self generatePIN];
}

-(void)generatePIN
{
    NSString *secret = self.secretTextField.text;
    NSData *secretData =  [NSData dataWithBase32String:[secret base32String]];

    NSInteger digits = [self.digitsTextField.text integerValue];
    NSInteger period = [self.expiryTextField.text integerValue];
    NSTimeInterval timestamp = [self.timestampLabel.text integerValue];

    TOTPGenerator *generator = [[TOTPGenerator alloc] initWithSecret:secretData algorithm:kOTPGeneratorSHA1Algorithm digits:digits period:period];

    NSString *pin = [generator generateOTPForDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];

    self.PINLabel.text = pin;
}

-(NSData *) encodeMessage:(NSString *)message
{
    NSString *string = [NSString stringWithUTF8String:message.UTF8String];
    ChirpConnect *connect = ((AppDelegate *)[UIApplication sharedApplication].delegate).connect;
    
    if ([string lengthOfBytesUsingEncoding:NSUTF8StringEncoding] >
        [connect maxPayloadLength]) {
        return nil;
    }

    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [connect isValidPayload:stringData] ? stringData : nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    return YES;
}

@end
