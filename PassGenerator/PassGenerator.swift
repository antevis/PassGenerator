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
	
	func testAccess(entryRules: EntryRules, makeSound: Bool = true) -> (accessGranted: Bool, message: String) {
		
		let sfx: SoundFX? = makeSound ? SoundFX() : nil
		
		let accessGranted = entryRules.areaAccess.contains(self)
		
		var message: String
		
		if accessGranted {
			
			message = "Access Granted"
			
			sfx?.loadGrantedSound()
		} else {
			
			message = "Access Denied"
			
			sfx?.loadDeniedSound()
		}
		
		sfx?.playSound()
		
		return (accessGranted, message)
	}
}

enum DiscountSubject: String {
	
	case food
	case merchandise
}

enum ManagementTier {
	
	case shift
	case general
	case senior
}

enum EntrantError: ErrorType {
	
	case NotAKidAnymore(yearThreshold: Int)
	
	case FirstNameMissing(message: String)
	case LastNameMissing(message: String)
	
	//these four represent non-optional types in all initializers, thus not handling them until part 2, when filling in the UI fields
	case SsnMissing(message: String)
	case DobMissing(message: String)
	case ManagerTierMissing(message: String)
	case dateOfBirthMissing(message: String)
	
	//these four being thrown from the Address init, but handling defered until UI in Part 2
	case AddressStreetMissing(message: String)
	case AddressCityMissing(message: String)
	case AddressStateMissing(message: String)
	case AddressZipMissing(message: String)
}

//MARK: structs

struct RideAccess {
	
	let unlimitedAccess: Bool
	let skipLines: Bool
	//	let seeEntrantAccessRules: Bool //Uncomment in Part 2
	
	func description() -> String {
		
		let rideAccess = "\(testAccess(self.unlimitedAccess, trueText: "Has Unlimited access to rides", falseText: "Has no access to rides").message)\r"
		
		let canSkip = "\(testAccess(self.skipLines, trueText: "Can Skip Lines", falseText: "Cannot Skip Lines").message)\r"
		
		return "\(rideAccess)\(canSkip)"
	}
	
	func testAccess(parameter: Bool, trueText: String = "Yes", falseText: String = "No", makeSound: Bool = true) -> (param: Bool, message: String) {
		
		let sfx: SoundFX? = makeSound ? SoundFX() : nil
		
		var message: String
		
		if parameter {
			
			message = trueText
			
			sfx?.loadGrantedSound()
			
		} else {
			
			message = falseText
			
			sfx?.loadDeniedSound()
		}
		
		sfx?.playSound()
		
		return (parameter, message)
	}
}

struct DiscountParams {
	
	let subject: DiscountSubject
	let discountValue: Double
	
	func description() -> String {
		
		return "Has discount of \(discountValue)% on \(subject)"
	}
}

struct EntryRules {
	
	let areaAccess: [Area]
	let rideAccess: RideAccess
	let discountAccess: [DiscountParams]?
	let greeting: String?
	
}

struct PersonFullName {
	
	let firstName: String?
	let lastName: String?
}

struct Address {
	
	let streetAddress: String
	let city: String
	let state: String
	let zip: String
	
	init(street: String?, city: String?, state: String?, zip: String?) throws {
		
		guard let street = street else {
			
			throw EntrantError.AddressStreetMissing(message: "*********ERROR*********\rStreet address missing\r*********ERROR*********\n")
		}
		guard let city = city else {
			
			throw EntrantError.AddressCityMissing(message: "*********ERROR*********\rCity missing\r*********ERROR*********\n")
		}
		guard let state = state else {
			
			throw EntrantError.AddressStateMissing(message: "*********ERROR*********\rState missing\r*********ERROR*********\n")
		}
		guard let zip = zip else {
			
			throw EntrantError.AddressZipMissing(message: "*********ERROR*********\rZIP-code missing\r*********ERROR*********\n")
		}
		
		self.city = city
		self.state = state
		self.streetAddress = street
		self.zip = zip
		
	}
}

//MARK: protocols

//Most protocols below deliberately define a single value, for maximum resilience in constructing objects

protocol Riding {
	
	var accessRules: RideAccess { get }
}

//Most entrants should conform to this
protocol DiscountClaimant {
	
	var discounts: [DiscountParams] { get }
}

//Hourly Employee, Manager, Season Pass Guest, Senior Guest, ContractEmployee, Vendor
protocol FullNameProvider {
	
	var fullName: PersonFullName? { get }
}

//Hourly Employee, Manager, Season Pass Guest, Contract Employee
protocol AddressProvider {
	
	var address: Address { get }
}

//Free Child Guest, Hourly Employee, Manager, Season Pass Guest, Senior Guest, Contract Employee, Vendor
protocol BirthdayProvider {
	
	var birthDate: NSDate? { get }
}

//Manager
protocol ManagementTierProvider {
	
	var tier: ManagementTier { get }
}

protocol DescriptionProvider {
	
	var description: String { get }
}

//Describes any type of entrant. Extended to BirthdayProvider for implementation of extra credit
//FullNameProvider - for optional names for all entrants.
protocol Entrant: Riding, BirthdayProvider, FullNameProvider, DescriptionProvider {
	
	var greeting: String { get }
	var accessibleAreas: [Area] { get }
	
	func swipe() -> EntryRules
}


//MARK: Auxilliary methods (Yes, I don't like word 'Helper'))



//Vendor, For Part 2
//protocol VisitDateDependant {
//
//	var visitDate: NSDate { get }
//}

//MARK: Entrant classes

//defines Employee properties - to be extended for each specific type of employee
//May seem over-complicated, but allows Hourly employees to be initialized in 3 lines of code
class Employee: Entrant, AddressProvider, DiscountClaimant {
	
