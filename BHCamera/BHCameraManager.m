//
//  BHCameraManager.m
//  BHCamera
//
//  Created by Christian Sullivan on 5/15/15.
//  Copyright (c) 2015 Bodhi5, Inc. All rights reserved.
//

#import "BHCameraManager.h"
#import <BHCamera/BHCamera-Swift.h>
#import "RCTEventDispatcher.h"
#import "RCTBridge.h"
#import "RCTUIManager.h"
#import "RCTSparseArray.h"

@implementation BHCameraManager
@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (UIView *)view {
  return [[[BHCamera alloc] init] initWithBridge:_bridge];
}

- (dispatch_queue_t)methodQueue
{
  return _bridge.uiManager.methodQueue;
}

RCT_EXPORT_VIEW_PROPERTY(scanning, BOOL);
RCT_EXPORT_VIEW_PROPERTY(flash, NSInteger);
RCT_EXPORT_VIEW_PROPERTY(torch, float);
RCT_EXPORT_VIEW_PROPERTY(camera, NSInteger);
RCT_EXPORT_VIEW_PROPERTY(aspect, NSInteger);
RCT_EXPORT_VIEW_PROPERTY(orientation, NSInteger);

RCT_EXPORT_METHOD(startScanning:(NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, RCTSparseArray *viewRegistry) {
    id view = viewRegistry[reactTag];
    if (![view isKindOfClass:[BHCamera class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting BHCamera, got: %@", view);
    }
    [view startScanner];
  }];
}

RCT_EXPORT_METHOD(stopScanning:(NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, RCTSparseArray *viewRegistry) {
    id view = viewRegistry[reactTag];
    if (![view isKindOfClass:[BHCamera class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting BHCamera, got: %@", view);
    }
    [view stopScanner];
  }];
}

RCT_EXPORT_METHOD(captureImage:(NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, RCTSparseArray *viewRegistry) {
    id view = viewRegistry[reactTag];
    if (![view isKindOfClass:[BHCamera class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting BHCamera, got: %@", view);
    }
    [view captureImage];
  }];
}

@end