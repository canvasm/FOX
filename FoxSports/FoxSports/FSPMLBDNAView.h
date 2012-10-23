//
//  FSPMLBDNAView.h
//  FoxSports
//
//  Created by Jeremy Eccles on 2012-10-17.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPMLBDNAView : UIView <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *_tableView;
}

@property (nonatomic, retain) UITableView *_tableView;

@end
