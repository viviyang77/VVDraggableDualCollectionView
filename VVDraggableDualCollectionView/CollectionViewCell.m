//
//  CollectionViewCell.m
//  VVDraggableDualCollectionView
//
//  Created by Vivi Yang on 8/1/16.
//  Copyright © 2016 Vivi Yang. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell


- (instancetype)initWithFrame:(CGRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
        self.label.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont fontWithName:@"Avenir Next" size:14];
        self.label.clipsToBounds = YES;
        self.label.layer.cornerRadius = 40;
        
        [self.contentView addSubview:self.label];
    }
    return self;
}

@end
