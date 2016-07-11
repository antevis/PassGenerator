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


struct EntryRules {
	
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

//Most protocols below deliberately define a single value, for absolute resilience in constructing objects

protocol Riding {
	
	var accessRules: RideAccess { get }
}

//Most entrants should conform to this
protocol DiscountClaimant {
	
	var discounts: [DiscountParams] { get }
}

//Hourly Employee, Manager, Season Pass Guest, Senior Guest, ContractEmployee, Vendor
protocol FullNameProvider {
	
	var fullName: PersonFullName { get }
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

//defines Employee properties
protocol Employee: Entrant, FullNameProvider, AddressProvider, BirthdayProvider, DiscountClaimant {

	//Since SSN requested from employees only, be it here
	var ssn: String { get }
}

//extends employee properties with Management Tier
protocol ManagerType: Employee, ManagementTierProvider {
	
}

//Describes any type of entrant.
protocol Entrant: Riding {
	
	var accessibleAreas: [Area] { get }
	
	func swipe() -> EntryRules
}

extension Entrant {
	
	//Default swipe implementation
	func swipe() -> EntryRules {
		return EntryRules(areaAccess: accessibleAreas, rideAccess: accessRules, discountAccess: nil)
	}
}

class Hourly: DiscountClaimant, FullNameProvider, AddressProvider, BirthdayProvider {
	
	let accessRules: RideAccess = RideAccess(unlimitedAccess: true, skipLines: false)
	
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



//MARK: Entrant classes

class ClassicGuest: Entrant {
	
	let accessibleAreas: [Area] = [.amusement]
	let accessRules: RideAccess = RideAccess(unlimitedAccess: true, skipLines: false)
}

class VipGuest: Entrant, DiscountClaimant {
	
	let accessibleAreas: [Area] = [.amusement]
	let accessRules: RideAccess = RideAccess(unlimitedAccess: true, skipLines: true)
	
	let discounts: [DiscountParams] = [
		
		DiscountParams(subject: .food, discountValue: 10),
		DiscountParams(subject: .merchandise, discountValue: 20)
	]
	
	func swipe() -> EntryRules {
		
		return EntryRules(areaAccess: accessibleAreas, rideAccess: accessRules, discountAccess: discounts)
	}
}

class FreeChildGuest: ClassicGuest, BirthdayProvider {
	
	let birthDate: NSDate
	
	init(birthDate: NSDate) {
		
		self.birthDate = birthDate
	}
}

class HourlyEmployeeCatering: Hourly, Employee {
	
	let accessibleAreas: [Area] = [.amusement, .kitchen]
}

class HourlyEmployeeRideServices: Hourly, Employee {
	
	let accessibleAreas: [Area] = [.amusement, .rideControl]
}

class HourlyEmployeeMaintenance: Hourly, Employee {
	
	let accessibleAreas: [Area] = [.amusement, .kitchen, .rideControl, .maintenance]
}

class Manager: ManagerType {
	
	let accessibleAreas: [Area] = [.amusement, .kitchen, .rideControl, .maintenance, .office]
	
	let accessRules: RideAccess = RideAccess(unlimitedAccess: true, skipLines: false)
	
	let discounts: [DiscountParams] = [
		
		DiscountParams(subject: .food, discountValue: 25),
		DiscountParams(subject: .merchandise, discountValue: 25)
	]
	
	let birthDate: NSDate
	
	let fullName: PersonFullName
	
	let ssn: String
	
	let address: Address
	
	let tier: ManagementTier
	
	init(birthDate: NSDate, fullName: PersonFullName, socSecNumber: String, address: Address, tier: ManagementTier) {
		
		self.birthDate = birthDate
		self.fullName = fullName
		self.ssn = socSecNumber
		self.address = address
		self.tier = tier
	}
	
	
}

