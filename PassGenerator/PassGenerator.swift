//
//  PassGenerator.swift
//  PassGenerator
//
//  Created by Ivan Kazakov on 11/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import Foundation

//MARK: enums

enum Area {
	
	case amusement
	case kitchen
	case rideControl
	case maintenance
	case office
}

enum DiscountSubject {
	
	case food
	case merchandise
}

enum ManagementTier {
	
	case shift
	case general
	case senior
}


//MARK: structs

struct RideAccess {
	
	let unlimitedAccess: Bool
	let skipLines: Bool
//	let seeEntrantAccessRules: Bool //Uncomment in Part 2
}

struct DiscountParams {
	
	let subject: DiscountSubject
	let discountValue: Double
}


struct EntrantRules {
	
	let areaAccess: [Area]
	let rideAccess: RideAccess
	let discountAccess: [DiscountParams]?
	
}

struct PersonFullName {
	
	let firstName: String
	let lastName: String
}

struct Address {
	
	let streetAddress: String
	let city: String
	let state: String
	let zip: String
}


//MARK: protocols

//Most protocols below deliberately define a single value, for absolute resшlience in constructing objects

//Most entrants conform to this
protocol DiscountClaimant {
	
	var discounts: [DiscountParams] { get }
}

//Hourly Employee, Manager, Season Pass Guest, Senior Guest, ContractEmployee, Vendor
protocol FullNameProvider {
	
	var fullName: PersonFullName { get }
}

//Hourly Employee, Manager, Contract Employee
protocol SSNProvider {
	
	var ssn: String { get }
}

//Hourly Employee, Manager, Season Pass Guest, Contract Employee
protocol AddressProvider {
	
	var address: Address { get }
	
}

//Free Child Guest, Hourly Employee, Manager, Season Pass Guest, Senior Guest, Contract Employee, Vendor
protocol BirthdayProvider {
	
	var birthDate: NSDate { get }
}

//Vendor, For Part 2
//protocol VisitDateDependant {
//	
//	var visitDate: NSDate { get }
//}

//Manager
protocol ManagementTierProvider {
	
	var tier: ManagementTier { get }
}

//Joins those who have to provide both: Employees, Managers
protocol PersonalDataProvider: FullNameProvider, SSNProvider {
	
}

//defines Employee properties
protocol Employee: Entrant, FullNameProvider, AddressProvider, BirthdayProvider, DiscountClaimant {
	

}

//extends employee properties with Management Tier
protocol Manager: Employee, ManagementTierProvider {
	
}

//Describes any type of entrant.
protocol Entrant {
	
	var accessibleAreas: [Area] { get }
	var accessRules: RideAccess { get }
	
	func swipe() -> EntrantRules
}

//MARK: Entrant classes

class ClassicGuest: Entrant {
	
	let accessibleAreas: [Area] = [.amusement]
	let accessRules: RideAccess = RideAccess(unlimitedAccess: true, skipLines: false)
	
	func swipe() -> EntrantRules {
		return EntrantRules(areaAccess: accessibleAreas, rideAccess: accessRules, discountAccess: nil)
	}
}

class VipGuest: Entrant, DiscountClaimant {
	
	let accessibleAreas: [Area] = [.amusement]
	let accessRules: RideAccess = RideAccess(unlimitedAccess: true, skipLines: true)
	
	let discounts: [DiscountParams] = [
		
		DiscountParams(subject: .food, discountValue: 10),
		DiscountParams(subject: .merchandise, discountValue: 20)
	]
	
	func swipe() -> EntrantRules {
		
		return EntrantRules(areaAccess: accessibleAreas, rideAccess: accessRules, discountAccess: discounts)
	}
}

class FreeChildGuest: ClassicGuest, BirthdayProvider {
	
	let birthDate: NSDate
	
	init(birthDate: NSDate) {
		
		self.birthDate = birthDate
	}
}

class HourlyEmployeeCatering: Employee {
	
	let accessibleAreas: [Area] = [.amusement, .kitchen]
	let accessRules: RideAccess = RideAccess(unlimitedAccess: true, skipLines: false)
	
	func swipe() -> EntrantRules {
		return EntrantRules(areaAccess: accessibleAreas, rideAccess: accessRules, discountAccess: nil)
	}
	
	let discounts: [DiscountParams] = [
		
		DiscountParams(subject: .food, discountValue: 15),
		DiscountParams(subject: .merchandise, discountValue: 25)
	]
	
	let birthDate: NSDate
	
	let fullName: PersonFullName
	
	let ssn: String
	
	let address: Address
	
	init(birthDate: NSDate, fullName: PersonFullName, socSecNumber: String, address: Address) {
		
		self.birthDate = birthDate
		self.fullName = fullName
		self.ssn = socSecNumber
		self.address = address
	}
}


