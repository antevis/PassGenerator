//
//  ViewController.swift
//  PassGenerator
//
//  Created by Ivan Kazakov on 11/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		//let areas: [Area] = [.amusement]
		
		//UI Logic will definitely avoid force-unwrapping
		let classicGuestDOB = birthDayFromComponents(day: 1, month: 10, year: 1978)!
		let childGuestDOB = birthDayFromComponents(day: 13, month: 7, year: 2012)!
		let hefsDOB = birthDayFromComponents(day: 12, month: 12, year: 1985)!
		let hersDOB = birthDayFromComponents(day: 2, month: 11, year: 1978)!
		let hemtDOB = birthDayFromComponents(day: 13, month: 7, year: 1993)!
		let managerDOB = birthDayFromComponents(day: 28, month: 02, year: 1990)!
		
		let classicName = PersonFullName(firstName: "John", lastName: "Smith")
		let childName = PersonFullName(firstName: "Harry", lastName: nil)
		let hefsName = PersonFullName(firstName: "Maria", lastName: "Sanders")
		let hersName = PersonFullName(firstName: "Andrew", lastName: "Ricker")
		let hemtName = PersonFullName(firstName: "Peter", lastName: "Jackson")
		let managerName = PersonFullName(firstName: "Managus", lastName: "Treater")
		
		let hefsAddress: Address = Address(streetAddress: "Broadway 1", city: "New York", state: "NY", zip: "22222")
		let hersAddrsess = Address(streetAddress: "Poland str.", city: "Warsaw", state: "EU", zip: "33249")
		let hemtAddress = Address(streetAddress: "London str.", city: "Vilnius", state: "LT", zip: "23455")
		let managerAddress = Address(streetAddress: "Infinite Loop", city: "Cupertino", state: "CA", zip: "99982")
		
		let hefsSsn	= "333-22-5555"
		let hersSsn = "444-22-5555"
		let hemtSsn = "777-77-7777"
		let managerSsn = "000-00-0000"
		
		
		let classicGuest = ClassicGuest(birthDate: classicGuestDOB, fullName: classicName)
		
		let vipGuest = VipGuest()
		
		let freeChild = FreeChildGuest(birthDate: childGuestDOB, fullName: childName)
		
		let hefs = HourlyEmployeeCatering(fullName: hefsName, address: hefsAddress, ssn: hefsSsn, birthDate: hefsDOB)
		
		let hers = HourlyEmployeeRideService(fullName: hersName, address: hersAddrsess, ssn: hersSsn, birthDate: hersDOB)
		
		let hemt = HourlyEmployeeMaintenance(fullName: hemtName, address: hemtAddress, ssn: hemtSsn, birthDate: hemtDOB)
		
		let manager = Manager(tier: .shift, fullName: managerName, address: managerAddress, ssn: managerSsn, birthDate: managerDOB)
		
		
		let entrants: [Entrant] = [classicGuest, vipGuest, freeChild, hefs, hers, hemt, manager]
		let areas: [Area] = [Area.amusement, Area.kitchen, Area.maintenance, Area.office, Area.rideControl]
		
		
		//===========testing access
		for entrant in entrants {
			
			let rules = entrant.swipe()
			
			print("\(entrant.description):\r")
			print("\(rules.greeting)\r")
			
			//=========== Area access test (emulates pressing each of 5 possible options
			for area in areas {
				
				//testing access for all area
				print("\(area) area: \(area.testAccess(rules).message)")
			}
			print("\r")
			
			//=========== Ride Access test (general imformative message)
			print("\(rules.rideAccess.description())")
			print("\r")
			
			//Per category test (emulates pressing button for each of to possible options)
			print("Unlimited Ride Access: \(rules.rideAccess.testAccess(rules.rideAccess.unlimitedAccess).message)")
			
			print("Can Skip Lines: \(rules.rideAccess.testAccess(rules.rideAccess.skipLines).message)")
			print("\r")
			
			//=========== Discount Test
			discountTestOf(rules)
			print("===============\r")
			
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

