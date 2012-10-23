//
//  FSPTveProviderButton.m
//  FoxSportsTVEHarness
//
//  Created by Joshua Dubey on 5/3/12.
//  Copyright (c) 2012 Übermind, Inc. All rights reserved.
//

#import "FSPTveProviderButton.h"

#import <QuartzCore/QuartzCore.h>

@implementation FSPTveProviderButton

@synthesize provider = _provider;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
		self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 2;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.cornerRadius = 5;
    }
    return self;
}

- (void)setProvider:(MVPD *)provider
{
    _provider = provider;
    
    if (_provider != nil) {
        [self loadImageWithUrl:_provider.logoURL];
    }
}

- (void)loadImageWithUrl:(NSString *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:60.0f];
    [NSURLConnection sendAsynchronousRequest:request 
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               UIImage *logoImage = [UIImage imageWithData:data];
                               [self setImage:logoImage forState:UIControlStateNormal];
                               UIEdgeInsets insets = UIEdgeInsetsMake((self.frame.size.height - logoImage.size.height) / 2, (self.frame.size.width - logoImage.size.width) / 2, (self.frame.size.height - logoImage.size.height) / 2, (self.frame.size.width - logoImage.size.width) / 2);
                               [self setImageEdgeInsets:insets];

                           }];
}

@end
