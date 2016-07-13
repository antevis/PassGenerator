//
//  PassGenerator.swift
//  PassGenerator
//
//  Created by Ivan Kazakov on 11/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import Foundation
import AudioToolbox

//MARK: enums

var gameSound: SystemSoundID = 0

enum Area {
	
	case amusement
	case kitchen
	case rideControl
	case maintenance
	case office
	
	func testAccess(entryRules: EntryRules) -> (accessGranted: Bool, message: String) {
		
		let accessGranted = entryRules.areaAccess.contains(self)
		
		var message: String
		
		if accessGranted {
			
			message = "Access Granted"
			
			loadGrantedSound()
		} else {
			
			message = "Access Denied"
			
			loadDeniedSound()
		}
		
		playSound()
		
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
	
	func testAccess(parameter: Bool, trueText: String = "Yes", falseText: String = "No", makeSound: Bool = false) -> (param: Bool, message: String) {
		
		var message: String
		
		if parameter {
			
			message = trueText
			
			loadGrantedSound()
			
		} else {
			
			message = falseText
			
			loadDeniedSound()
		}
		
		if makeSound {
			
			playSound()
		}
		
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

func composeGreetingConsidering(birthday: NSDate?, forEntrant fullName: PersonFullName?) -> String {
	
	//Every entrant will eventually get at least "Hello" in the Entrant rules.
	//Well, next 4 lines seem ugly. Knowing of ?? operator, will probably fix later.
	var addressing: String = ""
	
	if let name = fullName?.firstName {
		
		addressing += ", \(name)"
	}
	
	var greeting: String = "Hello\(addressing)"
	
	if let birthday = birthday {
		
		//Borrowed from @thedan84
		let calendar = NSCalendar.currentCalendar()
		let today = calendar.components([.Month, .Day], fromDate: NSDate())
		let bday = calendar.components([.Month, .Day], fromDate: birthday)
		
		if today.month == bday.month && today.day == bday.day {
			
			greeting += ", Happy Birthday!"
			
		} else {
			
			greeting += "!"
		}
	}
	
	return greeting
}

func birthDayFromComponents(day day: Int, month: Int, year: Int) -> NSDate? {
	
	let dateComponents: NSDateComponents = NSDateComponents()
	dateComponents.day = day
	dateComponents.month = month
	dateComponents.year = year
	
	let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
	
	return calendar?.dateFromComponents(dateComponents)
}

func discountTestOf(rules: EntryRules) {
	
	guard let discounts = rules.discountAccess where discounts.count > 0 else {
		
		print("No discounts found")
		
		return
	}
	
	for discount in discounts {
		
		print(discount.description())
	}
}

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
	
	init(accessibleAreas: [Area], accessRules: RideAccess, discounts: [DiscountParams], fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate, description: String) {
		
		self.ssn = ssn
		self.accessibleAreas = accessibleAreas
		self.accessRules = accessRules
		self.fullName = fullName
		self.address = address
		self.birthDate = birthDate
		self.discounts = discounts
		
		self.greeting = composeGreetingConsidering(birthDate, forEntrant: fullName)
		
		self.description = description
	}
	
	convenience init(accessibleAreas: [Area], fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate, description: String) {
		
		let accessRules = RideAccess(unlimitedAccess: true, skipLines: false)
		
		let discounts: [DiscountParams] = [
			
			DiscountParams(subject: .food, discountValue: 15),
			DiscountParams(subject: .merchandise, discountValue: 25)
		]
		
		self.init(accessibleAreas: accessibleAreas, accessRules: accessRules, discounts: discounts,fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: description)
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
		self.greeting = composeGreetingConsidering(birthDate, forEntrant: fullName)
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
	
	init(birthDate: NSDate, fullName: PersonFullName? = nil, description: String = "Free Child Guest") {
		
		super.init(birthDate: birthDate, fullName: fullName, description: description)
	}
}

class HourlyEmployeeCatering: Employee {
	
	convenience init(fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate){
		
		let accessibleAreas: [Area] = [.amusement, .kitchen]
		self.init(accessibleAreas: accessibleAreas, fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: "Hourly Employee Food Services")
	}
}

class HourlyEmployeeRideService: Employee {
	
	convenience init(fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate){
		
		let accessibleAreas: [Area] = [.amusement, .rideControl]
		self.init(accessibleAreas: accessibleAreas, fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: "Hourly Employee Ride Services")
	}
}

class HourlyEmployeeMaintenance: Employee {
	
	convenience init(fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate){
		
		let accessibleAreas: [Area] = [.amusement, .kitchen, .rideControl, .maintenance]
		self.init(accessibleAreas: accessibleAreas, fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: "Hourly Employee Maintenance")
	}
}

class Manager: Employee, ManagementTierProvider {
	
	let tier: ManagementTier
	
	init(tier: ManagementTier, fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate) {
		
		self.tier = tier
		let accessibleAreas: [Area] = [.amusement, .kitchen, .rideControl, .maintenance, .office]
		let accessRules: RideAccess = RideAccess(unlimitedAccess: true, skipLines: false)
		let managerDiscounts: [DiscountParams] = [
			
			DiscountParams(subject: .food, discountValue: 25),
			DiscountParams(subject: .merchandise, discountValue: 25)
		]
		
		super.init(accessibleAreas: accessibleAreas, accessRules: accessRules, discounts: managerDiscounts, fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: "\(self.tier) Manager")
	}
}

//MARK: Audioservices
func loadGrantedSound() {
	
	AudioServicesCreateSystemSoundID(soundUrlFor(file: "AccessGranted", ofType: "wav"), &gameSound)
}

func loadDeniedSound() {
	
	AudioServicesCreateSystemSoundID(soundUrlFor(file: "AccessDenied", ofType: "wav"), &gameSound)
}

func playSound(){
	
	AudioServicesPlaySystemSound(gameSound)
}

func soundUrlFor(file fileName: String, ofType: String) -> NSURL {
	
	let pathToSoundFile = NSBundle.mainBundle().pathForResource(fileName, ofType: ofType)
	return NSURL(fileURLWithPath: pathToSoundFile!)
}
