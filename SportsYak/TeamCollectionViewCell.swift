//
//  TeamCollectionViewCell.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/24/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit

class TeamCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var teamImageView: UIImageView!
    
    func configureWithTeam(team: PFTeam) {
        self.teamImageView.backgroundColor = UIColor(hexString: team.colorMainHex).colorWithAlphaComponent(0.7)
        self.teamImageView.layer.cornerRadius = self.teamImageView.frame.size.width/2.0
        self.teamImageView.layer.masksToBounds = true
        if let teamType = TeamType(rawValue: team.teamType) {
            teamImageView.image = UIImage(named: teamType.imageIdentifier)            
        }
    }
    
}
