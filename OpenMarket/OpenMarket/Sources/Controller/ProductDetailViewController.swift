//
//  OpenMarket - ProductDetailViewController.swift
//  Created by Zhilly. 22/12/14
//  Copyright © yagom. All rights reserved.
//

import UIKit

class ProductDetailViewController: UIViewController {
    
    let productID: Int
    @IBOutlet weak var productImageCollectionView: UICollectionView!
    
    init(nibName: String, productID: Int) {
        self.productID = productID
        super.init(nibName: nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavigationBar()
    }
    
    private func addNavigationBar() {
        var statusBarHeight: CGFloat = 0
        statusBarHeight = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        
        let navigationBar = UINavigationBar(frame: .init(x: 0,
                                                         y: statusBarHeight,
                                                         width: view.frame.width,
                                                         height: statusBarHeight))
        navigationBar.isTranslucent = false
        navigationBar.backgroundColor = .systemBackground

        let productAction = UINavigationItem(title: "")
        productAction.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                                          style: .plain,
                                                          target: self,
                                                          action: #selector(didTapDismissButton))
        productAction.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                           target: self,
                                                           action: #selector(didTapDoneButton))
        
        navigationBar.items = [productAction]
        view.addSubview(navigationBar)
    }
    
    @objc
    func didTapDoneButton() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "수정", style: .default)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @objc
    func didTapDismissButton() {
        self.dismiss(animated: true)
    }
}
