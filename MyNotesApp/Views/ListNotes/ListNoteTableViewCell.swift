//
//  ListNoteTableViewCell.swift
//  MyNotesApp
//
//  Created by Алексей Павленко on 01.09.2022.
//

import UIKit

class ListNoteTableViewCell: UITableViewCell {
    static let identifier = "ListNoteTableViewCell"
 
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func setup(with note: Note) {
        titleLabel.text = note.title
        descriptionLabel.text = note.desc
    }
    
}
