//
//  BlockerCellModel.swift
//  NoFeed
//
//  Created by Vova Seuruk on 8/27/18.
//  Copyright © 2018 Vova Seuruk. All rights reserved.
//

import UIKit

protocol BlockerCellDataProvider: BlockerCellDataDescriptor, BlockerIdentifierable { }

protocol BlockerCellDataDescriptor {
    
    var title: String { get }
    var imageName: String { get }
    var brandingColor: UIColor? { get }
    
}

class BlockerCellModel: BlockerCellDataProvider {
    
    let title: String
    let imageName: String
    let brandingColor: UIColor?
    
    init(with title: String, imageName: String, brandingColor: UIColor? = nil) {
        self.title = title
        self.imageName = imageName
        self.brandingColor = brandingColor
    }
}

extension BlockerCellModel: BlockerIdentifierable {
    
    var blockerIdentifier: String {
        return title
    }
    
}
