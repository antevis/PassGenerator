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



//MARK: protocols

protocol EntrantName {
	
	var firstName: String { get }
	var lastName: String { get }
}

protocol EntrantAddress {
	
	var streetAddress: String { get }
	var city: String { get }
	var state: String { get }
	var zip: String { get }
	
}

protocol Birthday {
	
	var birthDate: NSDate { get }
}

protocol VisitDate {
	
	var visitDate: NSDate { get }
}

protocol Entrant {
	
	func swipe() -> EntrantRules
}
