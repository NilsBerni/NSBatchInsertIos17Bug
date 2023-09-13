//
//  CodableProperties.swift
//  CoreDataTest
//
//  Created by Nils Bernschneider on 11.09.23.
//

import Foundation
import CoreData

protocol CodableProperties: Codable {
    var dictionaryValue: [String: Any] { get }
}

struct SubprogressUICounter {
    
    var stepWeight: Double
    
    // weight: weight of this subprogress
    // totalSteps: total steps to complete subprogress
    init(weight: Double, totalSteps: Int) {
        self.stepWeight = weight / Double(totalSteps)
    }
    
    // go x steps of total steps
    func go(steps: Double = 1) {
        //LengoApiSync.shared.progressAppend(steps * stepWeight)
    }
}

extension Array where Element: CodableProperties {

    func newBatchInsertRequest(entity: NSEntityDescription, subprogressWeight: Double? = nil) -> NSBatchInsertRequest {
        var index = 0
        let total = self.count
        
        var subprogress: SubprogressUICounter?
        if let subprogressWeight {
            subprogress = SubprogressUICounter(weight: subprogressWeight, totalSteps: total / 10)
            subprogress?.go()
        }
        
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: entity, dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: self[index].dictionaryValue)
            index += 1
            
            if index % 10 == 0 {
                subprogress?.go()
            }
            return false
        })
        
        return batchInsertRequest
    }
}
