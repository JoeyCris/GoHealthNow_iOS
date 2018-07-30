//
//  GlucoGuideTabBarController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-30.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "GlucoGuideTabBarController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "GGTabBar.h"

@interface GlucoGuideTabBarController() <UITableViewDelegate, UINavigationControllerDelegate>

@property(nonatomic) id<UITableViewDelegate> origDelegate;

@end

@implementation GlucoGuideTabBarController

#pragma mark - View Lifecyle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    GGTabBar *tabBar = [[GGTabBar alloc]initWithFrame:self.tabBar.frame];
    @try {
        [self setValue:tabBar forKey:@"tabBar"];
    }
    @catch (NSException *exception) {
        NSLog(@"Urgent error: tabBar key changed. Please fix that problem ASAP.");
    }
    @finally {
        
    }
    
    [StyleManager styleTabBar:tabBar];
    
    for (UINavigationController *rootNavigationController in self.childViewControllers) {
        [StyleManager styleNavigationBar:rootNavigationController.navigationBar];
    }
    
    if (self.moreNavigationController) {
        self.moreNavigationController.delegate = self;
        
        [StyleManager styleNavigationBar:self.moreNavigationController.navigationBar];
        
        if ([self.moreNavigationController.topViewController.view isKindOfClass:[UITableView class]]) {
            UITableView *moreTableView = (UITableView *)self.moreNavigationController.topViewController.view;
            
            [StyleManager styleTable:moreTableView];
            moreTableView.separatorColor = [UIColor buttonColor];
            
            self.origDelegate = moreTableView.delegate;
            moreTableView.delegate = self;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.origDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
    [StyleManager styleTableCell:cell];
    cell.imageView.tintColor = [UIColor buttonColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.origDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Navigation Controller Delegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    UINavigationBar *morenavbar = navigationController.navigationBar;
    UINavigationItem *morenavitem = morenavbar.topItem;
    /* We don't need Edit button in More screen. */
    morenavitem.rightBarButtonItem = nil;
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    @try {
        [((GGTabBar *)self.tabBar) reDrawWithScreenSize:size];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

@end
