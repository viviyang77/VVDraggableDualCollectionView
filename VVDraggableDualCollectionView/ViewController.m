//
//  ViewController.m
//  VVDraggableDualCollectionView
//
//  Created by Vivi Yang on 8/1/16.
//  Copyright © 2016 Vivi Yang. All rights reserved.
//

#import "ViewController.h"
#import "VVDraggableCollectionViewLayout.h"

#import "CollectionViewCell.h"

#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

#define SMALL_CELL_SIZE CGSizeMake(SCREEN_WIDTH / 2.5, SCREEN_WIDTH / 2.5 / 2.0 * 3.0)
#define LARGE_CELL_SIZE CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH / 2.0 * 3.0)

#define MAXIMUM_SHINK_HEIGHT_FOR_CELL 15.0

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>
{
    NSIndexPath *indexPathOfFocusedCell;    // used for pan gesture recognizer in collection view
}
@property (strong, nonatomic) UICollectionView *smallCollectionView;
@property (strong, nonatomic) UICollectionView *largeCollectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIColletionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"Cell #%ld", (long)indexPath.item];
    cell.tag = indexPath.item;
    
    switch (indexPath.item % 3) {
        case 0:
            cell.backgroundColor = [UIColor redColor];
            break;
            
        case 1:
            cell.backgroundColor = [UIColor yellowColor];
            break;
            
        case 2:
            cell.backgroundColor = [UIColor greenColor];
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.smallCollectionView]) {
        indexPathOfFocusedCell = indexPath;
        [self enlargeFocusedCellToLargeSize];
        
        return;
        
    } else {
        // Large collection view cell
        
        VVDraggableCollectionViewLayout *layout = (VVDraggableCollectionViewLayout *)self.largeCollectionView.collectionViewLayout;
        layout.indexPathOfFocusedCell = indexPath;
        
        // Set the layoutMode to intermediate so that cells other than focused cell will be shrinked to small size
        layout.layoutMode = layoutModeIntermediate;
        
        [self.largeCollectionView performBatchUpdates:^{
            [layout invalidateLayout];
            
        } completion:^(BOOL finished) {
            
            layout.layoutMode = layoutModeLarge;
            layout.changeInHeight = LARGE_CELL_SIZE.height - SMALL_CELL_SIZE.height;
            
            [self.largeCollectionView performBatchUpdates:^{
                [self.largeCollectionView setCollectionViewLayout:layout animated:YES];
                
            } completion:^(BOOL finished) {
                
                // Show a separate small collection view
                [self.smallCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                
                self.smallCollectionView.alpha = 1;
                self.largeCollectionView.alpha = 0;
                
                layout.indexPathOfFocusedCell = nil;
                [layout invalidateLayout];
            }];
        }];
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.smallCollectionView) {
        return SMALL_CELL_SIZE;
    } else {
        return LARGE_CELL_SIZE;
    }
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0;
    
}

#pragma mark - UIGestureRecognizerDelegate methods

/// Return YES to allow both gestureRecognizer and otherGestureRecognizer to recognize their gestures simultaneously. The default implementation returns NO—no two gestures can be recognized simultaneously.
/// This method is called when recognition of a gesture by either gestureRecognizer or otherGestureRecognizer would block the other gesture recognizer from recognizing its gesture. Note that returning YES is guaranteed to allow simultaneous recognition; returning NO, on the other hand, is not guaranteed to prevent simultaneous recognition because the other gesture recognizer's delegate may return YES.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

#pragma mark - Private methods
- (void)setupView {
    
    CGFloat x, y, w, h;
    
    // Small collection view
    
    x = 0;
    w = SCREEN_WIDTH;
    h = SCREEN_WIDTH / 2.5 / 2.0 * 3.0;
    y = SCREEN_HEIGHT - h;
    
    VVDraggableCollectionViewLayout *layout = [[VVDraggableCollectionViewLayout alloc] init];
    layout.cellSize = SMALL_CELL_SIZE;
    layout.smallCellSize = SMALL_CELL_SIZE;
    layout.largeCellSize = LARGE_CELL_SIZE;
    layout.layoutMode = layoutModeSmall;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.maximumShrinkHeight = MAXIMUM_SHINK_HEIGHT_FOR_CELL;
    
    self.smallCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(x, y, w, h) collectionViewLayout:layout];
    self.smallCollectionView.dataSource = self;
    self.smallCollectionView.delegate = self;
    [self.smallCollectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    self.smallCollectionView.clipsToBounds = NO;
    self.smallCollectionView.backgroundColor = [UIColor clearColor];
    
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
    panGR.maximumNumberOfTouches = 1;
    panGR.minimumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.smallCollectionView addGestureRecognizer:panGR];
    
    [self.view addSubview:self.smallCollectionView];
    
    
    // Large collection view
    x = 0;
    w = SCREEN_WIDTH;
    h = SCREEN_WIDTH / 2.0 * 3.0;
    y = SCREEN_HEIGHT - h;
    
    VVDraggableCollectionViewLayout *largeLayout = [[VVDraggableCollectionViewLayout alloc] init];
    largeLayout.cellSize = LARGE_CELL_SIZE;
    largeLayout.smallCellSize = SMALL_CELL_SIZE;
    largeLayout.largeCellSize = LARGE_CELL_SIZE;
    largeLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    largeLayout.layoutMode = layoutModeLarge;
    largeLayout.maximumShrinkHeight = MAXIMUM_SHINK_HEIGHT_FOR_CELL;
    
    self.largeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(x, y, w, h) collectionViewLayout:largeLayout];
    self.largeCollectionView.dataSource = self;
    self.largeCollectionView.delegate = self;
    [self.largeCollectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    self.largeCollectionView.alpha = 0;
    self.largeCollectionView.pagingEnabled = YES;
    self.largeCollectionView.backgroundColor = [UIColor clearColor];
    
    UIPanGestureRecognizer *panGR2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
    panGR2.maximumNumberOfTouches = 1;
    panGR2.minimumNumberOfTouches = 1;
    panGR2.delegate = self;
    [self.largeCollectionView addGestureRecognizer:panGR2];
    
    [self.view addSubview:self.largeCollectionView];
}

