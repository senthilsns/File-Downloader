//
//  AppDelegate.h
//  FileDownloader
//
//  Created by appledeveloper on 25/03/19.
//  Copyright © 2019 Senthilkumar K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

