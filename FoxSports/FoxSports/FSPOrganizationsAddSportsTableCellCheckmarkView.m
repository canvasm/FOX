//
//  FSPOrganizationsAddSportsTableCellCheckmarkView.m
//  FoxSports
//
//  Created by Ed McKenzie on 7/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPOrganizationsAddSportsTableCellCheckmarkView.h"

@interface FSPOrganizationsAddSportsTableCellCheckmarkView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) BOOL observing;

@end

@implementation FSPOrganizationsAddSportsTableCellCheckmarkView

@synthesize imageView = _imageView;
@synthesize observing = _observing;

- (void)awakeFromNib {
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:self.imageView];
    self.selected = NO;
    if (!_observing) {
        [self addObserver:self
               forKeyPath:@"selected"
                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial)
                  context:NULL];
        _observing = YES;
    }
}

- (void)dealloc {
    if (_observing) {
        [self removeObserver:self forKeyPath:@"selected"];
        _observing = NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selected"]) {
        NSNumber *selectedValue = [change objectForKey:NSKeyValueChangeNewKey];
        if ([selectedValue isKindOfClass:NSNumber.class]) {
            self.imageView.image = [UIImage imageNamed:(selectedValue.boolValue ?
                                                        @"checkmark" : @"empty_circle")];
        }
    }
}

@end
