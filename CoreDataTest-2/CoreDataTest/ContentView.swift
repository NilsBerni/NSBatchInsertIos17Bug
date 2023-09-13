//
//  ContentView.swift
//  CoreDataTest
//
//  Created by Nils Bernschneider on 29.08.23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.iVal, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.iVal)")
                    } label: {
                        Text("\(item.iVal)")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: batchInsert) {
                        Label("Batch Insert", systemImage: "text.insert")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.iVal = -1

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func batchInsert() {
        withAnimation {
            var propertiesArray = [[String:Any]]()
            for n in 0..<1000 {
                
                let ownDict: Dictionary<String, [String]> = ["en": ["test"], "de": ["test"]]
                propertiesArray.append([
                    "iVal": -1,
                    "iVal_pushed": false,
                    "last_retrieval": 1230,
                    "lec": 0,
                    "obj": 0,
                    "lng": "en",
                    "sel": ["test"],
                    "own": ownDict
                ])
            }

            var index = 0
            let total = propertiesArray.count
            let batchInsertRequest = NSBatchInsertRequest(entityName: "Item", dictionaryHandler: { dictionary in
                guard index < total else 
                { 
                    return true
                }
                dictionary.addEntries(from: propertiesArray[index])
                index += 1
                
                if index % 10 == 0 {
                    //subprogress?.go()
                }
                return false
            })
            if let fetchResult = try? viewContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                print(success)
            }

//            var insertResult : NSBatchInsertResult
//            do {
//                insertResult = try viewContext.execute(batchInsert) as! NSBatchInsertResult
//                print(insertResult.description)
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
