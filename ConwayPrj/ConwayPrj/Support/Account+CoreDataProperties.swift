//
//  Account+CoreDataProperties.swift
//  ConwayPrj
//
//  Created by Jose on 06/04/2018.
//  Copyright © 2018 Jose. All rights reserved.
//
//

import Foundation
import CoreData


extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var publickey: String?
    @NSManaged public var privatekey: String?

}
