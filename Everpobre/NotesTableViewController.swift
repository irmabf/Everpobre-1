//
//  NotesTableViewController.swift
//  Everpobre
//
//  Created by Joaquin Perez on 12/03/2018.
//  Copyright © 2018 Joaquin Perez. All rights reserved.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController {
    
    var noteList:[Note] = []
    
    var observer : NSObjectProtocol?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        
        
        // Fetch Request.
        let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
        
    
//        // 1.- Creamos el objeto
//        let fetchRequest =  NSFetchRequest<Note>()
//
//        // 2.- Que entidad es de la que queremos objeto.
//        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Note", in: viewMOC)
        
        let fetchRequest = Note.fetchNoteRequest()
        
   //     let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        
 

        
        // 3.- (Opcional) Indicamos orden.
        let sortByDate = NSSortDescriptor(key: "createdAtTI", ascending: true)
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortByDate,sortByTitle]
        
        // 4.- (Opcional) Filtrado.
        let created24H = Date().timeIntervalSince1970 - 24 * 3600
        let predicate = NSPredicate(format: "createdAtTI >= %f", created24H)
        fetchRequest.predicate = predicate
        
        
        
        // 5.- Ejecutamos la request.
        try! noteList = viewMOC.fetch(fetchRequest)
        
        
        observer = NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextDidSave, object: nil, queue: OperationQueue.main, using: { (notification) in
    
             self.tableView.reloadData()
        })
        
    }

    deinit {
        if let obs = observer
        {
        NotificationCenter.default.removeObserver(obs)
        }
    }


    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return noteList.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        }

        cell?.textLabel?.text = noteList[indexPath.row].title

        return cell!
    }
  

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let noteViewController = NoteViewByCodeController()
        noteViewController.note = noteList[indexPath.row]
        navigationController?.pushViewController(noteViewController, animated: true)
    }
    
    @objc func addNewNote()  {
        
        
        // Tradicionalmente.
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: DataManager.sharedManager.persistentContainer.viewContext) as! Note
        
        note.title = "Nueva nota"
        note.createdAtTI = Date().timeIntervalSince1970
        
        try! DataManager.sharedManager.persistentContainer.viewContext.save()
        
        noteList.append(note)
        
        tableView.reloadData()
        
    }

}