	//Since SSN being requested from employees only, be it here
	let ssn: String
	let accessRules: RideAccess
	let accessibleAreas: [Area]
	let fullName: PersonFullName?
	let address: Address
	let birthDate: NSDate?
	let discounts: [DiscountParams]
	let greeting: String
	let description: String
	
	init(accessibleAreas: [Area], accessRules: RideAccess, discounts: [DiscountParams], fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate, description: String) throws {
		
		guard fullName.firstName != nil else {
			
			throw EntrantError.FirstNameMissing(message: "*********ERROR*********\rFirst Name Missing\r*********ERROR*********\n")
		}
		
		guard fullName.lastName != nil else {
			
			throw EntrantError.LastNameMissing(message: "*********ERROR*********\rLast Name Missing\r*********ERROR*********\n")
		}
		
		self.ssn = ssn
		self.accessibleAreas = accessibleAreas
		self.accessRules = accessRules
		self.fullName = fullName
		self.address = address
		self.birthDate = birthDate
		self.discounts = discounts
		
		self.greeting = Aux.composeGreetingConsidering(birthDate, forEntrant: fullName)
		
		self.description = description
	}
	
	convenience init(accessibleAreas: [Area], fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate, description: String) throws {
		
		let accessRules = RideAccess(unlimitedAccess: true, skipLines: false)
		
		let discounts: [DiscountParams] = [
			
			DiscountParams(subject: .food, discountValue: 15),
			DiscountParams(subject: .merchandise, discountValue: 25)
		]
		
		
		try self.init(accessibleAreas: accessibleAreas, accessRules: accessRules, discounts: discounts,fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: description)
	}
	
	func swipe() -> EntryRules {
		
		return EntryRules(areaAccess: accessibleAreas, rideAccess: accessRules, discountAccess: discounts, greeting: greeting)
	}
}

//To encapsulate all common guest properties.
class Guest: Entrant {
	
	var birthDate: NSDate?
	var fullName: PersonFullName?
	let greeting: String
	let accessRules: RideAccess
	let accessibleAreas: [Area]
	let description: String
	
	init(birthDate: NSDate? = nil, fullName: PersonFullName? = nil, accessRules: RideAccess, description: String) {
		
		self.accessibleAreas = [.amusement]
		self.greeting = Aux.composeGreetingConsidering(birthDate, forEntrant: fullName)
		self.accessRules = accessRules
		
		if let birthday = birthDate {
			
			self.birthDate = birthday
		}
		
		self.description = description
	}
	
	func swipe() -> EntryRules {
		
		return EntryRules(areaAccess: accessibleAreas, rideAccess: accessRules, discountAccess: nil, greeting: greeting)
	}
}

class ClassicGuest: Guest {
	
	init(birthDate: NSDate? = nil, fullName: PersonFullName? = nil, description: String = "Classic Guest") {
		
		let accessRules = RideAccess(unlimitedAccess: true, skipLines: false)
		super.init(birthDate: birthDate, fullName: fullName, accessRules: accessRules, description: description)
	}
}

class VipGuest: Guest, DiscountClaimant {
	
	let discounts: [DiscountParams]
	
	init(birthDate: NSDate? = nil, fullName: PersonFullName? = nil, description: String = "VIP Guest") {
		
		let accessRules = RideAccess(unlimitedAccess: true, skipLines: true)
		
		discounts = [
			
			DiscountParams(subject: .food, discountValue: 10),
			DiscountParams(subject: .merchandise, discountValue: 20)
		]
		
		super.init(birthDate: birthDate, fullName: fullName, accessRules: accessRules, description: description)
	}
	
	override func swipe() -> EntryRules {
		
		return EntryRules(areaAccess: accessibleAreas, rideAccess: accessRules, discountAccess: discounts, greeting: greeting)
	}
}

class FreeChildGuest: ClassicGuest {
	
	init(birthDate: NSDate, fullName: PersonFullName? = nil, description: String = "Free Child Guest") throws {
		
		if Aux.fullYearsFrom(birthDate) > 5 {
			
			throw EntrantError.NotAKidAnymore(yearThreshold: 5)
		}
		
		super.init(birthDate: birthDate, fullName: fullName, description: description)
	}
}

class HourlyEmployeeCatering: Employee {
	
	convenience init(fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate) throws {
		
		let accessibleAreas: [Area] = [.amusement, .kitchen]
		
		try self.init(accessibleAreas: accessibleAreas, fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: "Hourly Employee Food Services")
	}
}

class HourlyEmployeeRideService: Employee {
	
	convenience init(fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate) throws {
		
		let accessibleAreas: [Area] = [.amusement, .rideControl]
		
		try self.init(accessibleAreas: accessibleAreas, fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: "Hourly Employee Ride Services")
	}
}

class HourlyEmployeeMaintenance: Employee {
	
	convenience init(fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate) throws {
		
		let accessibleAreas: [Area] = [.amusement, .kitchen, .rideControl, .maintenance]
		
		try self.init(accessibleAreas: accessibleAreas, fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: "Hourly Employee Maintenance")
	}
}

class Manager: Employee, ManagementTierProvider {
	
	let tier: ManagementTier
	
	init(tier: ManagementTier, fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate) throws {
		
		self.tier = tier
		
		let accessibleAreas: [Area] = [.amusement, .kitchen, .rideControl, .maintenance, .office]
		let accessRules = RideAccess(unlimitedAccess: true, skipLines: false)
		
		let discounts: [DiscountParams] = [
			
			DiscountParams(subject: .food, discountValue: 25),
			DiscountParams(subject: .merchandise, discountValue: 25)
		]
		
		try super.init(accessibleAreas: accessibleAreas, accessRules: accessRules, discounts: discounts, fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: "\(tier) Manager")
	}
}

