//
//  Entrants.swift
//  PassGenerator
//
//  Created by Ivan Kazakov on 14/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import Foundation

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

//Due to equality of discount params for VIP and seasonal, the latter could be made inheriting from VIP + conforming to AddressProvider, but the match considered as coincidencial, not intentional
class SeasonPassGuest: Guest, DiscountClaimant, AddressProvider {
	
	let discounts: [DiscountParams]
	let address: Address
	
	init(birthDate: NSDate, fullName: PersonFullName, address: Address) {
		
		let accessRules = RideAccess(unlimitedAccess: true, skipLines: true)
		
		//declaration extracted for clarity
		let description: String = "Season Pass Guest"
		
		self.discounts = [
			
			DiscountParams(subject: .food, discountValue: 10),
			DiscountParams(subject: .merchandise, discountValue: 20)
		]
		
		self.address = address
		
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