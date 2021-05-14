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
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // свойство viewcontext == база данных
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext }
    
    private init() {}
    
    // MARK: - Core Data Saving support
    // метод сохраняет базу данных
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Public methods
    // сохраняем объект в базе данных, в completion происходит захват задачи для дальнейшей передачи в контроллер
    func save(_ taskName: String, completion: (Task) -> Void) {
        // создание экземпляра модели через entitydescription более надежный
//        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: viewContext) else { return }
//        guard let task = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? Task else { return }
        
        // создание экземпляра модели через инициализатор менее надежный
        let task = Task(context: viewContext)
        task.title = taskName
        
        // захватываем тип данных
        completion(task)
        saveContext()
    }
    
    func edit(_ task: Task, newName: String) {
        // присваиваем новое имя для задачи
        task.title = newName
        
        saveContext()
    }
    
    func delete(_ task: Task) {
        // удаляем объект из базы
        viewContext.delete(task)
        
        saveContext()
    }
    
    // захватываем данные из базы данных для дальнейшей передачи
    func fetchData(completion: (Result<[Task], Error>) -> Void)  {
        // формируем запрос
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            // загружаем базу в массив
            let tasks = try viewContext.fetch(fetchRequest)
            // захватываем массив для дальнейшей передачи его в контроллере
            completion(.success(tasks))
        } catch let error {
            completion(.failure(error))
        }
    }
}
