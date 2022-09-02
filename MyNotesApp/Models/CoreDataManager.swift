//
//  CoreDataManager.swift
//  MyNotesApp
//
//  Created by Алексей Павленко on 01.09.2022.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager(modelName: "MyNotesApp")
    
    let modelName: String
    init(modelName: String) {
        self.modelName = modelName
    }
    
    //Create NSPersistentContainer
    lazy private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unable to load persistent stores \(error.localizedDescription)")
            }
        }
        
        return container
    }()
    
    //Get fetchedResultsController From CoreData
    func fetchedResultsController(filter: String?) -> NSFetchedResultsController<Note> {
        //creates fetch request
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \Note.lastUpdated, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let filter = filter {
            let predicate = NSPredicate(format: "text contains[cd] %@", filter)
            fetchRequest.predicate = predicate
        }
        
        return NSFetchedResultsController<Note>(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    //Create ViewContex from CoreData
    private var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    //Add Note to CoreData
    func createNote() -> Note {
        let note = Note(context: viewContext)
        note.id = UUID()
        note.text = ""
        note.lastUpdated = Date()
        save()
        return note
    }
    
    //Remove Note from CoreData
    func delete(_ note: Note) {
        viewContext.delete(note)
        save()
    }
    
    func save() {
        do {
            try viewContext.save()
        } catch let error {
            print("Failed to save.", error.localizedDescription)
        }
    }
    
}

