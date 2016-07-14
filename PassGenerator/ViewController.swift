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
		let classicGuestDOB = dateFromComponents(day: 1, month: 10, year: 1978)!
		
		//let childGuestDOB = dateFromComponents(day: 14, month: 7, year: 2010)! //throws an error
		let childGuestDOB = dateFromComponents(day: 14, month: 7, year: 2012)! //passes age threshold for Free Kid
		
		let hefsDOB = dateFromComponents(day: 12, month: 12, year: 1985)!
		let hersDOB = dateFromComponents(day: 2, month: 11, year: 1978)!
		let hemtDOB = dateFromComponents(day: 14, month: 7, year: 1993)!
		let managerDOB = dateFromComponents(day: 28, month: 02, year: 1990)!
		
		let classicName = PersonFullName(firstName: "John", lastName: "Smith")
		let childName = PersonFullName(firstName: "Harry", lastName: nil)
		let hefsName = PersonFullName(firstName: "Maria", lastName: "Sanders")
		let hersName = PersonFullName(firstName: "Andrew", lastName: "Ricker")
		let hemtName = PersonFullName(firstName: "Peter", lastName: "Jackson")
		let managerName = PersonFullName(firstName: "Managus", lastName: "Treater")
		
		//UI fields filling will actually imlement throwing in case of missing data
		let hefsAddress: Address = try! Address(street: "Broadway 1", city: "New York", state: "NY", zip: "22222")
		let hersAddrsess = try! Address(street: "Poland str.", city: "Warsaw", state: "EU", zip: "33249")
		let hemtAddress = try! Address(street: "London str.", city: "Vilnius", state: "LT", zip: "23455")
		let managerAddress = try! Address(street: "Infinite Loop", city: "Cupertino", state: "CA", zip: "99982")
		
		let hefsSsn	= "333-22-5555"
		let hersSsn = "444-22-5555"
		let hemtSsn = "777-77-7777"
		let managerSsn = "000-00-0000"
		
		
		//===========Init of Classic Guest. No possible errors exist for this type
		let classicGuest = ClassicGuest(birthDate: classicGuestDOB, fullName: classicName)
		
		//===========Init of VIP Guest. No possible errors exist for this type
		let vipGuest = VipGuest()
		
		var freeChild: FreeChildGuest?
		var hefs: HourlyEmployeeCatering?
		var hers: HourlyEmployeeRideService?
		var hemt: HourlyEmployeeMaintenance?
		var manager: Manager?
		
		
		var entrants: [Entrant] = [classicGuest, vipGuest]
		
		//===========Init of Free Child===================
		do {
			
			try freeChild = FreeChildGuest(birthDate: childGuestDOB, fullName: childName)
			
			//can safely do it here as in case of error above the control flow immediately transfers to catch blocks and next lines are unreachable.
			if let freeChild = freeChild {
				
				entrants.append(freeChild)
			}
		
		} catch EntrantError.NotAKidAnymore(let yearThreshold) {
			
			print("Looks too grown-up for \(yearThreshold)-old:)\n")
		
		//For the purposes of 'Exhaustiveness'
		} catch {
			
			fatalError("Something real bad and unpredictabe happened")
		}
		//================================================
		
		//===========Init of FOOD Services Hourly Employee
		do {
			
			try hefs = HourlyEmployeeCatering(fullName: hefsName, address: hefsAddress, ssn: hefsSsn, birthDate: hefsDOB)
			
			//can safely do it here as in case of error above the control flow immediately transfers to catch blocks and next lines are unreachable.
			if let hefs = hefs {
				
				entrants.append(hefs)
			}
		
		} catch EntrantError.FirstNameMissing(let msg) {
			
			print(msg)
			
		} catch EntrantError.LastNameMissing(let msg) {
			
			print(msg)
		
		//For the purposes of 'Exhaustiveness'
		} catch {
			
			fatalError("Something real bad and unpredictabe happened")
		}
		//================================================
		
		//===========Init of RIDE Services Hourly Employee
		do {
			
			try hers = HourlyEmployeeRideService(fullName: hersName, address: hersAddrsess, ssn: hersSsn, birthDate: hersDOB)
			
			if let hers = hers {
				
				entrants.append(hers)
			}
			
		} catch EntrantError.FirstNameMissing(let msg) {
			
			print(msg)
			
		} catch EntrantError.LastNameMissing(let msg) {
			
			print(msg)
			
			//For the purposes of 'Exhaustiveness'
		} catch {
			
			fatalError("Something real bad and unpredictabe happened")
		}
		//================================================
		
		//===========Init of MAINTENANCE Services Hourly Employee
		do {
			
			try hemt = HourlyEmployeeMaintenance(fullName: hemtName, address: hemtAddress, ssn: hemtSsn, birthDate: hemtDOB)
			
			if let hemt = hemt {
				
				entrants.append(hemt)
			}
			
		} catch EntrantError.FirstNameMissing(let msg) {
			
			print(msg)
			
		} catch EntrantError.LastNameMissing(let msg) {
			
			print(msg)
			
			//For the purposes of 'Exhaustiveness'
		} catch {
			
			fatalError("Something real bad and unpredictabe happened")
		}
		//================================================
		
		//===========Init of MANAGER Services Hourly Employee
		do {
			
			try manager = Manager(tier: .shift, fullName: managerName, address: managerAddress, ssn: managerSsn, birthDate: managerDOB)
			
			if let manager = manager {
				
				entrants.append(manager)
			}
			
		} catch EntrantError.FirstNameMissing(let msg) {
			
			print(msg)
			
		} catch EntrantError.LastNameMissing(let msg) {
			
			print(msg)
			
			//For the purposes of 'Exhaustiveness'
		} catch {
			
			fatalError("Something real bad and unpredictabe happened")
		}
		//===============================================
		
		
		let areas: [Area] = [Area.amusement, Area.kitchen, Area.maintenance, Area.office, Area.rideControl]
		
		
		//===========testing access
		for entrant in entrants {
			
			let rules = entrant.swipe()
			
			print("\(entrant.description)\n")
			
			if let greeting = rules.greeting {
				
				print("\(greeting)\n")
			}
			
			
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
			print("======================================================\r")
			
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

