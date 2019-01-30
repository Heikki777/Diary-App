//
//  JournalEntryCell.swift
//  Diary App
//
//  Created by Heikki Hämälistö on 19/10/2017.
//  Copyright © 2017 Heikki Hämälistö. All rights reserved.
//

import UIKit

class JournalEntryCell: UITableViewCell {

    @IBOutlet weak var entryDateLabel: UILabel!
    @IBOutlet weak var entryImageView: UIImageView!
    @IBOutlet weak var entryTextLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayRatingView: DayRatingView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureCell()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }
    
    func configureCell(){
        self.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 83)
        if let entryImageView = self.entryImageView{
            entryImageView.layer.cornerRadius = 34
            entryImageView.clipsToBounds = true
            entryImageView.contentMode = .scaleAspectFill
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
