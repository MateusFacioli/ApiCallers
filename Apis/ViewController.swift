//
//  ViewController.swift
//  Apis
//
//  Created by Mateus Rodrigues on 13/07/22.
//

import UIKit

//models

struct User: Codable {
    let name: String
    let email: String
}
struct ToDoList: Codable {
    let title: String
    let completed: Bool
}

class ViewController: UIViewController {
   
    private let table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models: [Codable] = []
    private let kind = (user: User.self, list: ToDoList.self)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        fetchItems()
        
//        let service = Service()
//        service.makePostRequest()
//        service.get(cep: "13098315", callback: { result in
//
//            DispatchQueue.main.async {
//                switch result {
//                case let .success(data):
//                    print(data)
//                    break
//                case let .failure(error):
//                    print(error)
//                    break
//                }
//            }
//        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    fileprivate func fetchData(_ url: URL?) {//, expecting: (User, ToDoList)) {
        
        guard let url = url else {
            return
        }
    
        URLSession.shared.request(url: url, expecting: [User].self) { [weak self] result in
            switch result {
            case.success(let users):
                DispatchQueue.main.async {
                    self?.models = users
                    self?.table.reloadData()
                }
                print("SUCCESS ON CALL API... \(url) with results: \(result)")
            case.failure(let error):
                print("FAILURE ON CALL API... \(url) -> \(error)")
            }
        }
    }
    
    func fetchUser() {
        fetchData(Constants.usersUrl)
    }
    
    func fetchItems() {
        fetchData(Constants.todoUrl)
    }
   
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = (models[indexPath.row] as? ToDoList)?.title
        if let item = models[indexPath.row] as? ToDoList {
            cell.accessoryType =  item.completed ? .checkmark : .none//.detailDisclosureButton
        }
        else {
            cell.textLabel?.text = (models[indexPath.row] as? User)?.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
}

