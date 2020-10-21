//
//  YBIBToolViewHandler.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/7.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBToolViewHandler.h"
#import "YBIBCopywriter.h"
#import "YBIBUtilities.h"
#import "YBIBImageData.h"
#import "YBIBVideoData.h"

@interface YBIBToolViewHandler ()
@property (nonatomic, strong) YBIBSheetView *sheetView;
@property (nonatomic, strong) YBIBSheetAction *saveAction;
///转发action
@property (nonatomic, strong) YBIBSheetAction *transformAction;
///分享action
@property (nonatomic, strong) YBIBSheetAction *shareAction;

@property (nonatomic, strong) YBIBTopView *topView;
@end

@implementation YBIBToolViewHandler

#pragma mark - <YBIBToolViewHandler>

@synthesize yb_containerView = _yb_containerView;
@synthesize yb_containerSize = _yb_containerSize;
@synthesize yb_currentPage = _yb_currentPage;
@synthesize yb_totalPage = _yb_totalPage;
@synthesize yb_currentOrientation = _yb_currentOrientation;
@synthesize yb_currentData = _yb_currentData;

- (void)yb_containerViewIsReadied {
    [self.yb_containerView addSubview:self.topView];
    [self layoutWithExpectOrientation:self.yb_currentOrientation()];
}

- (void)yb_pageChanged {
    if (self.topView.operationType == YBIBTopViewOperationTypeSave) {
        self.topView.operationButton.hidden = [self currentDataShouldHideSaveButton];
    }
    [self.topView setPage:self.yb_currentPage() totalPage:self.yb_totalPage()];
}

- (void)yb_respondsToLongPress {
    [self showSheetView];
}

- (void)yb_hide:(BOOL)hide {
    self.topView.hidden = hide;
    [self.sheetView hideWithAnimation:NO];
}

- (void)yb_orientationWillChangeWithExpectOrientation:(UIDeviceOrientation)orientation {
    [self.sheetView hideWithAnimation:NO];
}

- (void)yb_orientationChangeAnimationWithExpectOrientation:(UIDeviceOrientation)orientation {
    [self layoutWithExpectOrientation:orientation];
}

#pragma mark - private

- (BOOL)currentDataShouldHideSaveButton {
    id<YBIBDataProtocol> data = self.yb_currentData();
    BOOL allow = [data respondsToSelector:@selector(yb_allowSaveToPhotoAlbum)] && [data yb_allowSaveToPhotoAlbum];
    BOOL can = [data respondsToSelector:@selector(yb_saveToPhotoAlbum)];
    return !(allow && can);
}

- (void)layoutWithExpectOrientation:(UIDeviceOrientation)orientation {
    CGSize containerSize = self.yb_containerSize(orientation);
    UIEdgeInsets padding = YBIBPaddingByBrowserOrientation(orientation);
    
    self.topView.frame = CGRectMake(padding.left, padding.top, containerSize.width - padding.left - padding.right, [YBIBTopView defaultHeight]);
}

- (void)showSheetView {
    
//    _saveAction = [YBIBSheetAction actionWithName:@"保存图片" action:^(id<YBIBDataProtocol> data) {
//        if (!self) return;
//        if ([data respondsToSelector:@selector(yb_saveToPhotoAlbum)]) {
//            [data yb_saveToPhotoAlbum];
//        }
//        [self.sheetView hideWithAnimation:YES];
//    }];
    
    if ([self currentDataShouldHideSaveButton]) {
        [self.sheetView.actions removeObject:self.saveAction];
    } else {
        if (![self.sheetView.actions containsObject:self.saveAction]) {
        
            [self.sheetView hideWithAnimation:YES];
            [self.sheetView.actions addObject:self.saveAction];
            
            if (!self.isFuYouQuan) {
                [self.sheetView.actions addObject:self.transformAction];
//                [self.sheetView.actions addObject:self.shareAction];  // 小视频移除分享到微信功能
            }
        }
    }
    [self.sheetView showToView:self.yb_containerView orientation:self.yb_currentOrientation()];
}

#pragma mark - getters

- (YBIBSheetView *)sheetView {
    if (!_sheetView) {
        _sheetView = [YBIBSheetView new];
        __weak typeof(self) wSelf = self;
        [_sheetView setCurrentdata:^id<YBIBDataProtocol>{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return nil;
            return self.yb_currentData();
        }];
    }
    return _sheetView;
}

- (YBIBSheetAction *)saveAction {
    
    NSString *tmp = NSStringFromClass([self.yb_currentData() class]);
    if (!_saveAction && [tmp isEqualToString:@"YBIBImageData"]) {
        __weak typeof(self) wSelf = self;
        _saveAction = [YBIBSheetAction actionWithName:@"保存图片" action:^(id<YBIBDataProtocol> data) {
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            if ([data respondsToSelector:@selector(yb_saveToPhotoAlbum)]) {
                [data yb_saveToPhotoAlbum];
            }
            [self.sheetView hideWithAnimation:YES];
        }];
    }else if(!_saveAction && [tmp isEqualToString:@"YBIBVideoData"]){
        __weak typeof(self) wSelf = self;
        _saveAction = [YBIBSheetAction actionWithName:@"保存视频" action:^(id<YBIBDataProtocol> data) {
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            if ([data respondsToSelector:@selector(yb_saveToPhotoAlbum)]) {
                [data yb_saveToPhotoAlbum];
            }
            [self.sheetView hideWithAnimation:YES];
        }];
    }
    return _saveAction;
}

- (YBIBSheetAction *)transformAction {
    if (!_transformAction) {
        __weak typeof(self) wSelf = self;
        _transformAction = [YBIBSheetAction actionWithName:@"转发福信" action:^(id<YBIBDataProtocol> data) {
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            if ([data respondsToSelector:@selector(yb_transformToFuXin)]) {
                [data yb_transformToFuXin];
                if (self.hideBrowser) {
                    self.hideBrowser();
                }
            }
            [self.sheetView hideWithAnimation:YES];
        }];
    }
    return _transformAction;
}

- (YBIBSheetAction *)shareAction {
    if (!_shareAction) {
        __weak typeof(self) wSelf = self;
        _shareAction = [YBIBSheetAction actionWithName:@"分享给微信好友" action:^(id<YBIBDataProtocol> data) {
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            if ([data respondsToSelector:@selector(yb_shareToWeChat)]) {
                [data yb_shareToWeChat];
                if (self.hideBrowser) {
                    self.hideBrowser();
                }
            }
            [self.sheetView hideWithAnimation:YES];
        }];
    }
    return _shareAction;
}

- (YBIBTopView *)topView {
    if (!_topView) {
        _topView = [YBIBTopView new];
        _topView.isFuYouQuan = self.isFuYouQuan;
        _topView.operationType = YBIBTopViewOperationTypeMore;
        __weak typeof(self) wSelf = self;
        [_topView setClickOperation:^(YBIBTopViewOperationType type) {
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            switch (type) {
                case YBIBTopViewOperationTypeSave: {
                    id<YBIBDataProtocol> data = self.yb_currentData();
                    if ([data respondsToSelector:@selector(yb_saveToPhotoAlbum)]) {
                        [data yb_saveToPhotoAlbum];
                    }
                }
                    break;
                case YBIBTopViewOperationTypeMore: {
                    [self showSheetView];
                }
                    break;
                case YBIBTopViewOperationTypeDismiss: {
                   if (self.hideBrowser) {
                       self.hideBrowser();
                   }
                }
                    break;
                default:
                    break;
            }
        }];
    }
    return _topView;
}

@end
