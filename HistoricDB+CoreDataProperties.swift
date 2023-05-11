//
//  HistoricDB+CoreDataProperties.swift
//  Dog Recognizer
//
//  Created by Maxence Cabiddu on 09/05/2023.
//
//

import Foundation
import CoreData


extension HistoricDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoricDB> {
        return NSFetchRequest<HistoricDB>(entityName: "HistoricDB")
    }

    @NSManaged public var picture: Data?
    @NSManaged public var predictions: String?
    @NSManaged public var dateOfCreation: Date?

}

extension HistoricDB : Identifiable {

}
