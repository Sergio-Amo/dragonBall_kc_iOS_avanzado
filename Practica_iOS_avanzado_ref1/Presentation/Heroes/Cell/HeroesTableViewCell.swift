//
//  HeroesTableViewCell.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 28/10/23.
//

import UIKit
import Kingfisher

class HeroesTableViewCell: UITableViewCell {
    
    static let identifier = "HeroesTableViewCell"

    @IBOutlet weak var tittleOutlet: UILabel!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var descriptionOutlet: UILabel!
    @IBOutlet weak var containerOutlet: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerOutlet.layer.cornerRadius = 4.0
    }
    
    override func prepareForReuse() {
        //Resets all data containing outlets to nil
        self.updateViews(data: nil)
    }
    
    func updateViews(data: Hero?) {
        update(title: data?.name)
        update(description: data?.description)
        update(photo: data?.photo)
    }
    private func update(title: String? = nil) {
        tittleOutlet.text = title
    }
    private func update(description: String? = nil) {
        descriptionOutlet.text = description
    }
    private func update(photo: URL? = nil) {
        guard let photo else { return }
        imageOutlet.kf.setImage(with: photo)
    }
}
