//
//  AlertController.swift
//  CoreDataDemo
//
//  Created by Кирилл Нескоромный on 14.05.2021.
//

import UIKit

class AlertController: UIAlertController {
    // принимает опциональный тип, тк экземпляр класса в главном контроллере также принимает опционал, в completion происходит захват того, что внесли в текстовое поле
    func action(task: Task?, completion: @escaping (String) -> Void) {
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            // излекаем значение из текстового поля
            guard let newValue = self.textFields?.first?.text else { return }
            // проверяем на пустую строку
            guard !newValue.isEmpty else { return }
            // передаем в completion то, что внес пользователь
            completion(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        // добавляем действия в контроллер
        addAction(saveAction)
        addAction(cancelAction)
        // добавляем текстовое поле
        addTextField { textField in
            textField.placeholder = "Task"
            textField.text = task?.title
        }
    }
}


