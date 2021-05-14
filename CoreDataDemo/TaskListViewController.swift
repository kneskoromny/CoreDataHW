//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 10.05.2021.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    // MARK: - Private properties
    private let cellID = "cell"
    
    private var taskList: [Task] = []
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        // загружаем данные из базы для обновления контроллера
        fetchData()
    }
    
    // MARK: - Private methods
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert()
    }
    

    // обновляем данные из базы, получаем массив
    private func fetchData() {
        StorageManager.shared.fetchData { result in
            switch result {
            // передаем базу в массив контроллера
            case .success(let tasks):
                self.taskList = tasks
            case .failure(let error):
                print(error)
            }
        }
    }
    // метод создает новую задачу по имени и возвращает захваченное значение
    private func save(taskName: String) {
        StorageManager.shared.save(taskName) { task in
            // добавляет задачу в массив контроллера
            self.taskList.append(task)
            // создаем индекс для новой строки
            let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
            // добавляем строку по индексу
            tableView.insertRows(at: [cellIndex], with: .automatic)
        }
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    // MARK: - UITableViewDelegate
    // удаляем задачу
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // получаем элемент массива по индексу и определяем задачу для удаления из базы
        let task = taskList[indexPath.row]
        
        if editingStyle == .delete {
            //удаляем из массива в контроллере
            taskList.remove(at: indexPath.row)
            // удаляем строку с задачей
            tableView.deleteRows(at: [indexPath], with: .automatic)
            // удаляем из базы данных
            StorageManager.shared.delete(task)
            
        }
    }
    // редактируем задачу
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // снимает выделение с ячейки
        tableView.deselectRow(at: indexPath, animated: true)
        // получаем элемент массива по индексу
        let task = taskList[indexPath.row]
        // вызываем кастомный алертконтроллер и в completion добавляем действие для обновления интерфейса
        showAlert(task: task) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
    }
}
// MARK: - AlertController
extension TaskListViewController {
    
    // инициализаторы с параметрами по умолчанию нужны для использования одного алерта в разных ситуациях, а completion позволит добавить действие после вызова
    private func showAlert(task: Task? = nil, completion: (() -> Void)? = nil) {
        // если инициализатор не пустой, то хотим редактировать задачу, иначе - новая задача, заголовок для контроллера
        let title = task != nil ? "Update Task" : "New Task"
        
        //создаем экземпляр контроллера
        let alert = AlertController(
            title: title,
            message: "What do you want?",
            preferredStyle: .alert
        )
        // в completion возвращается то, что внес пользователь и передаем его или в edit или в save
        alert.action(task: task) { taskName in
            // если параметры заполнены, то редактируем
            if let task = task, let completion = completion {
                // вызываем метод для редактирования
                StorageManager.shared.edit(task, newName: taskName)
                // пустой completion для дальнейшего обновления нтерфейса
                completion()
            } else {
                // если параметров в инициализаторе нет, то добавляем новую задачу
                self.save(taskName: taskName)
            }
        }
        present(alert, animated: true)
        
    }
}



