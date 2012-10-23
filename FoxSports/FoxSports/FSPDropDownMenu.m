//
//  FSPDropDownMenu.m
//  FoxSports
//
//  Created by Chase Latta on 3/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPDropDownMenu.h"
#import "FSPDropDownMenuItem.h"
#import "FSPDropDownCell.h"
#import "FSPPrimarySegmentedControl.h"
#import "FSPSegmentedNavigationControl.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

@interface FSPDropDownMenu ()
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) FSPSegmentedNavigationControl *navigationView;
@property (nonatomic, strong) UIView *segmentedControlContainer;

- (void)setupViews;
- (void)segmentDidChange:(id)sender;
@end

@implementation FSPDropDownMenu
@synthesize sections;
@synthesize segments;
@synthesize delegate;
@synthesize tableView;
@synthesize navigationView;
@synthesize segmentedControlContainer;

- (CGFloat)sectionsHeight;
{
    return self.tableView.bounds.size.height;
}

+ (id)dropDownMenuWithSections:(NSArray *)sectionItems segments:(NSArray *)segmentItems;
{
    return [[self alloc] initWithSections:sectionItems segments:segmentItems];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithSections:nil segments:nil];
}

- (id)initWithSections:(NSArray *)sectionItems segments:(NSArray *)segmentItems;
{
    CGRect frame = CGRectNull;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(0, 0, 286.0, 100);
    } else {
        frame = CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, 100);        
    }
        
    self = [super initWithFrame:frame];
    if (self) {
        self.segments = segmentItems;
        self.sections = [sectionItems mutableCopy];
        self.backgroundColor = [UIColor clearColor];
        [self setupViews];
    }
    return self;
}

#pragma mark - :: View Setup ::
- (void)setupViews;
{
    // Constants
    static CGFloat rowHeight = 38.0;
    CGFloat segmentHeight = 0.0;
    
    // Setup the tableview
    CGFloat tableHeight = [self.sections count] * rowHeight;
    UITableView *sectionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, tableHeight) style:UITableViewStylePlain];
    sectionTableView.dataSource = self;
    sectionTableView.delegate = self;
    sectionTableView.scrollEnabled = NO;
    sectionTableView.rowHeight = rowHeight;
    sectionTableView.backgroundColor = [UIColor colorWithRed:9/255.0f green:33/255.0f blue:73/255.0f alpha:1.000];
    sectionTableView.accessibilityIdentifier = @"dropDownMenu";
	sectionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Add the drop shadow
    UIImage *shadowImage = [UIImage imageNamed:@"dropdown_shadow"];
    CGRect tableFrame = sectionTableView.frame;
    UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(tableFrame.origin.x, tableFrame.origin.y, tableFrame.size.width, shadowImage.size.height)];
    shadowImageView.image = shadowImage;
    UIImageView *bottomShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(tableFrame.origin.x, CGRectGetMaxY(tableFrame) - 7, tableFrame.size.width, shadowImage.size.height)];
    shadowImageView.image = shadowImage;
    bottomShadowImageView.image = shadowImage;
    
    [self addSubview:sectionTableView];
    
    // Images don't look correct at this time
//    [self addSubview:shadowImageView];
//    [self addSubview:bottomShadowImageView];
    self.tableView = sectionTableView;
    
    if ([self.segments count] > 0) {
        
        segmentHeight = FSPNavigationViewPreferredHeight;

        // Setup the segmented control
        segmentedControlContainer = [[UIView alloc] initWithFrame:CGRectMake(0, sectionTableView.frame.size.height, self.bounds.size.width, segmentHeight)];
        segmentedControlContainer.backgroundColor = [UIColor fsp_darkBlueColor];
        
        if ([self.segments count] > 1) {
            // Use a segemented control
            navigationView = [[FSPSegmentedNavigationControl alloc] initWithFrame:segmentedControlContainer.bounds];
            for (NSUInteger i = 0; i < self.segments.count; i++) {
                [navigationView insertSegmentWithTitle:((FSPDropDownMenuItem *)[self.segments objectAtIndex:i]).menuTitle atIndex:i animated:NO];
            }
            navigationView.accessibilityIdentifier = @"chipController";
            [segmentedControlContainer addSubview:navigationView];
            navigationView.selectedSegmentIndex = 0;
            [navigationView addTarget:self action:@selector(segmentDidChange:)];
        } else if ([self.segments count] == 1) {
            //Hide control container if there is only one segment
            segmentedControlContainer.frame = CGRectZero;
        }
        
        [self addSubview:segmentedControlContainer];
    }
    
    CGRect bounds = self.bounds;
    bounds.size.height = tableHeight + segmentHeight;
    self.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
}

