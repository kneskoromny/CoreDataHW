//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Кирилл Нескоромный on 11.05.2021.
//

import UIKit
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context = persistentContainer.viewContext
    
    lazy var taskList = fetchData()
    
    private init() {}
    
    // MARK: - Core Data Saving support
    func saveContextFatalError() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Public methods
    func save(_ taskName: String) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        task.title = taskName
        taskList.append(task)
        
        saveContext()
    }
    
    func edit(taskString: String, index: Int) {
        let task = taskList[index]
        task.title = taskString
        
        saveContext()
    }
    
    func delete(_ index: Int) {
        let itemToDelete = taskList[index]
        context.delete(itemToDelete)
        taskList.remove(at: index)
        
        saveContext()
    }
    
    func fetchData() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            let tasks = try context.fetch(fetchRequest)
            return tasks
        } catch let error {
            print(error)
        }
        return []
    }
}
