//
//  ListTabView.swift
//  OpenMarket
//
//  Created by 최지혁 on 2022/11/29.
//

import UIKit

class BaseView: UIView {
    override init(frame:CGRect) {
          super.init(frame:frame)
          self.prepareView()
    }

    required init?(coder:NSCoder) {
         super.init(coder:coder)
         prepareView()
    }

    func prepareView() {

    }
}

class ListTabView: BaseView{
    @IBOutlet weak var listCollectionView: UICollectionView!
    private var product: ProductList?
    private let cellIdentifier: String = String(describing: ListCollectionViewCell.self)
    
    override func prepareView() {
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        
        listCollectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
}

extension ListTabView: UICollectionViewDelegate {
    
}

extension ListTabView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ListCollectionViewCell =
        collectionView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell",
                                           for: indexPath) as! ListCollectionViewCell
        guard let productItem = product?.pages[indexPath.item] else {
            return cell
        }
        
        cell.configurationCell(item: productItem)
        cell.addBottomLine(color: .gray, width: 0.5)
        
        return cell
    }
}
