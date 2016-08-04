//
//  VVDraggableCollectionViewLayout.h
//  VVDraggableDualCollectionView
//
//  Created by Vivi Yang on 8/1/16.
//  Copyright © 2016 Vivi Yang. All rights reserved.
//
//  NOTE: This layout class is designed for ONE SINGLE SECTION ONLY and NO SUPPLEMENTARY / DECORATION VIEW

#import <UIKit/UIKit.h>

@interface VVDraggableCollectionViewLayout : UICollectionViewFlowLayout


/// This layout class is designed for ONE SINGLE SECTION ONLY and NO SUPPLEMENTARY / DECORATION VIEW

typedef enum {
    layoutModeSmall,
    layoutModeIntermediate,
    layoutModeLarge
} layoutMode;

@property (assign, nonatomic) CGSize cellSize;

@property (assign, nonatomic) CGSize smallCellSize;
@property (assign, nonatomic) CGSize largeCellSize;

@property (strong, nonatomic) NSIndexPath *indexPathOfFocusedCell;

@property (assign, nonatomic) layoutMode layoutMode;

// -------------------------

/// A negative value of `changeInHeight` indicates that user is shrinking the cell to be even smaller than small cell size.
@property (assign, nonatomic) CGFloat changeInHeight;

/// Defines the maximum vertical distance that can be reduced from height of small cell.
/// (If height of small cell is x, the height of a cell can be shrinked to at most x - maximumShrinkHeight)
@property (assign, nonatomic) CGFloat maximumShrinkHeight;

@end

