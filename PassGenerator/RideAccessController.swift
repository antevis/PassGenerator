//
//  RideAccessController.swift
//  PassGenerator
//
//  Created by Ivan Kazakov on 14/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import Foundation

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
			
			if !self.rideSwiped {
				
				//For simplicity ride considered started right after swiping
				rideSwiped = true
				ride?.startRide(rideDuration: 5)
				
				print("Welcome!")
				
			} else {
				
				let sfx: SoundFX? = makeSound ? SoundFX() : nil
				
				sfx?.loadDeniedSound()
				sfx?.playSound()
				
				print("Ride is in progress, one swipe per ride, please.")
			}
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
