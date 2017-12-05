//
//  SearchCell.swift
//  YVFourSquareTrendingVenues
//
//  Created by Yash Vyas on 05/12/17.
//  Copyright © 2017 Yash Vyas. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var address: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
