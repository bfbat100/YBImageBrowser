//
//  YBIBTopView.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/6.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBTopView.h"
#import "YBIBIconManager.h"
#import "YBIBUtilities.h"

@interface YBIBTopView ()
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, strong) UIButton *operationButton;
@property (nonatomic, strong) UIButton *dismissButton;

@end

@implementation YBIBTopView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.pageLabel];
        //根据需求隐藏顶部更多操作按钮
//        [self addSubview:self.operationButton];
        [self addSubview:self.dismissButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = self.bounds.size.height, width = self.bounds.size.width;
    
    self.pageLabel.frame = CGRectMake(width/2 - 40, 0, 80, height);
    CGFloat buttonWidth = 54;
    self.operationButton.frame = CGRectMake(width - buttonWidth, 0, buttonWidth, height);
    
    self.dismissButton.frame = CGRectMake(16, 0, 40, 40);
}

#pragma mark - public

+ (CGFloat)defaultHeight {
    return 50;
}

- (void)setPage:(NSInteger)page totalPage:(NSInteger)totalPage {
    if (totalPage <= 1) {
        self.pageLabel.hidden = YES;
    } else {
        self.pageLabel.hidden  = NO;
        
        NSString *text = [NSString stringWithFormat:@"%ld/%ld", page + (NSInteger)1, totalPage];
        NSShadow *shadow = [NSShadow new];
        shadow.shadowBlurRadius = 4;
        shadow.shadowOffset = CGSizeMake(0, 1);
        shadow.shadowColor = UIColor.darkGrayColor;
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSShadowAttributeName:shadow}];
        self.pageLabel.attributedText = attr;
    }
}

#pragma mark - event

- (void)clickOperationButton:(UIButton *)button {
    [self setOperationType:YBIBTopViewOperationTypeMore];

    if (self.clickOperation) self.clickOperation(self.operationType);
}

- (void)clickDismissbtn:(UIButton *)button {
    [self setOperationType:YBIBTopViewOperationTypeDismiss];

    if (self.clickOperation) self.clickOperation(self.operationType);
}

#pragma mark - getters & setters

- (void)setOperationType:(YBIBTopViewOperationType)operationType {
    _operationType = operationType;
    
    UIImage *image = nil;
    switch (operationType) {
        case YBIBTopViewOperationTypeSave:
            image = [YBIBIconManager sharedManager].toolSaveImage();
            break;
        case YBIBTopViewOperationTypeMore:
            image = [YBIBIconManager sharedManager].toolMoreImage();
        case YBIBTopViewOperationTypeDismiss:
            image = [YBIBIconManager sharedManager].dismissImage();
            
            break;
        
    }
    
    [self.operationButton setImage:image forState:UIControlStateNormal];
}

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        _pageLabel = [UILabel new];
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.font = [UIFont systemFontOfSize:18];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _pageLabel;
}

- (UIButton *)operationButton {
    if (!_operationButton) {
        _operationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _operationButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _operationButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_operationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_operationButton addTarget:self action:@selector(clickOperationButton:) forControlEvents:UIControlEventTouchUpInside];
        _operationButton.layer.shadowColor = UIColor.darkGrayColor.CGColor;
        _operationButton.layer.shadowOffset = CGSizeMake(0, 1);
        _operationButton.layer.shadowOpacity = 1;
        _operationButton.layer.shadowRadius = 4;
    }
    return _operationButton;
}

- (UIButton *)dismissButton {
    if(!_dismissButton) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dismissButton addTarget:self action:@selector(clickDismissbtn:) forControlEvents:UIControlEventTouchUpInside];
        _dismissButton.layer.shadowColor = UIColor.darkGrayColor.CGColor;
        _dismissButton.layer.shadowOffset = CGSizeMake(0, 1);
        _dismissButton.layer.shadowOpacity = 1;
        [_dismissButton setImage:[YBIBIconManager sharedManager].dismissImage() forState:UIControlStateNormal];
    }
    return _dismissButton;
}
@end
