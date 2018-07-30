//
//  UserSetupPageViewControllerProtocol.h
//  GlucoGuide
//
//  Created by Siddarth on 2015-01-25.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UserSetupPageViewControllerProtocol <NSObject>

@required

@property (nonatomic) BOOL isUserSetupModeEnabled;
@property (nonatomic) NSUInteger userSetupPageIndex;

@optional

@property (nonatomic) id delegate;
- (void)didFlipForwardToNextPageWithGesture:(id)sender;

@end
