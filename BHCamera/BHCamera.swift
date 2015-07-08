//
//  BHCamera.swift
//  BHCamera
//
//  Created by Christian Sullivan on 5/15/15.
//  Copyright (c) 2015 Bodhi5, Inc. All rights reserved.
//

import AVFoundation;
import UIKit
import React

@objc(BHCamera)
public class BHCamera: UIView, AVCaptureMetadataOutputObjectsDelegate {
 
  //MARK: Class Methods
  @objc
  class func requestCameraAuth(callback: RCTResponseSenderBlock) {
    let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
    
    switch authorizationStatus {
    case .NotDetermined:
      // permission dialog not yet presented, request authorization
      AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo,
        completionHandler: { (granted:Bool) -> Void in
          if granted {
            callback([["success": true, "details": "Access to camera has been granted"]])
          }
          else {
            callback([["success": false, "details": "Access to camera has been denied"]])
          }
      })
    case .Authorized:
      callback([["success": false, "details": "Access to camera has been denied"]])
    case .Denied, .Restricted:
      callback([["success": false, "details": "Access to camera has been denied"]])
    }
  }
  
  //MARK: Props
  
  var session         : AVCaptureSession = AVCaptureSession()
  var sessionQueue    : dispatch_queue_t!
  var previewLayer    : AVCaptureVideoPreviewLayer!
  var bridge          : RCTBridge!
  var captureDevice   : AVCaptureDevice?
  var stillImageOutput: AVCaptureStillImageOutput?
  let screenWidth     : CGFloat = UIScreen.mainScreen().bounds.size.width
 

  
  //MARK: Built-Ins
  
  @objc
  public func initWithBridge(_bridge: RCTBridge) -> BHCamera {
    self.bridge = _bridge
    self.getCameraAuth()
    self.initCamera()
    return self
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    if (self.captureDevice == nil) {
      return
    }
    self.previewLayer.frame = self.bounds
    self.layer.insertSublayer(self.previewLayer, atIndex:0)
  }
  
  public override func insertReactSubview(subview: RCTViewNodeProtocol!, atIndex: Int) {
    self.insertSubview(subview as! UIView, atIndex: atIndex + 1)
  }
  
  public override func removeReactSubview(subview: RCTViewNodeProtocol!) {
    (subview as! UIView).removeFromSuperview()
  }
  
  public func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
    
    if self.captureDevice == nil {
      return
    }
    
    let barCodeTypes = [
      AVMetadataObjectTypeUPCECode,
      AVMetadataObjectTypeCode39Code,
      AVMetadataObjectTypeCode39Mod43Code,
      AVMetadataObjectTypeEAN13Code,
      AVMetadataObjectTypeEAN8Code,
      AVMetadataObjectTypeCode93Code,
      AVMetadataObjectTypeCode128Code,
      AVMetadataObjectTypePDF417Code,
      AVMetadataObjectTypeQRCode,
      AVMetadataObjectTypeAztecCode
    ]
    
    //var barCodeObject : AVMetadataObject!
    var detectionString : String!
    
    // The scanner is capable of capturing multiple 2-dimensional barcodes in one scan.
    for metadata in metadataObjects {
      for barcodeType in barCodeTypes {
        if metadata.type == barcodeType {
          //barCodeObject = self.previewLayer.transformedMetadataObjectForMetadataObject(metadata as! AVMetadataMachineReadableCodeObject)
          detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
          self.stopScanner()
          break
        }
      }
    }
    if detectionString != nil {
      self.bridge.eventDispatcher.sendAppEventWithName("BHCameraEvent", body: ["type": "Barcode", "data": detectionString ] )
    }
  }
  
  @objc
  public func initCamera() {
    
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    self.sessionQueue = dispatch_queue_create("bhCameraQueue", DISPATCH_QUEUE_SERIAL)
    self.captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    
    if self.captureDevice == nil {
      return
    }
    
    dispatch_async(self.sessionQueue, {
      do {
        try self.captureDevice!.lockForConfiguration()
      } catch {
        
      }
      
      self.captureDevice!.focusMode = AVCaptureFocusMode.ContinuousAutoFocus;
      self.captureDevice!.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure;
      self.captureDevice!.unlockForConfiguration();
    })
    
    do {
      let input : AVCaptureDeviceInput? = try AVCaptureDeviceInput(device: self.captureDevice)
      // If our input is not nil then add it to the session, otherwise we're kind of done!
      if input != nil {
        self.session.addInput(input)
      }
    } catch {
      // This is fine for a demo, do something real with this in your app. :)
      print(error, appendNewline: false)
    }
    
    let stillOutput = AVCaptureStillImageOutput();
    stillOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG];
    self.stillImageOutput = stillOutput;
    self.session.addOutput(self.stillImageOutput);
    
    let output = AVCaptureMetadataOutput()
    output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
    self.session.addOutput(output)
    output.metadataObjectTypes = output.availableMetadataObjectTypes
    
    self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
    self.previewLayer.frame = self.bounds
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    self.layer.addSublayer(self.previewLayer)
  }
  //MARK: Setters
  
  @objc
  public func setScanning(isScanning: Bool){
    (isScanning) ? self.startScanner() : self.stopScanner()
  }
  
  @objc
  public func setTorch(mode: Float) {
    if (!self.captureDevice!.hasTorch) {
      return
    }
    
    let torchOn = !self.captureDevice!.torchActive
    var err: NSError? = nil
    
    do {
      try self.captureDevice!.lockForConfiguration()
    } catch let error as NSError {
      err = error
    }
    do {
      try self.captureDevice!.setTorchModeOnWithLevel(1.0)
    } catch let error as NSError {
      err = error
    }
    self.captureDevice!.torchMode = torchOn ? AVCaptureTorchMode.On : AVCaptureTorchMode.Off
    self.captureDevice!.unlockForConfiguration()
    if (err != nil) { print("Error Setting Flash Mode: \(err)") }
  }
  
  @objc
  public func setFlash(mode: Int) {
    let flashMode = AVCaptureFlashMode(rawValue: mode)!
    if (self.captureDevice == nil || !self.captureDevice!.hasFlash || !self.captureDevice!.isFlashModeSupported(flashMode)) {
      return
    }
    var err: NSError? = nil
    do {
      try self.captureDevice!.lockForConfiguration()
    } catch let error as NSError {
      err = error
    }
    self.captureDevice!.flashMode = AVCaptureFlashMode(rawValue: mode)!
    self.captureDevice!.unlockForConfiguration()
    if (err != nil) { print("Error Setting Flash Mode: \(err)") }
  }
  
  @objc
  public func setCamera(mode: Int){
    print("Setting Camera \(mode)")
  }
  
  //TODO: Allow for setting aspect
  @objc
  public func setAspect(mode: Int){
    print("Setting Aspect \(mode)")
  }
  
  //TODO: Allow for setting orientation
  @objc
  public func setOrientation(mode: Int){
    print("Setting Orientatio \(mode)")
  }
  
  //MARK: Methods
  
  @objc
  public func getCameraAuth() {
    let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
    
    switch authorizationStatus {
    case .NotDetermined:
      // permission dialog not yet presented, request authorization
      AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo,
        completionHandler: { (granted:Bool) -> Void in
          if granted {
            self.bridge.eventDispatcher.sendAppEventWithName("BHCameraEvent", body: ["type": "AccessGranted", "data": true ] )
          }
          else {
            self.bridge.eventDispatcher.sendAppEventWithName("BHCameraEvent", body: ["type": "AccessError", "data": "Access to camera has been denied" ] )
          }
      })
    case .Authorized:
      self.bridge.eventDispatcher.sendAppEventWithName("BHCameraEvent", body: ["type": "AccessAllowed", "data": true ] )
    case .Denied, .Restricted:
      self.bridge.eventDispatcher.sendAppEventWithName("BHCameraEvent", body: ["type": "AccessError", "error": "Access to camera has been denied"] )
    }
  }
  
  @objc
  public func captureImage() -> String {
    var image: UIImage?
    
    if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
      videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
      stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
        if (sampleBuffer != nil) {
          let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
          let dataProvider = CGDataProviderCreateWithCFData(imageData)
          let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true,  CGColorRenderingIntent.RenderingIntentDefault)
          
          image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
          let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingPathComponent("\(NSUUID().UUIDString).jpg)") as String
          _ = UIImageJPEGRepresentation(image!, 1.0)?.writeToFile(documentsPath, atomically: true)
          self.bridge.eventDispatcher.sendAppEventWithName("BHCameraEvent", body: ["type": "ImageCapture", "data": documentsPath] )
        }
      })
    }
    return ""
  }
  
  @objc
  public func startScanner() {
    if !self.session.running {
      self.session.startRunning()
      self.bridge.eventDispatcher.sendAppEventWithName("BHCameraEvent", body: ["type": "ScannerStart", "data": true ] )
    }
  }
  
  @objc
  public func stopScanner() {
    if self.session.running {
      self.session.stopRunning()
      self.bridge.eventDispatcher.sendAppEventWithName("BHCameraEvent", body: ["type": "ScannerStop", "data": true ] )
    }
  }
  
}