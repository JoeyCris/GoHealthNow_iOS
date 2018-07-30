//
//  dropdownList.m
//  dropdownList
//
//  Created by Haoyu Gu on 2016-03-29.
//  Copyright © 2016 Haoyu Gu. All rights reserved.
//

#import "dropdownList.h"
#import "FoodItem.h"

@interface dropdownList() <UITableViewDataSource , UITableViewDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *data;
@property (nonatomic) NSString *offsetString;
@property (nonatomic) BOOL drawed;

@end

static NSString * const TAG_TABLE_VIEW_CELL = @"tableViewCellId";
static NSUInteger const CELL_HEIGHT = 50;

@implementation dropdownList

@synthesize delegate;

- (id)init {
    if (self = [super init]) {
        self.drawed = NO;
    }
    return self;
}

- (id)initWithData:(NSArray*)data {
    if (self = [super init]) {
        self.drawed = NO;
        [self showWithData:data];
    }
    return self;
}

- (void)drawElements {
    self.offsetString = @"";
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height/2);
    self.backgroundColor = [UIColor clearColor];
    self.tableView = [[UITableView alloc] init];
    [self.tableView setFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //[self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
    [self addSubview:self.tableView];
    
    self.drawed = YES;
}

- (void)setHeaderOffsetString:(NSString*)offset{
    self.offsetString = offset;
}

- (void)showWithData:(NSArray *)data {
    if (self.data) {
        [self.data removeAllObjects];
    }
    self.data = [[NSMutableArray alloc] initWithArray:data];
    if (!self.drawed) {
        [self drawElements];
    }
    self.hidden = NO;
    [self.tableView reloadData];
}

- (void)show {
    self.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^(){
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y,
                                          self.tableView.frame.size.width, ([self.data count]*CELL_HEIGHT <= self.frame.size.height)? [self.data count]*CELL_HEIGHT:self.frame.size.height);
    }   completion:^(BOOL finished){
        if (finished) {
            [self.tableView reloadData];
        }
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.25 animations:^(){
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y,
                                          self.tableView.frame.size.width, 0);
    }   completion:^(BOOL finished){
        if (finished) {
            self.hidden= YES;
        }
    }];
}

- (void)remove {
    
}

- (void)sendOutStringBtnTapped:(UIButton *)btn {
    [self.delegate dropdownListSelectedString:((FoodItem *)self.data[btn.tag]).name];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CGFloat newHeight = ([self.data count]*CELL_HEIGHT <= self.frame.size.height)? [self.data count]*CELL_HEIGHT: self.frame.size.height;
    if (self.tableView.frame.size.height != newHeight) {
        [UIView animateWithDuration:0.25 animations:^(){
             self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, newHeight);
        }];
    }
    
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:TAG_TABLE_VIEW_CELL];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TAG_TABLE_VIEW_CELL];
        UIButton *topLeftButton = [[UIButton alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 38, 16, 18, 18)];
        [topLeftButton setBackgroundImage:[UIImage imageNamed:@"topLeftArrowIcon"] forState:UIControlStateNormal];
        topLeftButton.tag = indexPath.row;
        [topLeftButton addTarget:self action:@selector(sendOutStringBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        topLeftButton.userInteractionEnabled = YES;
        [cell addSubview:topLeftButton];
        [cell bringSubviewToFront:topLeftButton];
    }
    
    for (UIView *e in cell.subviews) {
        if ([e isKindOfClass:[UIButton class]]) {
            e.tag = indexPath.row;
        }
    }
    
    
    //cell.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 5);
    
    cell.textLabel.text = [self.data objectAtIndex:indexPath.row];
    
    //[cell.textLabel setText:[NSString stringWithFormat:@"%@%@", self.offsetString, ((FoodItem *)self.data[indexPath.row]).name]];
    //[cell.detailTextLabel setText:@"Detail"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate dropdownListSelectedAtIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
