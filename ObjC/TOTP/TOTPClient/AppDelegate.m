/*------------------------------------------------------------------------------
 *
 *  AppDelegate.m
 *
 *  For full information on usage and licensing, see https://chirp.io/
 *
 *  Copyright © 2011-2019, Asio Ltd.
 *  All rights reserved.
 *
 *----------------------------------------------------------------------------*/

#import "AppDelegate.h"
#import "Credentials.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.connect = [[ChirpConnect alloc] initWithAppKey:CHIRP_APP_KEY andSecret:CHIRP_APP_SECRET];
    NSError *err = [self.connect setConfig:CHIRP_APP_CONFIG];
    if (!err) {
        err = [self.connect start];
        if (err) {
            NSLog(@"ChirpError (%@)", err.description);
        } else {
            NSLog(@"Started ChirpSDK");
        }
    } else {
        NSLog(@"ChirpError (%@)", err.description);
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    if (self.connect) {
        if (self.connect.state != CHIRP_CONNECT_STATE_STOPPED) {
            NSError *err = [self.connect stop];
            if (err) {
                NSLog(@"ChirpError (%@)", err.description);
            }
        }
    }
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    if (self.connect) {
        if (self.connect.state != CHIRP_CONNECT_STATE_STOPPED) {
            NSError *err = [self.connect stop];
            if (err) {
                NSLog(@"ChirpError (%@)", err.description);
            }
        }
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.connect) {
        if (self.connect.state == CHIRP_CONNECT_STATE_STOPPED) {
            NSError *err = [self.connect start];
            if (err) {
                NSLog(@"ChirpError (%@)", err.description);
            }
        }
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (self.connect) {
        if (self.connect.state == CHIRP_CONNECT_STATE_STOPPED) {
            NSError *err = [self.connect start];
            if (err) {
                NSLog(@"ChirpError (%@)", err.description);
            }
        }
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    if (self.connect) {
        if (self.connect.state != CHIRP_CONNECT_STATE_STOPPED) {
            NSError *err = [self.connect stop];
            if (err) {
                NSLog(@"ChirpError (%@)", err.description);
            }
        }
    }
}


@end
