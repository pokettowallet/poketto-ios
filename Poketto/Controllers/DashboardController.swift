//
//  DashboardController.swift
//  Poketto
//
//  Created by André Sousa on 17/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import SwiftyJSON
import Presentr
import MagicalRecord
import Contacts


class DashboardController: UIViewController {
    
    @IBOutlet var collectionView    : UICollectionView!
    private let refreshControl      = UIRefreshControl()
    var transactions                : Array<Any> = []
    let reuseIdentifier             = "transactionCellId"
    var headerID                    = "dashboardHeaderId"
    var balance                     : Float!
    var contactStore                = CNContactStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavDivider()
    
        collectionView.refreshControl = self.refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIScreen.main.bounds.size.width < 375 {
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                let itemWidth = 375*UIScreen.main.bounds.size.width/375
                let itemHeight = layout.itemSize.height
                layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
                layout.invalidateLayout()
            }
        }
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }
    
    func addNavDivider() {
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        let dividerView = UIView(frame: CGRect(x: 15, y: (navigationController?.navigationBar.frame.size.height)!-2, width: (navigationController?.navigationBar.frame.size.width)!-30, height: 2))
        dividerView.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1)
        navigationController?.navigationBar.addSubview(dividerView)
    }
    
    func fetchData() {
        
        let wallet = Wallet.init()
        //        wallet.importSeed(seed: "barely setup matter drive exchange agree fatal sunny interest adjust horror hip season captain dilemma upgrade debris bullet renew hurt citizen scatter famous season")
        let explorer = Explorer.init()
        explorer.balanceFrom(address: wallet.getEthereumAddress()!.address, completion: { balance in
            print("balance \(balance)")
            self.balance = balance
            self.collectionView.reloadData()
        })
        
        print("wallet address \(wallet.getEthereumAddress()!.address)")
        explorer.transactionsFrom(address: wallet.getEthereumAddress()!.address, completion: { transactions in
            print("transactions \(transactions)")
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.transactions = transactions
                self.collectionView.reloadData()
            }
        })
    }
    
    @objc func refreshData(_ sender: Any) {
        fetchData()
    }
    
    @IBAction func pay() {
        
        let paymentContactsNavVC = storyboard?.instantiateViewController(withIdentifier: "paymentContactsNavVC") as! UINavigationController
        navigationController?.present(paymentContactsNavVC, animated: true, completion: nil)
    }
    
    @IBAction func settings() {
        
        let presenter: Presentr = {
            let width = ModalSize.sideMargin(value: 14)
            let height = ModalSize.custom(size: 570)
            let window = UIApplication.shared.keyWindow
            var padding : CGFloat = 0
            if window?.safeAreaInsets.bottom == 0 {
                padding = 50
            }
            let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 14, y: (122-padding)*(UIScreen.main.bounds.size.height/812)-padding))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = .coverVertical
            customPresenter.dismissTransitionType = .coverVerticalFromTop
            customPresenter.roundCorners = true
            customPresenter.cornerRadius = 25
            customPresenter.backgroundColor = .black
            customPresenter.backgroundOpacity = 0.5
            customPresenter.dismissOnSwipe = false
            customPresenter.dismissOnSwipeDirection = .top
            return customPresenter
        }()
        let controller = storyboard?.instantiateViewController(withIdentifier: "settingsNavVC") as! UINavigationController
        customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
    }
    
    @IBAction func request() {
        
        let presenter: Presentr = {
            let width = ModalSize.sideMargin(value: 14)
            let height = ModalSize.custom(size: 536)
            let window = UIApplication.shared.keyWindow
            var padding : CGFloat = 0
            if window?.safeAreaInsets.bottom == 0 {
                padding = 40
            }
            let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 14, y: (145-padding)*(UIScreen.main.bounds.size.height/812)-padding))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = .coverVertical
            customPresenter.dismissTransitionType = .coverVerticalFromTop
            customPresenter.roundCorners = true
            customPresenter.cornerRadius = 25
            customPresenter.backgroundColor = .black
            customPresenter.backgroundOpacity = 0.5
            customPresenter.dismissOnSwipe = false
            customPresenter.dismissOnSwipeDirection = .top
            return customPresenter
        }()
        let navController = storyboard?.instantiateViewController(withIdentifier: "requestNavVC") as! UINavigationController
        let wallet = Wallet.init()
        let controller = navController.viewControllers[0] as! RequestController
        controller.address = wallet.getEthereumAddress()?.address
        customPresentViewController(presenter, viewController: navController, animated: true, completion: nil)
    }
}

extension DashboardController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var sectionHeader = DashboardHeaderView()
        
        sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.headerID, for: indexPath) as! DashboardHeaderView
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            if(balance != nil) {
                sectionHeader.balanceLabel.text = "\(balance!) xDai"
            }
            
            return sectionHeader
        }
        return UICollectionReusableView()

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TransactionCell
        
        let transaction = transactions[indexPath.row] as! JSON
        
        let address = transaction["to"].stringValue.uppercased()
        
        if let contact = PKContact.mr_findFirst(byAttribute: "address", withValue: address) {
            
            cell.addressLabel.text = contact.name
            
            do {
                let phoneContact = try contactStore.unifiedContact(withIdentifier: contact.contact_id!, keysToFetch: [CNContactThumbnailImageDataKey as CNKeyDescriptor])
                if let avatar = phoneContact.thumbnailImageData {
                    DispatchQueue.main.async {
                        cell.contactImageView.image = UIImage(data: avatar)
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.contactImageView.image = UIImage(named: "contact-placeholder")
                    }
                }
            } catch {
                print("Error fetching results for container")
                DispatchQueue.main.async {
                    cell.contactImageView.image = UIImage(named: "contact-placeholder")
                }
            }
            
        } else {
            cell.addressLabel.text = "Unknown \(transaction["to"])"
            DispatchQueue.main.async {
                cell.contactImageView.image = UIImage(named: "unknown-address")
            }
        }
        
        if let amount = transaction["value"].string {
            let wei = Float(amount)!
            let dai : Float = wei / 1000000000000000000.0
            cell.amountLabel.text = String(format: "%.2f", dai)
        }
        
        cell.contactImageView.layer.cornerRadius = 20
        
        return cell
    }
}

extension DashboardController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
}
