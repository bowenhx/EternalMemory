//
//  AddOperationTableViewHandler.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-15.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "AddOperationTableViewHandler.h"
#import "GenealogyMemberEditorViewController.h"

@implementation AddOperationTableViewHandler

- (void)dealloc
{
    [_items release];
    [_textLabelAttributes release];
    [super dealloc];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer] autorelease];
        cell.textLabel.font = _textLabelAttributes[kLabelAttributesTextFont];
        cell.textLabel.textColor = _textLabelAttributes[kLabelAttributesTextColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSInteger row = indexPath.row;
    
    cell.textLabel.text = self.items[row];
    
    return cell;
}


#pragma mark UITableViewDelegate



@end
