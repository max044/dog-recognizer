//
//  MyHistoricDB+CoreDataProperties.swift
//  Dog Recognizer
//
//  Created by Maxence Cabiddu on 09/05/2023.
//
//

import Foundation
import CoreData


extension MyHistoricDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyHistoricDB> {
        return NSFetchRequest<MyHistoricDB>(entityName: "MyHistoricDB")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var picture: Data?
    @NSManaged public var predictions: String?

}
