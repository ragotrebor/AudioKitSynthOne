//
//  TimeKnob.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/5/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

public class TimeKnob: Knob {
    
    var conductor = Conductor.sharedInstance
    
    var limitedRate = Rate.count - 3
    
    var rate: Rate {
        return Rate(rawValue: 3 + Int(CGFloat(limitedRate) - knobValue * CGFloat(limitedRate))) ?? Rate.sixtyFourth
    }
    
    func update() {
        if conductor.syncRatesToTempo {
            knobValue = CGFloat(Rate.fromTime(_value).time) / CGFloat(limitedRate)
        } else {
            _value = range.clamp(rate.time)
            knobValue = CGFloat(_value.normalized(from: range, taper: taper))
        }
    }
    
    private var _value: Double = 0
    
    override public var value: Double {
        get {
            if conductor.syncRatesToTempo {
                return rate.time
            } else {
                return _value
            }
        }
        set(newValue) {
            _value = range.clamp(newValue)
            _value = onlyIntegers ? round(_value) : _value
            
            if !conductor.syncRatesToTempo {
                knobValue = CGFloat(_value.normalized(from: range, taper: taper))
            }
        }
    }
    
    // Init / Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
        contentMode = .redraw
    }
    
    override func setPercentagesWithTouchPoint(_ touchPoint: CGPoint) {
        // Knobs assume up or right is increasing, and down or left is decreasing
        
        knobValue += (touchPoint.x - lastX) * knobSensitivity
        knobValue -= (touchPoint.y - lastY) * knobSensitivity
        
        knobValue = (0.0 ... 1.0).clamp(knobValue)
        
        if conductor.syncRatesToTempo {
            value = rate.time
        } else {
            value = Double(knobValue).denormalized(to: range, taper: taper)
        }
        
        callback(value)
        lastX = touchPoint.x
        lastY = touchPoint.y
    }
}
