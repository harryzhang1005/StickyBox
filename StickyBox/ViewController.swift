//
//  ViewController.swift
//  StickyBox
//
//  Created by Harvey Zhang on 12/8/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    var dynamicAnimator: UIDynamicAnimator!
    
    var stickyBoxBehavior: StickyBoxBehavior!
    
    // item view
    
    var itemView: UIView!   // like, a red box
    let aspectRatio: CGFloat = 0.75     // w:h = 0.75:1.0
    var length: CGFloat {   // item view width
        let b = UIScreen.mainScreen().bounds
        let length: CGFloat = 0.1 * max(b.width, b.height)
        return length
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configure()
    }

    func configure()
    {
        // Create an item view
        self.itemView = UIView(frame: CGRect(x: 0, y: 0, width: length, height: length/aspectRatio))
        itemView.backgroundColor = UIColor.redColor()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "pan:")
        itemView.addGestureRecognizer(panGesture)
        
        view.addSubview(itemView)
        
        self.dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        self.stickyBoxBehavior = StickyBoxBehavior(item: itemView, inset: length * 0.5)
        
        dynamicAnimator.addBehavior(stickyBoxBehavior)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "longPress:")
        view.addGestureRecognizer(longPressGesture)
    }
    
    func pan(gesture: UIPanGestureRecognizer)
    {
        let location = gesture.locationInView(view)
        
        switch gesture.state
        {
        case .Began:
            stickyBoxBehavior.isEnableBehaviors = false
            
        case .Changed:
            itemView.center = location
            
        case .Cancelled, .Ended:
            stickyBoxBehavior.isEnableBehaviors = true
            
        default: break
        }
        
    }
    
    // handle debug mode
    func longPress(gesture: UILongPressGestureRecognizer)
    {
        guard gesture.state == .Began else { return }
        
        print("long press clicked")
        dynamicAnimator.debugEnabled = !dynamicAnimator.debugEnabled
    }
    
    // MARK: - Handle device rotation
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        stickyBoxBehavior.isEnableBehaviors = false
        
        stickyBoxBehavior.configureFieldBehavors(CGRect(origin: CGPoint.zero, size: size))
        
        //dynamicAnimator.removeBehavior(stickyBoxBehavior)     // or via above line change the field behaviors
        
        let p = CGPoint(x: length/2, y: (length/aspectRatio)/2)
        
        coordinator.animateAlongsideTransition({ (context) -> Void in
            self.itemView.center = p
            })
            { (content) -> Void in
                //self.dynamicAnimator.addBehavior(self.stickyBoxBehavior)
                self.stickyBoxBehavior.isEnableBehaviors = true
        }
    }

}
