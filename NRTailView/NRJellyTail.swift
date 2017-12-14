//
//  JellyTail.swift
//  JellyTail
//
//  Created by nabinrai on 10/31/17.
//  Copyright © 2017 nabin. All rights reserved.
//

import UIKit
import Foundation


protocol NRJellyTailDelegate: class{
  
  func swipeLeftAction(jellyView:NRJellyTail )
  
  
}

class NRJellyTail: UIView {
  
  
  
  // constant
  let thresholdPointToDismiss: CGFloat = 10
  let crossImgAnimatePoint: CGFloat = 50+0
  let maxPointDivisor: CGFloat = 1.0
  let translationXMultiplier: CGFloat = 1.5
  
  
  // variables
  var color: CGColor = UIColor.red.cgColor
  private var originalCenter: CGPoint?
  private var p0: CGPoint!
  private var p2: CGPoint!
  private lazy var gestureViewRect: CGRect = {
    return self.bounds
  }()
  private var path: UIBezierPath!
  
  private var controlPointX: CGFloat!
  private var controlPointY: CGFloat!
 // private var interactionInProgress = false
  private var shouldCompleteTransition = false
  private lazy var screenFrame: CGRect = {
    return UIScreen.main.bounds
  }()
  private var sliceLayer: CAShapeLayer!{
    willSet{
      if sliceLayer != nil{
        sliceLayer.removeFromSuperlayer()
      }
    }
  }
  private var leftSliceLayer: CAShapeLayer!{
    willSet{
      if sliceLayer != nil{
        sliceLayer.removeFromSuperlayer()
      }
    }
  }
  
  open var midYConstant: CGFloat = 0
  weak var nrJellyTailDelegate: NRJellyTailDelegate?
  

  
  // MARK:- draw rect method
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    self.forEquilixerX_needForNRJellyTail()
    self.originalCenter = self.center
    p0 = CGPoint(x: self.bounds.maxX, y:self.bounds.minY)
    p2 = CGPoint(x: self.bounds.maxX, y: self.bounds.maxY)
    
    controlPointX = screenFrame.maxX-50
    controlPointY = screenFrame.midY-midYConstant
    
