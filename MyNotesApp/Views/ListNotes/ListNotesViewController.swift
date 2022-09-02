//
//  ListNotesViewController.swift
//  MyNotesApp
//
//  Created by Алексей Павленко on 01.09.2022.
//

import UIKit
import CoreData

class ListNotesViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak var notesCountLabel: UILabel!
    
    //MARK: - Properties
    private let searchController = UISearchController()
    private var fetchedResultController: NSFetchedResultsController<Note>!
    private var allNotesCount: Int = 0 {
        didSet {
            notesCountLabel.text = "\(allNotesCount) \(allNotesCount == 1 ? "Note" : "Notes")"
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFetchedResultController()
        configureNavigationController()
        configureTableView()
        configureSearchBar()
    }
    
    //MARK: - Actions
    
    @IBAction func createNewNoteButtonTapped(_ sender: UIButton) {
        goToEditNote(createNote())
    }
    
    //MARK: - Methods
    private func configureFetchedResultController(filer: String? = nil) {
        fetchedResultController = CoreDataManager.shared.fetchedResultsController(filter: filer)
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("Failed to init fetchedResultsController. \(error.localizedDescription)")
        }
    }
    
    private func configureNavigationController() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.backBarButtonItem?.tintColor = .red
    }
    
    private func configureTableView() {
        tableView.contentInset = .init(top: 10, left: 0, bottom: 30, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func configureSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchBar.tintColor = .red
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.delegate = self
    }
    
    private func goToEditNote(_ note: Note) {
        guard let editNoteController = storyboard?.instantiateViewController(withIdentifier: EditNoteViewController.identifier) as? EditNoteViewController else { return }
        editNoteController.note = note
        navigationController?.pushViewController(editNoteController, animated: true)
    }
    
    private func createNote() -> Note {
        let note = CoreDataManager.shared.createNote()
        return note
    }
    
    private func deleteFromStorage(note: Note) {
        CoreDataManager.shared.delete(note)
    }
}
//MARK: - NSFetchedResultsController Helpers
extension ListNotesViewController {
    private var sections: [NSFetchedResultsSectionInfo] {
        return fetchedResultController.sections ?? []
    }
    
    private func note(for indexPath: IndexPath) -> Note {
        fetchedResultController.object(at: indexPath)
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension ListNotesViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .move, .update:
            break
        @unknown default: fatalError("Unknown type \(type) detected.")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        @unknown default: fatalError("Unknown type \(type) detected.")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        allNotesCount = controller.fetchedObjects?.count ?? 0
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension ListNotesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allNotesCount = sections[section].numberOfObjects
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListNoteTableViewCell.identifier) as! ListNoteTableViewCell
        cell.setup(with: note(for: indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteFromStorage(note: note(for: indexPath))
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToEditNote(note(for: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

//MARK: - UISearchBarDelegate, UISearchControllerDelegate
extension ListNotesViewController: UISearchBarDelegate, UISearchControllerDelegate {
    func search(_ query: String?) {
        if let query = query, query.count >= 1 {
            configureFetchedResultController(filer: query)
        } else {
            configureFetchedResultController()
        }
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search(nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        search(query)
    }
}