- (void)userDidPan:(UIPanGestureRecognizer *)panGR {
    
    if (panGR.view == self.smallCollectionView) {
        /// The translation of the pan gesture in the coordinate system of the specified view.
        /// The x and y values report the total translation over time. They are not delta values from the last time that the translation was reported. Apply the translation value to the state of the view when the gesture is first recognized—do not concatenate the value each time the handler is called.
        CGPoint changePoint = [panGR translationInView:self.view];
        
        // Determine the cell that's being panned
        
        if (panGR.state == UIGestureRecognizerStateBegan) {
            
            CGPoint pointInCollectionView = [panGR locationInView:self.smallCollectionView];
            NSIndexPath *indexPath = [self.smallCollectionView indexPathForItemAtPoint:pointInCollectionView];
            indexPathOfFocusedCell = indexPath;
            
            // If the gesture's direction is mostly horizontal, only let the collectionView's own pan GR recognize
            CGPoint velocityPoint = [panGR velocityInView:panGR.view];
            
            if (fabs(velocityPoint.y) > fabs(velocityPoint.x)) {                
                // If the gesture's direction is mostly vertical, only let the panGR recognize the touch
                
                // Disable collectionView's pan GR so that it won't recognize this touch
                self.smallCollectionView.panGestureRecognizer.enabled = NO;
                
                // Re-enable collectionView's pan GR so that it can recognize the next touch
                self.smallCollectionView.panGestureRecognizer.enabled = YES;
                
            } else {
                // Panning horizontally
                
                // Disable the panGR so that it won't recognize this touch
                panGR.enabled = NO;
                
                // Re-enable the panGR so that it can recognize the next touch
                panGR.enabled = YES;
            }

        }
        
        if (panGR.state == UIGestureRecognizerStateChanged) {
            
            VVDraggableCollectionViewLayout *layout = (VVDraggableCollectionViewLayout *)self.smallCollectionView.collectionViewLayout;
            layout.indexPathOfFocusedCell = indexPathOfFocusedCell;
            layout.changeInHeight = MAX(-MAXIMUM_SHINK_HEIGHT_FOR_CELL, -changePoint.y);   // a negative value of y indicates it's panning upwards ==> we want the distance so add a minus sign

            [layout invalidateLayout];
        }
        
        if (panGR.state == UIGestureRecognizerStateEnded) {
            
            if (-changePoint.y <= 50) {
                // If change in height is less than 50, make the cell back to small size
                [self shrinkFocusedCellToSmallSize];
                
            } else if (-changePoint.y > LARGE_CELL_SIZE.height - SMALL_CELL_SIZE.height - 50) {
                // If final height is less than 0 points away from max height, make the cell size to large size
                [self enlargeFocusedCellToLargeSize];
            } else {
                // Determine whether to enlarge or shrink cell based on the last pan direction
                CGPoint velocity = [panGR velocityInView:self.view];
                
                if (velocity.y > 0) {
                    // Panning downwards
                    [self shrinkFocusedCellToSmallSize];
                    
                } else {
                    // Panning upwards
                    [self enlargeFocusedCellToLargeSize];
                }
            }
        }
        
    } // end of if (panGR.view == self.smallCollectionView)
    
    
    if (panGR.view == self.largeCollectionView) {
        
        CGPoint point = [panGR translationInView:self.view];
        
        if (panGR.state == UIGestureRecognizerStateBegan) {
            
            CGPoint pointInCollectionView = [panGR locationInView:self.largeCollectionView];
            NSIndexPath *indexPath = [self.largeCollectionView indexPathForItemAtPoint:pointInCollectionView];
            indexPathOfFocusedCell = indexPath;
            
            // If the gesture's direction is mostly horizontal, only let the collectionView's own pan GR recognize
            if (fabs(point.y) < 1) {
                
                // Disable the panGR so that it won't recognize this touch
                panGR.enabled = NO;
                
                // Re-enable the panGR so that it can recognize the next touch
                panGR.enabled = YES;
            } else {
                // If the gesture's direction is mostly vertical, only let the panGR recognize the touch
                
                // Disable collectionView's pan GR so that it won't recognize this touch
                self.largeCollectionView.panGestureRecognizer.enabled = NO;
                
                // Re-enable collectionView's pan GR so that it can recognize the next touch
                self.largeCollectionView.panGestureRecognizer.enabled = YES;
            }
            
        }
        
        if (panGR.state == UIGestureRecognizerStateChanged) {
            
            VVDraggableCollectionViewLayout *layout = (VVDraggableCollectionViewLayout *)self.largeCollectionView.collectionViewLayout;
            
            layout.indexPathOfFocusedCell = indexPathOfFocusedCell;
            layout.changeInHeight = MIN((LARGE_CELL_SIZE.height - SMALL_CELL_SIZE.height) + MAXIMUM_SHINK_HEIGHT_FOR_CELL, point.y);   // a positive value of y indicates it's panning downwards
            
            [layout invalidateLayout];
        }
        
        if (panGR.state == UIGestureRecognizerStateEnded) {
            
            // If change in height is less than 50, make the cell back to small size
            if (point.y > LARGE_CELL_SIZE.height - SMALL_CELL_SIZE.height - 50) {
                [self shrinkFocusedCellToSmallSize];
                
            } else if (point.y <= 50) {
                // If final height is less than 0 points away from max height, make the cell size to large size
                [self enlargeFocusedCellToLargeSize];
                
            } else {
                // Determine whether to enlarge or shrink cell based on the last pan direction
                CGPoint velocity = [panGR velocityInView:self.view];
                
                if (velocity.y >0) {
                    // Panning downwards
                    [self shrinkFocusedCellToSmallSize];
                } else {
                    // Panning upwards
                    [self enlargeFocusedCellToLargeSize];
                }
            }
        }
    }
}