    self.addGesture()
    
  }
  
  private func addGesture(){
    // gesture code
    let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
    self.isUserInteractionEnabled = true
    self.addGestureRecognizer(gesture)
  }
  
  
  // MARK:- Gesture handler method
  @objc private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
    //var onceString: String
    let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
    gestureRecognizer.setTranslation(CGPoint.zero, in: self)
    let deltaX = translation.x
    let gestureViewFrame = self.frame
    
    switch gestureRecognizer.state {
    case .began:
       
      break
    //  interactionInProgress = true
    case .changed:
      self.center = CGPoint(x: self.center.x + (translation.x*translationXMultiplier), y: self.center.y)
      self.addParabolicInRight(translationX: deltaX)
      if deltaX < 0 {
        
        if (gestureViewFrame.maxX) <= self.thresholdPointToDismiss{
          self.nrJellyTailDelegate?.swipeLeftAction(jellyView: self)
        }
        if (gestureViewFrame.maxX) <= self.crossImgAnimatePoint{
        //  self.nrJellyTailDelegate?.animateCrossBtn(jellyView: self)
        }
      }else if deltaX > 0{
       // self.nrJellyTailDelegate?.deAnimateCrossImgView(jellyView: self)
      }
      
    case .cancelled:
      
     // interactionInProgress = false
      self.resetView()
     // self.nrJellyTailDelegate?.deAnimateCrossImgView(jellyView: self)
      
    case .ended:
      
      self.resetView()
      //self.nrJellyTailDelegate?.deAnimateCrossImgView(jellyView: self)
     // interactionInProgress = false
    default:
        
      break
    }
  }
  
  
  // MARK: Goto original position
  
  func resetView(){
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
      if self.sliceLayer != nil{
        self.sliceLayer.removeFromSuperlayer()
      }
      self.controlPointX = self.screenFrame.maxX
      self.controlPointY = self.screenFrame.midY-self.midYConstant
      
      if let centeR = self.originalCenter{
        self.center = centeR
      }
    }, completion: nil)
  }
  
  
  
  // MARK:- Method to make BezierPath
  private func addParabolicInRight(translationX: CGFloat){

    path = UIBezierPath()

    controlPointX = controlPointX - translationX*translationXMultiplier

    let centerControlPoint = CGPoint(x: controlPointX, y: controlPointY)
    let centerPoint = CGPoint(x: self.bounds.maxX/maxPointDivisor, y: controlPointY)

    // center formula
    let three: CGFloat = 3
    let p1Y = (self.p0.y+centerControlPoint.y+centerPoint.y)/three
    let p4Y = (self.p2.y+centerControlPoint.y+centerPoint.y)/three
    let p1 = CGPoint(x: (self.p0.x+centerControlPoint.x+centerPoint.x)/three, y: p1Y)
    let p4 = CGPoint(x: (self.p2.x+centerControlPoint.x+centerPoint.x)/three, y: p4Y)

    // section fromula
    let m: CGFloat = 3, n: CGFloat = 2
    let p2 = CGPoint(x: (m*self.p0.x+n*centerControlPoint.x)/(m+n), y: p1.y)
    let p3 = CGPoint(x: (m*self.p2.x+n*centerControlPoint.x)/(m+n), y: p4.y)


    let r1Point = CGPoint(x: self.p0.x, y: p1.y)
    let r2Point = CGPoint(x: self.p0.x, y: p4.y)

    //center formula
    let controlR1Point = CGPoint(x: (self.p0.x+p1.x+r1Point.x)/3, y: (self.p0.y+p1.y+r1Point.y)/3)
    let controlR2Point = CGPoint(x: (self.p2.x+p4.x+r2Point.x)/3, y: (self.p2.y+p4.y+r2Point.y)/3)

    //for straight line
    let bottomRightPoint = CGPoint(x: gestureViewRect.minX, y: gestureViewRect.maxY)
    let topRightPoint = CGPoint(x: gestureViewRect.minX, y: gestureViewRect.minY)

    //drawing BezierPath
    path.move(to: self.p0)
    path.addQuadCurve(to: p2, controlPoint: controlR1Point)
    path.addQuadCurve(to: p3, controlPoint: centerControlPoint)
    path.addQuadCurve(to: self.p2, controlPoint: controlR2Point)
    path.addLine(to:bottomRightPoint )
    path.addLine(to: topRightPoint)
    path.close()

    let layer = CAShapeLayer()
    layer.path = path.cgPath
    layer.fillColor = color
    layer.backgroundColor = nil
    layer.strokeColor = color
    layer.lineWidth = 1.0
    sliceLayer = layer
    self.layer.insertSublayer(sliceLayer, at: 0)

  }
  

  
      // MARK: Methods
    
    private func forEquilixerX_needForNRJellyTail(){
        
        var equilizerY: CGFloat
        
        if PGDeviceDetector.IS_IPHONE_4_OR_LESS{
            equilizerY = 30
            self.midYConstant = equilizerY
        }else if PGDeviceDetector.IS_IPHONE_5{
            equilizerY = 30
            self.midYConstant = equilizerY
            
        }else if PGDeviceDetector.IS_IPHONE_6{
            equilizerY = 30
            self.midYConstant = equilizerY
            
        }else if PGDeviceDetector.IS_IPHONE_6P{
            equilizerY = 0
            self.midYConstant = equilizerY
            
        }else if PGDeviceDetector.IS_IPHONE_7{
            equilizerY = 0
            self.midYConstant = equilizerY
            
        }else if PGDeviceDetector.IS_IPHONE_7P{
            equilizerY = 0
            self.midYConstant = equilizerY
            
        }else if PGDeviceDetector.IS_IPHONE_X{
            equilizerY = 50
            self.midYConstant = equilizerY
        }
    }
  
  
}

struct PGScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(PGScreenSize.SCREEN_WIDTH, PGScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(PGScreenSize.SCREEN_WIDTH, PGScreenSize.SCREEN_HEIGHT)
}

struct PGDeviceDetector
{
    static let IS_IPHONE            = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && PGScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && PGScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && PGScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && PGScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_7          = IS_IPHONE_6
    static let IS_IPHONE_7P         = IS_IPHONE_6P
    static let IS_IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && PGScreenSize.SCREEN_MAX_LENGTH == 812
}

struct PGiOSVersion{
    static let SYS_VERSION_FLOAT = (UIDevice.current.systemVersion as NSString).floatValue
    static let iOS7 = (PGiOSVersion.SYS_VERSION_FLOAT < 8.0 && PGiOSVersion.SYS_VERSION_FLOAT >= 7.0)
    static let iOS8 = (PGiOSVersion.SYS_VERSION_FLOAT >= 8.0 && PGiOSVersion.SYS_VERSION_FLOAT < 9.0)
    static let iOS9 = (PGiOSVersion.SYS_VERSION_FLOAT >= 9.0 && PGiOSVersion.SYS_VERSION_FLOAT < 10.0)
    static let iOS10 = (PGiOSVersion.SYS_VERSION_FLOAT >= 10.0 && PGiOSVersion.SYS_VERSION_FLOAT < 11.0)
    static let iOS11 = (PGiOSVersion.SYS_VERSION_FLOAT >= 11.0 && PGiOSVersion.SYS_VERSION_FLOAT < 12.0)
}