#pragma mark - :: TableView Management ::
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [self.sections count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString * const Identifier = @"CELL";
    FSPDropDownCell *cell = (FSPDropDownCell *)[aTableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[FSPDropDownCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.textLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14.0];
		cell.textLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
		cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
		
		UIView *highlight = [[UIView alloc] init];
		highlight.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[cell addSubview:highlight];
        cell.drawTopDivider = YES;
        cell.drawBottomDivider = YES;
    }
    if (indexPath.row == 0)
        ((FSPDropDownCell *)cell).drawTopDivider = NO;
    if (indexPath.row >= (NSInteger)[self.sections count])
        ((FSPDropDownCell *)cell).drawBottomDivider = NO;

    cell.textLabel.text = ((FSPDropDownMenuItem *)[self.sections objectAtIndex:indexPath.row]).menuTitle;
	if ([self.delegate respondsToSelector:@selector(dropDownMenu:iconForSectionAtIndex:)]) {
		cell.imageView.image = [self.delegate dropDownMenu:self iconForSectionAtIndex:indexPath.row];
	}
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ([self.delegate respondsToSelector:@selector(dropDownMenu:didSelectSectionAtIndex:)]) {
        [self.delegate dropDownMenu:self didSelectSectionAtIndex:indexPath.row];
    }
    
    FSPDropDownMenuItem *item = [self.sections objectAtIndex:indexPath.row];
    if (item.selectionAction) item.selectionAction([aTableView cellForRowAtIndexPath:indexPath]);
    
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - :: Segment Management ::
- (void)segmentDidChange:(FSPSegmentedNavigationControl *)sender;
{
	NSInteger newSegment = sender.selectedSegmentIndex;
    if ([self.delegate respondsToSelector:@selector(dropDownMenu:didSelectSegmentAtIndex:)]) {
        [self.delegate dropDownMenu:self didSelectSegmentAtIndex:newSegment];
    }
    
    FSPDropDownMenuItem *item = [self.segments objectAtIndex:newSegment];
    if (item.selectionAction) item.selectionAction(sender);
}

- (void)updateSegments:(NSArray *)segmentItems
{
    self.segments = segmentItems;
    if ([self.segments count] > 1) {
        for (NSUInteger i = 0; i < self.segments.count; i++) {
            [navigationView setSegmentTitle:((FSPDropDownMenuItem *)[self.segments objectAtIndex:i]).menuTitle atIndex:i];
        }
        navigationView.selectedSegmentIndex = 0;
    } 
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    self.navigationView.selectedSegmentIndex = selectedSegmentIndex;
}

- (NSInteger )selectedSegmentIndex
{
    return self.navigationView.selectedSegmentIndex;
}

#pragma mark - :: Section Management ::
- (void)updateSectionName:(NSString *)sectionName atIndex:(NSInteger)index;
{
	if (index < 0) return;
    ((FSPDropDownMenuItem *)[self.sections objectAtIndex:index]).menuTitle = sectionName;
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)reloadSectionAtIndex:(NSInteger)index;
{
    // TODO: not sure why reloading this index doesn't work, but it's in there somewhere due to using notifications that are firing before favorting has a chance to finish propoagting
    [self.tableView reloadData];
//	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//	[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
