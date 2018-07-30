//
//  dropdownList.h
//  dropdownList
//
//  Created by Haoyu Gu on 2016-03-29.
//  Copyright © 2016 Haoyu Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol dropdownListDelegate <NSObject>

@optional
-(void)dropdownListSelectedAtIndex:(NSUInteger)index;
-(void)dropdownListSelectedString:(NSString *)string;

@end

@interface dropdownList : UIView

- (id)init;
- (id)initWithData:(NSArray*)data;

- (void)showWithData:(NSArray *)data;
- (void)setHeaderOffsetString:(NSString *)offset;

- (void)show;
- (void)hide;
- (void)remove;

@property (nonatomic) id<dropdownListDelegate> delegate;

@end
