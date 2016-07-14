/*
//  ViewController.swift
//  PassGenerator
//
//  Created by Ivan Kazakov on 11/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//
// COMMENTS FOR REVIEWER'S TESTING PURPOSES MARKED //, INFORMATION COMMENTS MARKED: */

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		/* Do any additional setup after loading the view, typically from a nib.*/
		
		/*Sure no force-unwrapping in UI Part 2*/
		let classicGuestDOB = Aux.dateFromDMY(day: 1, month: 10, year: 1978)!
		let vipDOB = Aux.dateFromDMY(day: 4, month: 7, year: 1776)
		
		let childGuestDOB = Aux.dateFromDMY(day: 14, month: 7, year: Aux.year() - 4)! //passes age threshold for Free Kid
		//let childGuestDOB = Aux.dateFromDMY(day: 14, month: 7, year: Aux.year() - 6)! //throws 'Not a kid anymore'
		
		let hefsDOB = Aux.dateFromDMY(day: 12, month: 12, year: 1985)!
		let hersDOB = Aux.dateFromDMY(day: 2, month: 11, year: 1978)!
		
		let hemtDOB = Aux.todayBirthday(year: 1993)! //Always birthday on review date
		
		let managerDOB = Aux.todayBirthday(year: 1990)! //Always birthday on review date
		
		let classicName = PersonFullName(firstName: "John", lastName: "Smith")
		let vipName = PersonFullName(firstName: "Thomas", lastName: "Jefferson")
		let childName = PersonFullName(firstName: "Harry", lastName: nil)
		
		let hefsName = PersonFullName(firstName: "Maria", lastName: "Sanders") //passes mandatory first name
		//let hefsName = PersonFullName(firstName: nil, lastName: "Sanders") //throws 'Missing First Name'
		
		let hersName = PersonFullName(firstName: "Andrew", lastName: "Ricker") //passes mandatory last name
		//let hersName = PersonFullName(firstName: "Andrew", lastName: nil) //throws 'Missing last Name'
		
		let hemtName = PersonFullName(firstName: "Peter", lastName: "Jackson")
		let managerName = PersonFullName(firstName: "Managus", lastName: "Treater")
		
		/*UI fields filling will actually imlement throwing in case of missing data*/
		let hefsAddress: Address = try! Address(street: "Broadway 1", city: "New York", state: "NY", zip: "22222")
		let hersAddrsess = try! Address(street: "Poland str.", city: "Warsaw", state: "EU", zip: "33249")
		let hemtAddress = try! Address(street: "London str.", city: "Vilnius", state: "LT", zip: "23455")
		let managerAddress = try! Address(street: "Infinite Loop", city: "Cupertino", state: "CA", zip: "99982")
		
		let hefsSsn	= "333-22-5555"
		let hersSsn = "444-22-5555"
		let hemtSsn = "777-77-7777"
		let managerSsn = "000-00-0000"
		
		/*===========Init of Classic Guest. No possible errors exist for this type*/
		let classicGuestWithAll = ClassicGuest(birthDate: classicGuestDOB, fullName: classicName)
		let classicGuestWithDob = ClassicGuest(birthDate: classicGuestDOB)
		let classicGuestWithName = ClassicGuest(fullName: classicName)
		let classicGuestWithNone = ClassicGuest()
		
		/*===========Init of VIP Guest. No possible errors exist for this type*/
		let vipGuestWithNone = VipGuest()
		let vipGuestWithDob = VipGuest(birthDate: vipDOB)
		let vipGuestWithName = VipGuest(fullName: vipName)
		let vipguestWithAll = VipGuest(birthDate: vipDOB, fullName: vipName)
		
		var freeChild: FreeChildGuest?
		var hefs: HourlyEmployeeCatering?
		var hers: HourlyEmployeeRideService?
		var hemt: HourlyEmployeeMaintenance?
		var manager: Manager?
		
		var entrants: [Entrant] = [classicGuestWithAll, classicGuestWithNone, classicGuestWithName, classicGuestWithDob, vipGuestWithDob, vipGuestWithNone, vipGuestWithDob, vipGuestWithName, vipguestWithAll]
		
		/*Error-handling at the stage of objects initialization makes sense only when required fields are wrapped inside another object or when the successful unit depends on the value iteslf rather than on its existence. This leaves us with First/Last names for employees, which are wrapped inside PersonFullName object, and value of date of birth for Free Kid.*/
		
		/*===========Init of Free Child===================*/
		do {
			
			try freeChild = FreeChildGuest(birthDate: childGuestDOB, fullName: childName)
			
			/*can safely do it here as in case of error above the control flow immediately transfers to catch blocks and next lines are unreachable.*/
			if let freeChild = freeChild {
				
				entrants.append(freeChild)
			}
		
		} catch EntrantError.NotAKidAnymore(let yearThreshold) {
			
			print("*********ERROR*********\rLooks too grown-up for \(yearThreshold)-year old:)\r*********ERROR*********\n")
		
		/*For the purposes of 'Exhaustiveness' as we are not inside of a throwing method*/
		} catch {
			
			fatalError("Something really bad and unpredictable happened")
		}
		/*================================================*/
		
		/*===========Init of FOOD Services Hourly Employee*/
		do {
			
			try hefs = HourlyEmployeeCatering(fullName: hefsName, address: hefsAddress, ssn: hefsSsn, birthDate: hefsDOB)
			
			/*can safely do it here as in case of error above the control flow immediately transfers to catch blocks and next lines are unreachable.*/
			if let hefs = hefs {
				
				entrants.append(hefs)
			}
		
		} catch EntrantError.FirstNameMissing(let msg) {
			
			print(msg)
			
		} catch EntrantError.LastNameMissing(let msg) {
			
			print(msg)
		
		/*For the purposes of 'Exhaustiveness' as we are not inside of a throwing method*/
		} catch {
			
			fatalError("Something really bad and unpredictable happened")
		}
		/*================================================*/
		
		/*===========Init of RIDE Services Hourly Employee*/
		do {
			
			try hers = HourlyEmployeeRideService(fullName: hersName, address: hersAddrsess, ssn: hersSsn, birthDate: hersDOB)
			
			if let hers = hers {
				
				entrants.append(hers)
			}
			
		} catch EntrantError.FirstNameMissing(let msg) {
			
			print(msg)
			
		} catch EntrantError.LastNameMissing(let msg) {
			
			print(msg)
			
		/*For the purposes of 'Exhaustiveness' as we are not inside of a throwing method*/
		} catch {
			
			fatalError("Something really bad and unpredictable happened")
		}
		/*================================================*/
		
		/*===========Init of MAINTENANCE Services Hourly Employee*/
		do {
			
			try hemt = HourlyEmployeeMaintenance(fullName: hemtName, address: hemtAddress, ssn: hemtSsn, birthDate: hemtDOB)
			
			if let hemt = hemt {
				
				entrants.append(hemt)
			}
			
		} catch EntrantError.FirstNameMissing(let msg) {
			
			print(msg)
			
		} catch EntrantError.LastNameMissing(let msg) {
			
			print(msg)
			
		/*For the purposes of 'Exhaustiveness' as we are not inside of a throwing method*/
		} catch {
			
			fatalError("Something really bad and unpredictable happened")
		}
		/*================================================*/
		
		/*===========Init of MANAGER Services Hourly Employee*/
		do {
			
			try manager = Manager(tier: .shift, fullName: managerName, address: managerAddress, ssn: managerSsn, birthDate: managerDOB)
			
			if let manager = manager {
				
				entrants.append(manager)
			}
			
		} catch EntrantError.FirstNameMissing(let msg) {
			
			print(msg)
			
		} catch EntrantError.LastNameMissing(let msg) {
			
			print(msg)
			
		/*For the purposes of 'Exhaustiveness' as we are not inside of a throwing method*/
		} catch {
			
			fatalError("Something really bad and unpredictable happened")
		}
		/*===============================================*/
		
		let areas: [Area] = [Area.amusement, Area.kitchen, Area.maintenance, Area.office, Area.rideControl]
		
		/*===========testing access*/
		for entrant in entrants {
			
			let rules = entrant.swipe()
			
			print("\(entrant.description)\n")
			
			print("\(rules.greeting)\n")
			
			/*=========== Area access test (emulates button touch for each of 5 possible area options*/
			for area in areas {
				
				/*testing access for all area*/
				print("\(area) area: \(area.testAccess(rules).message)")
			}
			print("\r")
			
			/*=========== Ride Access test (general imformative message)*/
			print("\(rules.rideAccess.description())")
			print("\r")
			
			/*=========== Ride Access test: Per category test (emulates button touch for each of possible options)*/
			print("Unlimited Ride Access: \(rules.rideAccess.testAccess(rules.rideAccess.unlimitedAccess).message)")
			print("Can Skip Lines: \(rules.rideAccess.testAccess(rules.rideAccess.skipLines).message)")
			
			print("\r")
			
			/*=========== Discount Test*/
			Aux.discountTestOf(rules)
			print("======================================================\r")
		}
		
		/*=========== testing for double swipes per 1 ride*/
		let doubleSwipeTester: DoubleSwipeTester = DoubleSwipeTester(entrant: classicGuestWithAll, testDurationSeconds: 19, timeStepSeconds: 1, rideDuration: 5)
		doubleSwipeTester.testForDoubleSwipes()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		/* Dispose of any resources that can be recreated.*/
	}
}

