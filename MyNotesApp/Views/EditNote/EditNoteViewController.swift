//
//  EditNoteViewController.swift
//  MyNotesApp
//
//  Created by Алексей Павленко on 01.09.2022.
//

import UIKit

class EditNoteViewController: UIViewController {
    static let identifier = "EditNoteViewController"

    //MARK: - Outlets
    @IBOutlet weak var textView: UITextView!
    
    //MARK: - Variables
    var note: Note!
    private var originalText: String?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.text = note.text
        originalText = note.text
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        handleChanges()
    }
    
    //MARK: - Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func handleChanges() {
        guard let text = textView.text, !text.isEmpty else {
            deleteNote()
            return
        }
        
        if originalText != text {
            updateNote()
        }
    }
    
    private func updateNote() {
        note.text = textView.text
        note.lastUpdated = Date()
        CoreDataManager.shared.save()
    }
    
    private func deleteNote() {
        CoreDataManager.shared.delete(note)
    }
    
}

