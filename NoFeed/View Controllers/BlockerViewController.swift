//
//  BlockerViewController.swift
//  NoFeed
//
//  Created by Vova Seuruk on 8/27/18.
//  Copyright © 2018 Vova Seuruk. All rights reserved.
//

import UIKit

class BlockerViewController: UIViewController {
    
    fileprivate let blockerCellReuseIdentifier = "blockerCell"
    fileprivate let actionCellReuseIdentifier = "actionCell"
    fileprivate let headerReuseIdentifier = "blockerHeader"
    
    fileprivate let dataSource: BlockerDataProvider
    private let containerManager: ContainerManagerProtocol = ContainerManager()
    private var currentPopupView: PopupView?
    
    fileprivate struct Constants {
        static let sideInset: CGFloat = 20.0
        static let padding: CGFloat = 18.0
        static let feedCellRatio: CGFloat = 1.125
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).viewForAutoLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: Constants.sideInset, bottom: 0.0, right: Constants.sideInset)
        collectionView.register(FeedBlockerCell.self, forCellWithReuseIdentifier: blockerCellReuseIdentifier)
        collectionView.register(ActionCell.self, forCellWithReuseIdentifier: actionCellReuseIdentifier)
        collectionView.register(BlockerReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        return collectionView
    }()
    
    init(with dataSource: BlockerDataProvider) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        title = "No Feed"
        
        view.addSubview(collectionView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(collectionView.constraintsWithAnchorsEqual(to: view))
    }
    
    fileprivate func setBlockerStateIfNeeded(for cell: BlockerCell) {
        
        guard let blockerCell = cell as? FeedBlockerCell,
            let identifier = blockerCell.dataSource?.identifier,
            let blockerIdenrifier = containerManager.blockerIndetifier(for: identifier) else {
                return
        }
        let modelExists = containerManager.modelExists(with: blockerIdenrifier)
        
        blockerCell.setBlockerIsOn(modelExists)
    }

    // MARK: cell selected actions
    
    fileprivate func selectBlocker(with cell: FeedBlockerCell) {
        cell.selected()
        
        guard let id = cell.dataSource?.identifier, let blockerIdenrifier = containerManager.blockerIndetifier(for: id) else { return }
        
        if cell.isBlockerOn {
            containerManager.addModel(with: blockerIdenrifier)
        } else {
            containerManager.removeModel(with: blockerIdenrifier)
        }
    }
    
    fileprivate func presentBuyPremiumView() {
        guard let navigationView = navigationController?.view else { return }
        
        let popupView = PopupView(with: .buyPremium, purchaseBlock: {
            // purchase logic
        }, restoreBlock: {
            // restore purchase logic
            }).viewForAutoLayout()
        currentPopupView = popupView
        
        navigationController?.view.addSubview(popupView)
        NSLayoutConstraint.activate(popupView.constraintsWithAnchorsEqual(to: navigationView))
        
        UIView.animate(withDuration: 0.3) {
            popupView.isVisible = true
        }
    }
    
    private func presentLimitationsView() {
        guard let navigationView = navigationController?.view else { return }
        
        let popupView = PopupView(becomePremiumCompletion: nil).viewForAutoLayout()
        currentPopupView = popupView
        
        navigationController?.view.addSubview(popupView)
        NSLayoutConstraint.activate(popupView.constraintsWithAnchorsEqual(to: navigationView))
        
        UIView.animate(withDuration: 0.3) {
            popupView.isVisible = true
        }
    }
    
    private func hidePopup() {
        currentPopupView?.isVisible = false
        currentPopupView?.removeFromSuperview()
        currentPopupView = nil
    }
}

extension BlockerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems(at: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = indexPath.section == 0 ? blockerCellReuseIdentifier : actionCellReuseIdentifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        guard let blockerCell = cell as? BlockerCell else { return cell }
        
        blockerCell.dataSource = dataSource.model(at: indexPath)
        setBlockerStateIfNeeded(for: blockerCell)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier, for: indexPath)
        guard let blockerHeader = headerView as? BlockerReusableView else { return headerView }
        
        blockerHeader.title = dataSource.titleForSupplementaryView(at: indexPath)
        return blockerHeader
    }
}

extension BlockerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGSize
        
        if indexPath.section == 0 {
            let width = (collectionView.bounds.width - (2 * Constants.sideInset + Constants.padding)) / 2
            let height = width * Constants.feedCellRatio
            size = CGSize(width: width, height: height)
        } else {
            let width = (collectionView.bounds.width - (2 * Constants.sideInset + Constants.padding)) / 2
            let height = width / 1.5
            size = CGSize(width: width, height: height)
        }
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.padding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width - (2 * Constants.sideInset), height: 50.0)
    }
}

extension BlockerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let blockerCell = collectionView.cellForItem(at: indexPath) as? FeedBlockerCell {
            selectBlocker(with: blockerCell)
        } else if isBuyPremiumCell(at: indexPath) {
            presentBuyPremiumView()
        }
    }
    
    private func isBuyPremiumCell(at indexPath: IndexPath) -> Bool {
        return indexPath.row == 1 ? true : false
    }
    
}
