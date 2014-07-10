//
//  RHCAppDelegate.m
//  Vindsiden-v2
//
//  Created by Ragnar Henriksen on 01.05.13.
//  Copyright (c) 2013 RHC. All rights reserved.
//

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import "RHCAppDelegate.h"
#import "RHCStationViewController.h"
#import "NSNumber+Convertion.h"
#import "NSString+isNumeric.h"
#import "RHCViewController.h"
#import "RHEVindsidenAPIClient.h"

@import VindsidenKit;

@interface RHCAppDelegate ()

@end


@implementation RHCAppDelegate
{
    dispatch_queue_t _formatterQueue;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    self.window.tintColor = RGBCOLOR( 227.0, 60.0, 13.0);

    _formatterQueue = dispatch_queue_create("formatter queue", NULL);
    
////#ifndef DEBUG
//    [TestFlight setOptions:@{@"disableInAppUpdates":@NO}];
//    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
//
////#endif
//    [TestFlight takeOff:@"b97e9c55-3aae-4f18-bc27-6fac0e973438"];

    // Override point for customization after application launch.
    if ( [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedUnit"] == 0 ) {
        [[NSUserDefaults standardUserDefaults] setInteger:SpeedConvertionToMetersPerSecond forKey:@"selectedUnit"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }

    [[Datamanager sharedManager] cleanupPlots];

    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    return YES;
}


- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURL *url = launchOptions[UIApplicationLaunchOptionsURLKey];
    if ( url.host == nil || [url.host rangeOfString:@"station" options:NSCaseInsensitiveSearch].location == NSNotFound ) {
        return NO;
    }
    return YES;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ( url.host == nil || [url.host rangeOfString:@"station" options:NSCaseInsensitiveSearch].location == NSNotFound ) {
        return NO;
    }

    id ident = [url.pathComponents lastObject];
    CDStation *station = nil;
    if ( [ident isNumeric] ) {
        station = [CDStation existingStation:ident inManagedObjectContext:[[Datamanager sharedManager] managedObjectContext]];
    } else {
        station = [CDStation searchForStation:ident inManagedObjectContext:[[Datamanager sharedManager] managedObjectContext]];
    }

    if ( nil == station ) {
        return NO;
    }

    if ( self.window.rootViewController.presentedViewController ) {
        [self.window.rootViewController dismissViewControllerAnimated:NO completion:^{
            [self openStationViewController:station];
        }];
    } else {
        [self openStationViewController:station];
    }

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    [RHEVindsidenAPIClient defaultManager].background = YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [RHEVindsidenAPIClient defaultManager].background = NO;
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [[Datamanager sharedManager] saveContext];
}


#if 0
- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application
{
    DLOG(@"");
}


- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application
{
    DLOG(@"");
}
#endif


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    DLOG(@"fetch");
    UINavigationController *nc = (UINavigationController *)self.window.rootViewController;
    RHCViewController *vc = (RHCViewController *)[nc.viewControllers firstObject];

    [vc updateContentWithCompletionHandler:completionHandler];
}


#pragma mark - Application's Documents directory


- (NSString *) applicationPrivateDocumentsDirectory
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Private Documents"];

    [fm createDirectoryAtPath:path withIntermediateDirectories:YES
                   attributes:nil
                        error:nil];

    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:path];
    [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
    return path;
}


#pragma mark - 


- (void)openStationViewController:(CDStation *)station
{
    UINavigationController *navCon = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"modalStationView"];
    RHCStationViewController *controller = navCon.viewControllers[0];

    [self.window.rootViewController presentViewController:navCon
                                                 animated:YES
                                               completion:^{
                                                   controller.currentStation = station;
                                               }
     ];
}


@end
