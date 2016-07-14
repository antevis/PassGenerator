//
//  Ride.swift
//  PassGenerator
//
//  Created by Ivan Kazakov on 14/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import Foundation


//protocol marked 'class' to make it possible to declare delegate weak. Which in turn prevents retain cycle with intersted listeners.
//https://www.natashatherobot.com/ios-weak-delegates-swift/
protocol RideDelegate: class {
	
	func rideCompleted()
}

class Ride {
	
	var timer = NSTimer()
	
	weak var delegate: RideDelegate?
	
	var seconds = 0
	
	var rideDuration: Int
	
	init(withDuration duration: Int) {
		
		self.rideDuration = duration
	}
	
	func startRide(rideDuration duration: Int = 10) {
		
		rideDuration = duration
		
		seconds = rideDuration
		
		timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(decreaseTimer), userInfo: nil, repeats: true)
	}
	
	@objc func decreaseTimer() {
		
		seconds -= 1

		if seconds == 0 {
			
			timer.invalidate()
			
			endRide()
		}
	}
	
	func endRide() {
		
		delegate?.rideCompleted()
	}
}
