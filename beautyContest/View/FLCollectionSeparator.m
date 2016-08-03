//
//  FLCollectionSeparator.m
//  carTune
//
//  Created by Tony on 16/6/30.
//  Copyright © 2016年 Jitsun. All rights reserved.
//

#import "FLCollectionSeparator.h"

@implementation FLCollectionSeparator

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
    }
    
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    self.frame = layoutAttributes.frame;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
