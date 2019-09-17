/*------------------------------------------------------------------------------
 *
 *  AppDelegate.h
 *
 *  For full information on usage and licensing, see https://chirp.io/
 *
 *  Copyright © 2011-2019, Asio Ltd.
 *  All rights reserved.
 *
 *----------------------------------------------------------------------------*/

#import <UIKit/UIKit.h>
#import <ChirpSDK/ChirpSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ChirpSDK *chirp;

@end

