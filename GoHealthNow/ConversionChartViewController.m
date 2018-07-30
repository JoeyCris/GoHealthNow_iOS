//
//  ViewController.m
//  singleton
//
//  Created by John Wreford on 2016-02-16.
//  Copyright © 2016 John Wreford. All rights reserved.
//

#import "ConversionChartViewController.h"
#import "StyleManager.h"
#import "Constants.h"

@interface ConversionChartViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *arrayVolImperial, *arrayVolMetric;
@property (nonatomic) NSArray *arrayWeightImperial, *arrayWeightMetric;

@end

@implementation ConversionChartViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    [StyleManager styleTable:self.tableView];
    
    self.arrayVolImperial = [[NSArray alloc]initWithObjects:[LocalizationManager getStringFromStrId:@"1/4 teaspoon (tsp)"],
                                                            [LocalizationManager getStringFromStrId:@"1/2 tsp"],
                                                            [LocalizationManager getStringFromStrId:@"1 tsp"],
                             [LocalizationManager getStringFromStrId:@"1 tablespoon (tbsp)"], [LocalizationManager getStringFromStrId:@"1/4 cup"], [LocalizationManager getStringFromStrId:@"1/3 cup"], [LocalizationManager getStringFromStrId:@"1/2 cup"], [LocalizationManager getStringFromStrId:@"2/3 cup"], [LocalizationManager getStringFromStrId:@"3/4 cup"], [LocalizationManager getStringFromStrId:@"1 cup"], nil];
    
    self.arrayVolMetric = [[NSArray alloc]initWithObjects:[LocalizationManager getStringFromStrId:@"1.25 ml (mililiter)"], @"2.5 ml", @"5 ml", @"15 ml", @"60 ml", @"75 ml", @"125 ml", @"150 ml", @"175 ml", @"250 ml", nil];
    
    self.arrayWeightImperial = [[NSArray alloc]initWithObjects:[LocalizationManager getStringFromStrId:@"1/2 ounce (oz)"], @"1 oz", @"2 oz", @"3 oz", @"4 oz", @"6 oz", @"7 oz", @"8 oz", @"9 oz", @"10 oz", @"12 oz", [LocalizationManager getStringFromStrId:@"1 lb (pound)"], @"1 1/2 lb", @"2 lb", nil];
    
        self.arrayWeightMetric = [[NSArray alloc]initWithObjects:[LocalizationManager getStringFromStrId:@"15 g (grams)"], @"25 g", @"50 g", @"75 g", @"100 g", @"175 g", @"200 g", @"250 g", @"275 g", @"300 g", @"350 g", @"450 g", @"750 g", [LocalizationManager getStringFromStrId:@"1 kg (kilogram)"], nil];
    
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    switch (section) {
        case 0:{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 20, 44)];
            NSString *string = [LocalizationManager getStringFromStrId:@"Volume"];
            
            label.font = [UIFont boldSystemFontOfSize:18];
            label.textColor = [UIColor darkGrayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByTruncatingMiddle;
            label.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [label setText:string];
            [view addSubview:label];
            view.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:244.0/255.0 blue:250/255.0 alpha:1];
            return view;
        }
            break;
            
        case 1:{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 20, 44)];
            NSString *string = [LocalizationManager getStringFromStrId:MSG_WEIGHT];
            
            label.font = [UIFont boldSystemFontOfSize:18];
            label.textColor = [UIColor darkGrayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByTruncatingMiddle;
            label.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [label setText:string];
            [view addSubview:label];
            view.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:244.0/255.0 blue:250/255.0 alpha:1];
            return view;
        }
            break;
            
        default:
            break;
    }
    
    return view;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [self.arrayVolImperial count];
    }else{
        return [self.arrayWeightImperial count];
    }
}
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"cellIdentifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:
        {
            UILabel *lblVolImperial = (UILabel *)[cell viewWithTag:100];
            lblVolImperial.text = [self.arrayVolImperial objectAtIndex:indexPath.row];
            
            UILabel *lblVolMetric = (UILabel *)[cell viewWithTag:101];
            lblVolMetric.text = [self.arrayVolMetric objectAtIndex:indexPath.row];
        }
            break;
            
        case 1:
        {
            UILabel *lblWeightImperial = (UILabel *)[cell viewWithTag:100];
            lblWeightImperial.text = [self.arrayWeightImperial objectAtIndex:indexPath.row];
            
            UILabel *lblWeightMetric = (UILabel *)[cell viewWithTag:101];
            lblWeightMetric.text = [self.arrayWeightMetric objectAtIndex:indexPath.row];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (IBAction)btnCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
