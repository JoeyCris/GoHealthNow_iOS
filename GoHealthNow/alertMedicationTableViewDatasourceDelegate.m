//
//  ViewController.m
//  datasouce
//
//  Created by John Wreford on 2015-09-30.
//  Copyright © 2015 John Wreford. All rights reserved.
//

#import "alertMedicationTableViewDatasourceDelegate.h"

@interface alertMedicationTableViewDatasourceDelegate ()

@end


@implementation alertMedicationTableViewDatasourceDelegate

#pragma mark UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    UITableViewCell  *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

    cell.textLabel.text = @"Test";
    
    return cell;
}


@end
