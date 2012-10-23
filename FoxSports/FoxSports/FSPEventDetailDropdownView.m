//
//  FSPEventDetailDropdownView.m
//  FoxSports
//
//  Created by greay on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventDetailDropdownView.h"
#import "FSPSegmentedNavigationControl.h"
#import "FSPAppDelegate.h"
#import "FSPRootViewController.h"

#import "UIFont+FSPExtensions.h"

@interface FSPEventDetailDropdownView ()
@property (nonatomic, strong) NSMutableArray *options;

- (NSString *)titleForSuboptionAtIndex:(NSUInteger)index;
@end


@implementation FSPEventDetailDropdownView
@synthesize navigationControl;
@synthesize options;
@synthesize selectedOptionIndex = _selectedOptionIndex;
@synthesize selectedSuboptionIndex = _selectedSuboptionIndex;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.options = [NSMutableArray array];

		[self.button addTarget:self action:@selector(showOptions:) forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}

//- (void)layoutSubviews
//{
//	[super layoutSubviews];
//	self.button.frame = self.bounds;
//}

- (NSString *)buttonTitle
{
	NSString *title = [self titleForOptionAtIndex:self.selectedOptionIndex];
	NSString *subtitle = [self titleForSuboptionAtIndex:self.selectedSuboptionIndex];
	if (subtitle) {
		title = [title stringByAppendingFormat:@" > %@", [self titleForSuboptionAtIndex:self.selectedSuboptionIndex]];
	}
	return title;
}

- (void)insertOptionWithTitle:(NSString *)title atIndex:(NSUInteger)index
{
	[self.options insertObject:[NSMutableArray arrayWithObject:title] atIndex:index];
}

- (void)removeOptionAtIndex:(NSUInteger)index
{
	[self.options removeObjectAtIndex:index];
}

- (void)removeAllOptions
{
	[self.options removeAllObjects];
}

- (void)setOptionTitle:(NSString *)title atIndex:(NSUInteger)index
{
	NSMutableArray *section = [self.options objectAtIndex:index];
	[section replaceObjectAtIndex:0 withObject:title];
}

- (NSUInteger)numberOfOptions
{
	return [self.options count];
}

- (NSString *)titleForOptionAtIndex:(NSUInteger)index
{
	NSMutableArray *section = [self.options objectAtIndex:index];
	return [section objectAtIndex:0];
}

- (NSString *)titleForSuboptionAtIndex:(NSUInteger)index
{
	NSString *title = nil;
	
	NSMutableArray *section = [self.options objectAtIndex:self.selectedOptionIndex];
	if ([section count] > 1 && self.selectedSuboptionIndex + 1 < [section count]) {
		title = [section objectAtIndex:self.selectedSuboptionIndex + 1];
	}
	return title;
}

- (NSUInteger)selectedOptionIndex
{
	return _selectedOptionIndex;
}

- (void)setSelectedOptionIndex:(NSUInteger)selectedOptionIndex
{
	if (selectedOptionIndex < [self.self numberOfOptions]) {
		_selectedOptionIndex = selectedOptionIndex;
		[self setButtonTitle:(NSString *)[self buttonTitle]];
	} else {
		_selectedOptionIndex = NSNotFound;
	}
}

- (NSUInteger)selectedSuboptionIndex
{
	return _selectedSuboptionIndex;
}

- (void)setSelectedSuboptionIndex:(NSUInteger)selectedSuboptionIndex
{
	NSMutableArray *section = [self.options objectAtIndex:self.selectedOptionIndex];
	
	if (selectedSuboptionIndex < [section count] - 1) {
		_selectedSuboptionIndex = selectedSuboptionIndex;
		[self setButtonTitle:[self buttonTitle]];
	} else {
		_selectedSuboptionIndex = NSNotFound;
	}
}

- (void)setSubOptions:(NSArray *)subOptions forSection:(NSUInteger)index;
{
	NSMutableArray *section = [self.options objectAtIndex:index];
	if ([section count] > 1) {
		[section removeObjectsInRange:NSMakeRange(1, [section count] - 1)];
	}
	[section addObjectsFromArray:subOptions];
	[self.options replaceObjectAtIndex:index withObject:section];
}


- (void)showOptions:(id)sender
{
	UITableViewController *tvc = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
	tvc.tableView.delegate = self;
	tvc.tableView.dataSource = self;
	
	tvc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelOptions:)];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tvc];
	
	FSPAppDelegate *appDelegate = (FSPAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.rootViewController presentViewController:navController animated:YES completion:NULL];
}

- (void)cancelOptions:(id)sender
{
	FSPAppDelegate *appDelegate = (FSPAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.rootViewController dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.options count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)index
{
	NSMutableArray *section = [self.options objectAtIndex:index];
	if ([section count] == 1) {
		return 1;
	} else {
		return [section count] - 1;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)index
{
	NSMutableArray *section = [self.options objectAtIndex:index];
	if ([section count] == 1) {
		return nil;
	} else {
		return [section objectAtIndex:0];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	}
	NSString *title = nil;
	NSMutableArray *section = [self.options objectAtIndex:indexPath.section];
	if ([section count] == 1) {
		title = [section objectAtIndex:0];
	} else {
		title = [section objectAtIndex:indexPath.row + 1];
	}

	cell.textLabel.text = title;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.selectedOptionIndex = indexPath.section;
	self.selectedSuboptionIndex = indexPath.row;

	FSPAppDelegate *appDelegate = (FSPAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.rootViewController dismissViewControllerAnimated:YES completion:^{
		[self.navigationControl sendActionsForControlEvents:UIControlEventValueChanged];
	}];
}

@end
