//
//  RideAccessController.swift
//  PassGenerator
//
//  Created by Ivan Kazakov on 14/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import Foundation

//protocol marked 'class' to make it possible to declare delegate as 'weak'. Which in turn prevents retain cycle with intersted listeners.
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

class RideAccessController: RideDelegate {
	
	var ride: Ride?
	
	init(rideDuration: Int) {
		
		self.ride = Ride(withDuration: rideDuration)
		
		self.ride?.delegate = self
	}
	
	var rideSwiped: Bool = false
	
	func rideCompleted() {
		
		self.rideSwiped = false
	}
	
	
	func validateRideAccess(entrant: Entrant, makeSound: Bool = true) {
		
		let rules: EntryRules = entrant.swipe()
		
		if rules.rideAccess.unlimitedAccess {
			
			let sfx: SoundFX? = makeSound ? SoundFX() : nil
			
			if !self.rideSwiped {
				
				//For simplicity the Ride considered started right after swiping
				rideSwiped = true
				ride?.startRide(rideDuration: 5)
				
				sfx?.loadGrantedSound()
				
				print("Welcome!")
				
			} else {
				
				sfx?.loadDeniedSound()
				
				print("Ride is in progress, one swipe per ride, please.")
			}
			
			sfx?.playSound()
		}
	}
}

class DoubleSwipeTester {
	
	private let entrant: Entrant
	
	private var secondsRemaining: Double
	private var secondsElapsed: Double = 0
	private var timerStep: Double
	
	private var timer = NSTimer()
	
	private let rideController: RideAccessController
	
	init(entrant: Entrant, testDurationSeconds: Double, timeStepSeconds: Double, rideDuration: Int) {
		
		self.entrant = entrant
		
		self.secondsRemaining = testDurationSeconds
		self.timerStep = timeStepSeconds
		
		self.rideController = RideAccessController(rideDuration: rideDuration)
	}
	
	func testForDoubleSwipes() {
		
		print("\n====== Double Swipe Test ======\n")
		
		print("Initial swipe:\r")
			
		timer = NSTimer.scheduledTimerWithTimeInterval(timerStep, target: self, selector: #selector(decreaseTimer), userInfo: nil, repeats: true)
		
		rideController.validateRideAccess(entrant)
		
	}
	
	@objc private func decreaseTimer() {
		
		secondsRemaining -= timerStep
		secondsElapsed += timerStep
		
		print("Swipe attempt: \(secondsElapsed) Seconds elapsed: ")
		
		rideController.validateRideAccess(entrant)
		
		if secondsRemaining == 0 {
			
			timer.invalidate()
			
			print("====== Double Swipe Test Complete ======\n")
		}
	}
}