- (void)shrinkFocusedCellToSmallSize {
    
    VVDraggableCollectionViewLayout *layout;
    
    if (self.smallCollectionView.alpha > 0) {
        layout = (VVDraggableCollectionViewLayout *)self.smallCollectionView.collectionViewLayout;
        layout.changeInHeight = 0;
        layout.indexPathOfFocusedCell = indexPathOfFocusedCell;
        
        [self.smallCollectionView performBatchUpdates:^{
            [self.smallCollectionView setCollectionViewLayout:layout animated:YES];
            
        } completion:^(BOOL finished) {
        }];
        
    } else {
        layout = (VVDraggableCollectionViewLayout *)self.largeCollectionView.collectionViewLayout;
        layout.changeInHeight = LARGE_CELL_SIZE.height - SMALL_CELL_SIZE.height;
        layout.indexPathOfFocusedCell = indexPathOfFocusedCell;
        
        [self.largeCollectionView performBatchUpdates:^{
            [self.largeCollectionView setCollectionViewLayout:layout animated:YES];
            
        } completion:^(BOOL finished) {
            
            // Show a separate small collection view
            [self.smallCollectionView scrollToItemAtIndexPath:indexPathOfFocusedCell atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            
            [UIView animateWithDuration:0.2 animations:^{
                self.smallCollectionView.alpha = 1;
                
            } completion:^(BOOL finished) {
                self.largeCollectionView.alpha = 0;
                
                layout.indexPathOfFocusedCell = nil;
                [layout invalidateLayout];
            }];
        }];
    }
}

- (void)enlargeFocusedCellToLargeSize {
    
    VVDraggableCollectionViewLayout *layout;
    
    if (self.smallCollectionView.alpha > 0) {
        layout = (VVDraggableCollectionViewLayout *)self.smallCollectionView.collectionViewLayout;
        layout.indexPathOfFocusedCell = indexPathOfFocusedCell;
        layout.changeInHeight = LARGE_CELL_SIZE.height - SMALL_CELL_SIZE.height;
        
        [self.smallCollectionView performBatchUpdates:^{
            [self.smallCollectionView setCollectionViewLayout:layout animated:YES];
            
        } completion:^(BOOL finished) {
            // Show a separate large collection view
            [self.largeCollectionView scrollToItemAtIndexPath:indexPathOfFocusedCell atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            
            self.largeCollectionView.alpha = 1;
            self.smallCollectionView.alpha = 0;
            
            layout.indexPathOfFocusedCell = nil;
            [layout invalidateLayout];
        }];
        
    } else {
        layout = (VVDraggableCollectionViewLayout *)self.largeCollectionView.collectionViewLayout;
        layout.indexPathOfFocusedCell = indexPathOfFocusedCell;
        layout.changeInHeight = 0;
        
        [self.largeCollectionView performBatchUpdates:^{
            [self.largeCollectionView setCollectionViewLayout:layout animated:YES];
            
        } completion:^(BOOL finished) {
            
            layout.changeInHeight = 0;
            [self.largeCollectionView performBatchUpdates:^{
                [self.largeCollectionView setCollectionViewLayout:layout animated:YES];
                
            } completion:^(BOOL finished) {
            }];
        }];
    }
}

@end
