//
//  VVDraggableCollectionViewLayout.m
//  VVDraggableDualCollectionView
//
//  Created by Vivi Yang on 8/1/16.
//  Copyright © 2016 Vivi Yang. All rights reserved.
//

#import "VVDraggableCollectionViewLayout.h"

#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

@interface VVDraggableCollectionViewLayout ()

@property (assign, nonatomic) CGFloat maxChangeInHeight;

@end

@implementation VVDraggableCollectionViewLayout


#pragma mark - Required methods

/// Returns the width and height of the collection view’s contents. These values represent the width and height of all the content, not just the content that is currently visible. The collection view uses this information to configure its own content size for scrolling purposes.
- (CGSize)collectionViewContentSize {
    
    CGFloat width = self.cellSize.width * [self.collectionView numberOfItemsInSection:0];
    return CGSizeMake(width, CGRectGetHeight(self.collectionView.bounds));
}

/// Return layout information for all items whose view intersects the specified rectangle. Your implementation should return attributes for all visual elements, including cells, supplementary views, and decoration views.
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *arrayOfAttributes = [NSMutableArray array];
    
    // Loop through each section and see if rect intersects any header / cell
    
    // Loop through all cells
    for (int index = 0; index < [self.collectionView numberOfItemsInSection:0]; index++) {
        
        NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
        UICollectionViewLayoutAttributes *cellAttributes = [self layoutAttributesForItemAtIndexPath:cellIndexPath];
        
        if (CGRectIntersectsRect(cellAttributes.frame, rect)) {
            [arrayOfAttributes addObject:cellAttributes];
        }
    }
    
    return arrayOfAttributes;
}

