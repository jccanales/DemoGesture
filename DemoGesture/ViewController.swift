//
//  ViewController.swift
//  DemoGesture
//
//  Created by Jean Carlo Canales Martinez on 1/25/16.
//  Copyright © 2016 Jean Carlo Canales Martinez. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var bananaPan: UIPanGestureRecognizer!
    @IBOutlet var monkeyPan: UIPanGestureRecognizer!
    var chompPlayer:AVAudioPlayer? = nil
    
    func loadSound(filename:NSString) -> AVAudioPlayer {
        
        do {
            let url = NSBundle.mainBundle().URLForResource(filename as String, withExtension: "caf")
            let error:NSError? = nil
            let player = try AVAudioPlayer(contentsOfURL: url!)
            if error != nil {
                print("Error loading \(url): \(error?.localizedDescription)")
            } else {
                player.prepareToPlay()
            }
            return player
        
        }catch _{
            return AVAudioPlayer()
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //1
        let filteredSubviews = self.view.subviews.filter({
            $0.isKindOfClass(UIImageView) })
        // 2
        for view in filteredSubviews  {
            // 3
            let recognizer = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
            // 4
            recognizer.delegate = self
            view.addGestureRecognizer(recognizer)
            
            //TODO: Add a custom gesture recognizer too
            recognizer.requireGestureRecognizerToFail(monkeyPan)
            recognizer.requireGestureRecognizerToFail(bananaPan)
        }
        self.chompPlayer = self.loadSound("chomp")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func handlePan(recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translationInView(self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + translation.x,
                y: view.center.y + translation.y)
        }
        
        recognizer.setTranslation(CGPointZero, inView: self.view)
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            // 1
            let velocity = recognizer.velocityInView(self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            print("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
            
            // 2
            let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
            // 3
            var finalPoint = CGPoint(x:recognizer.view!.center.x + (velocity.x * slideFactor),
                y:recognizer.view!.center.y + (velocity.y * slideFactor))
            // 4
            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)
            
            // 5
            UIView.animateWithDuration(Double(slideFactor * 2),
                delay: 0,
                // 6
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {recognizer.view!.center = finalPoint },
                completion: nil)
        }
    }
    
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = CGAffineTransformScale(view.transform,
                recognizer.scale, recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    @IBAction func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = CGAffineTransformRotate(view.transform, recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.chompPlayer?.play()
    }

}

