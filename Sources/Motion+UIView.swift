/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit

fileprivate var MotionInstanceKey: UInt8 = 0

fileprivate struct MotionInstance {
    /// An optional reference to the motion identifier.
    fileprivate var identifier: String?
    
    /// An optional reference to the motion animations.
    fileprivate var animations: [MotionAnimation]?
}

extension UIView {
    /// MotionInstance reference.
    fileprivate var motionInstance: MotionInstance {
        get {
            return AssociatedObject.get(base: self, key: &MotionInstanceKey) {
                return MotionInstance(identifier: nil, animations: nil)
            }
        }
        set(value) {
            AssociatedObject.set(base: self, key: &MotionInstanceKey, value: value)
        }
    }
    
    /// An identifier value used to connect views across UIViewControllers.
    open var motionIdentifier: String? {
        get {
            return motionInstance.identifier
        }
        set(value) {
            motionInstance.identifier = value
        }
    }
    
    /// The animations to run while in transition.
    open var motionAnimations: [MotionAnimation]? {
        get {
            return motionInstance.animations
        }
        set(value) {
            motionInstance.animations = value
        }
    }
}

extension UIView {
    /**
     Snapshots the view instance for animations during transitions.
     - Parameter afterUpdates: A boolean indicating whether to snapshot the view
     after a render update, or as is.
     - Parameter shouldHide: A boolean indicating whether the view should be hidden
     after the snapshot is taken.
     - Returns: A UIView instance that is a snapshot of the given UIView.
     */
    open func transitionSnapshot(afterUpdates: Bool, shouldHide: Bool = true) -> UIView {
        isHidden = false
        
        let oldCornerRadius = layer.cornerRadius
        layer.cornerRadius = 0
        
        var oldBackgroundColor: UIColor?
        
        if shouldHide {
            oldBackgroundColor = backgroundColor
            backgroundColor = .clear
        }
        
        let oldTransform = motionTransform
        motionTransform = CATransform3DIdentity
        
        let v = snapshotView(afterScreenUpdates: afterUpdates)!
        layer.cornerRadius = oldCornerRadius
        
        if shouldHide {
            backgroundColor = oldBackgroundColor
        }
        
        motionTransform = oldTransform
        
        let contentView = v.subviews.first!
        contentView.layer.cornerRadius = layer.cornerRadius
        contentView.layer.masksToBounds = true
        
        v.motionIdentifier = motionIdentifier
        v.layer.position = motionPosition
        v.bounds = bounds
        v.layer.cornerRadius = layer.cornerRadius
        v.layer.zPosition = layer.zPosition
        v.layer.opacity = layer.opacity
        v.isOpaque = isOpaque
        v.layer.anchorPoint = layer.anchorPoint
        v.layer.masksToBounds = layer.masksToBounds
        v.layer.borderColor = layer.borderColor
        v.layer.borderWidth = layer.borderWidth
        v.layer.shadowRadius = layer.shadowRadius
        v.layer.shadowOpacity = layer.shadowOpacity
        v.layer.shadowColor = layer.shadowColor
        v.layer.shadowOffset = layer.shadowOffset
        v.contentMode = contentMode
        v.motionTransform = motionTransform
        v.backgroundColor = backgroundColor
        
        isHidden = shouldHide
        
        return v
    }
}

extension UIView {
    /// Computes the rotation of the view.
    open var motionRotationAngle: CGFloat {
        get {
            return CGFloat(atan2f(Float(transform.b), Float(transform.a))) * 180 / CGFloat(Double.pi)
        }
        set(value) {
            transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi) * value / 180)
        }
    }
    
    /// The global position of a view.
    open var motionPosition: CGPoint {
        return superview?.convert(layer.position, to: nil) ?? layer.position
    }
    
    /// The layer.transform of a view.
    open var motionTransform: CATransform3D {
        get {
            return layer.transform
        }
        set(value) {
            layer.transform = value
        }
    }
    
    /// Computes the scale X axis value of the view.
    open var motionScaleX: CGFloat {
        return transform.a
    }
    
    /// Computes the scale Y axis value of the view.
    open var motionScaleY: CGFloat {
        return transform.b
    }
    
    /**
     A function that accepts CAAnimation objects and executes them on the
     view's backing layer.
     - Parameter animations: A list of CAAnimations.
     */
    open func animate(_ animations: CAAnimation...) {
        layer.animate(animations)
    }
    
    /**
     A function that accepts an Array of CAAnimation objects and executes
     them on the view's backing layer.
     - Parameter animations: An Array of CAAnimations.
     */
    open func animate(_ animations: [CAAnimation]) {
        layer.animate(animations)
    }
    
    /**
     A function that accepts a list of MotionAnimation values and executes
     them on the view's backing layer.
     - Parameter animations: A list of MotionAnimation values.
     */
    open func motion(_ animations: MotionAnimation...) {
        layer.motion(animations)
    }
    
    /**
     A function that accepts an Array of MotionAnimation values and executes
     them on the view's backing layer.
     - Parameter animations: An Array of MotionAnimation values.
     - Parameter completion: An optional completion block.
     */
    open func motion(_ animations: [MotionAnimation], completion: (() -> Void)? = nil) {
        layer.motion(animations, completion: completion)
    }
}