/// Return layout information for items in the collection view. You use this method to provide layout information only for items that have a corresponding cell. Do not use it for supplementary views or decoration views.
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat x, y, w, h;
    
    if (!self.indexPathOfFocusedCell) {
        attributes.frame = CGRectMake(indexPath.item * self.cellSize.width, 0, self.cellSize.width, self.cellSize.height);
        return attributes;
    }
    
    if (self.layoutMode == layoutModeSmall) {
        
        // ENLARGE THE FOCUSED CELL
        
        // Calculate the frame of focused cell first because we need to reference the x and width for non-focused cells
        h = self.smallCellSize.height + MIN(self.changeInHeight, self.maxChangeInHeight);
        w = self.smallCellSize.width / self.smallCellSize.height * h;
        y = - (h - CGRectGetHeight(self.collectionView.frame));
        
        if (self.indexPathOfFocusedCell.item == 0 && self.collectionView.contentOffset.x == 0) {
            x = 0;
            
        } else if (self.indexPathOfFocusedCell.item == [self.collectionView numberOfItemsInSection:0] - 1 && self.collectionView.contentOffset.x == self.collectionView.contentSize.width - self.smallCellSize.width) {
            x = self.collectionView.contentSize.width - w;
            
        } else {
            // a1: distance between contentOffset.x and minimum x of focused cell
            CGFloat a1 = self.indexPathOfFocusedCell.item * self.smallCellSize.width - self.collectionView.contentOffset.x;
            
            CGFloat changeInW = MIN(self.changeInHeight, self.maxChangeInHeight) * self.smallCellSize.width / self.smallCellSize.height;
            
            // w1: distance to add to the left of focused cell
            CGFloat w1 = (a1 * changeInW) / (CGRectGetWidth(self.collectionView.frame) - self.smallCellSize.width);
            
            x = self.indexPathOfFocusedCell.item * self.smallCellSize.width - w1;
        }
        
        if (![indexPath isEqual:self.indexPathOfFocusedCell]) {
            
            NSInteger difference = ABS(indexPath.item - self.indexPathOfFocusedCell.item);
            
            if (indexPath.item < self.indexPathOfFocusedCell.item) {
                // The cell is located BEFORE (to the LEFT of) selected cell
                x = x - difference * self.smallCellSize.width;
                
            } else {
                // The cell is located AFTER (to the RIGHT of) selected cell
                x = x + w + (difference - 1) * self.smallCellSize.width;
            }
            
            y = 0;
            w = self.smallCellSize.width;
            h = self.smallCellSize.height;
        }
        
        attributes.frame = CGRectMake(x, y, w, h);
    }
    
    if (self.layoutMode == layoutModeIntermediate) {
        
        x = self.collectionView.contentOffset.x;
        w = self.largeCellSize.width;
        h = self.largeCellSize.height;
        y = 0;
        
        if (![indexPath isEqual:self.indexPathOfFocusedCell]) {
            
            NSInteger difference = ABS(indexPath.item - self.indexPathOfFocusedCell.item);
            
            if (indexPath.item < self.indexPathOfFocusedCell.item) {
                // The cell is located BEFORE (to the LEFT of) selected cell
                x = x - difference * self.smallCellSize.width;
            } else {
                // The cell is located AFTER (to the RIGHT of) selected cell
                x = x + w + (difference - 1) * self.smallCellSize.width;
            }
            
            w = self.smallCellSize.width;
            h = self.smallCellSize.height;
            y = self.largeCellSize.height - h;
        }
        
        attributes.frame = CGRectMake(x, y, w, h);
    }
    
    
    if (self.layoutMode == layoutModeLarge) {
        
        // If self.changeInHeight is greater than 0, we want cells that are not focused to have small size
        if (self.changeInHeight > 0) {
            
            h = self.largeCellSize.height - MIN(self.maxChangeInHeight + self.maximumShrinkHeight, self.changeInHeight);
            w = self.largeCellSize.width / self.largeCellSize.height * h;
            y = self.largeCellSize.height - h;
            
            CGFloat focusedX;
            if (self.indexPathOfFocusedCell.item == 0) {
                focusedX = 0;
                
            } else if (self.indexPathOfFocusedCell.item == [self.collectionView numberOfItemsInSection:0] - 1) {
                focusedX = self.collectionView.contentSize.width - w;
                
            } else {
                focusedX = self.collectionView.contentOffset.x + (CGRectGetWidth(self.collectionView.frame) - w) / 2.0;
            }
            
            // SHRINK the cell
            if ([indexPath isEqual:self.indexPathOfFocusedCell]) {
                x = focusedX;
                
            } else {
                NSInteger difference = ABS(indexPath.item - self.indexPathOfFocusedCell.item);
                
                if (indexPath.item < self.indexPathOfFocusedCell.item) {
                    // The cell is located BEFORE (to the LEFT of) selected cell
                    x = focusedX - difference * self.smallCellSize.width;
                    
                } else {
                    // The cell is located AFTER (to the RIGHT of) selected cell
                    x = focusedX + w + (difference - 1) * self.smallCellSize.width;
                }
                
                w = self.smallCellSize.width;
                h = self.smallCellSize.height;
                y = CGRectGetHeight(self.collectionView.frame) - h;
            }
        } else {
            // If self.changeInHeight is 0, we want all cells to have large size

            x = self.largeCellSize.width * indexPath.item;
            y = 0;
            w = self.largeCellSize.width;
            h = self.largeCellSize.height;
        }
        
        attributes.frame = CGRectMake(x, y, w, h);
    }
    
    return attributes;
}

/// Return YES if the collection view requires a layout update or NO if the layout does not need to change. Subclasses can override it and return an appropriate value based on whether changes in the bounds of the collection view require changes to the layout of cells and supplementary views.
- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    return YES;
}


#pragma mark - Optional methods

/// Layout updates occur the first time the collection view presents its content and whenever the layout is invalidated explicitly or implicitly because of a change to the view. During each layout update, the collection view calls this method first to give your layout object a chance to prepare for the upcoming layout operation.
- (void)prepareLayout {
    [super prepareLayout];
    
    if (CGSizeEqualToSize(self.cellSize, CGSizeZero)) {
        self.cellSize = CGSizeMake(CGRectGetWidth(self.collectionView.frame) / 2.5, CGRectGetWidth(self.collectionView.frame) / 2.5 / 3.0 * 4.0);
    }
    
    if (self.maxChangeInHeight == 0) {
        self.maxChangeInHeight = self.largeCellSize.height - self.smallCellSize.height;
    }
    
}

@end
