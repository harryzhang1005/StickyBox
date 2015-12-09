//
//  StickyBoxBehavior.swift
//  StickyBox
//
//  Created by Harvey Zhang on 12/8/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit

enum FieldPosition: Int {
    case TopLeft = 0
    case TopRight
    case BottomLeft
    case BottomRight
}

class StickyBoxBehavior: UIDynamicBehavior
{
    var collisionBehavior: UICollisionBehavior?         // Used for collision with the edges to keep the box on screen
    var dynamicItemBehavior: UIDynamicItemBehavior?     // Used to change the dynamic properties of the red box
    var fieldBehaviors = [UIFieldBehavior]()            // Used to store 4 sping field behaviors
    
    private let item: UIDynamicItem     // like, red box view
    private let inset: CGFloat          // item inset
    
    init(item: UIDynamicItem, inset: CGFloat)
    {
        self.item = item
        self.inset = inset
    
        // 1. Collision behavior
        self.collisionBehavior = UICollisionBehavior(items: [item])
        collisionBehavior?.translatesReferenceBoundsIntoBoundary = true
        
        // 2. Dynamic item behavior
        self.dynamicItemBehavior = UIDynamicItemBehavior(items: [item])
        dynamicItemBehavior?.density = 0.01  // The relative mass density of the behavior’s dynamic items.
        dynamicItemBehavior?.elasticity = 0.5
        dynamicItemBehavior?.friction = 0.1
        dynamicItemBehavior?.resistance = 10
        dynamicItemBehavior?.allowsRotation = false
        
        super.init()
        
        addChildBehavior(collisionBehavior!)
        addChildBehavior(dynamicItemBehavior!)
        
        // 3. Field Behavior
        for _ in 0 ..< 4
        {
            /*
            Creates and returns a spring field behavior. A field behavior object that applies spring effects to items.
            */
            let fb = UIFieldBehavior.springField()
            fieldBehaviors.append(fb)
            fb.addItem(item)
            addChildBehavior(fb)
        }
    }
    
    var isEnableBehaviors:Bool = true {
        didSet {
            if isEnableBehaviors {
                collisionBehavior?.addItem(item)
                dynamicItemBehavior?.addItem(item)
                for fb in fieldBehaviors {
                    fb.addItem(item)
                }
            }
            else {
                collisionBehavior?.removeItem(item)
                dynamicItemBehavior?.removeItem(item)
                for fb in fieldBehaviors {
                    fb.removeItem(item)
                }
            }
        }//Set
    }
    
    // MARK: - UIDynamicAnimator
    
    /*
    Called when the dynamic behavior is added to, or removed from, a dynamic animator.
    The dynamic animator that the behavior is being added to, or nil if being removed from an animator.
    */
    override func willMoveToAnimator(dynamicAnimator: UIDynamicAnimator?) {
        super.willMoveToAnimator(dynamicAnimator)
        
        let bounds = dynamicAnimator?.referenceView?.bounds
        configureFieldBehavors(bounds)
    }
    
    // When the device change the orientation, the dynmaic animator will temp lost the reference view; so the para `bounds` is CGRect?
    func configureFieldBehavors(bounds: CGRect?)
    {
        if bounds != nil {
            let w = bounds!.width    // { return UIScreen.mainScreen().bounds.width }()
            let h = bounds!.height   // { return UIScreen.mainScreen().bounds.height }()
            let dx: CGFloat = inset + item.bounds.width/2
            let dy: CGFloat = inset + item.bounds.height/2
            
            print("w,h,dx,dy: \(w),\(h),\(dx),\(dy)")
            
            func setupFieldBehavior(fb: UIFieldBehavior, _ point: CGPoint)
            {
                // This position property defines the center point of the field. The shape of the field around this point is defined by the region property.
                fb.position = point
                fb.region = UIRegion(size: CGSize(width: w - 2*dx, height: h - 2*dy) )
            }
            
            let pTopLeft = CGPoint(x: dx, y: dy)
            let pTopRight = CGPoint(x: w - dx, y: dy)
            let pBottomLeft = CGPoint(x: dx, y: h - dy)
            let pBottomRight = CGPoint(x: w - dx, y: h - dy)
            
            setupFieldBehavior(fieldBehaviors[FieldPosition.TopLeft.rawValue], pTopLeft)
            setupFieldBehavior(fieldBehaviors[FieldPosition.TopRight.rawValue], pTopRight)
            setupFieldBehavior(fieldBehaviors[FieldPosition.BottomLeft.rawValue], pBottomLeft)
            setupFieldBehavior(fieldBehaviors[FieldPosition.BottomRight.rawValue], pBottomRight)
        }//if
    }
    
}
