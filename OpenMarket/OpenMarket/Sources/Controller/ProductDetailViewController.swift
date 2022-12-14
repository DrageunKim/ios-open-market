//
//  OpenMarket - ProductDetailViewController.swift
//  Created by Zhilly. 22/12/14
//  Copyright © yagom. All rights reserved.
//

import UIKit

class ProductDetailViewController: UIViewController {
    var currentIndex: CGFloat = 0
    let productID: Int
    var product: Product?
    var imageURLArray: [URL?] = []
    let flowLayout = UICollectionViewFlowLayout()
    
    @IBOutlet weak var productImageCollectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
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
        configureCollectionView()
        configureFlowLayout()
        
        fetchProduct()
    }
    
    private func configureFlowLayout() {
        let cellHeight: CGFloat = UIScreen.main.bounds.height / 10 * 3.5
        let cellWidth: CGFloat = cellHeight
        
        let insetX = (productImageCollectionView.bounds.width - cellWidth) / 2.0
        let insetY = (productImageCollectionView.bounds.height - cellHeight) / 2.0
        
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        flowLayout.scrollDirection = .horizontal
        
        productImageCollectionView.collectionViewLayout = flowLayout
        productImageCollectionView.decelerationRate = .fast
        productImageCollectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        productImageCollectionView.isPagingEnabled = false
    }
    
    private func configureCollectionView() {
        productImageCollectionView.delegate = self
        productImageCollectionView.dataSource = self
        registerCellNib()
    }
    
    private func registerCellNib() {
        let collectionViewCellNib = UINib(nibName: ImageCollectionViewCell.stringIdentifier(),
                                          bundle: nil)
        
        productImageCollectionView.register(collectionViewCellNib,
                                            forCellWithReuseIdentifier: ImageCollectionViewCell.stringIdentifier())
    }
    
    private func configureUIComponent() {
        guard let product = product else { return }
        
        titleLabel.text = product.name
        stockLabel.text = "남은수량 : \(product.stock)"
        priceLabel.text = "\(product.currency.rawValue) \(product.price)"
        descriptionTextView.text = product.description
        
        guard let detailImages = product.images else { return }
        
        detailImages.forEach {
            if let imageURL: URL = URL(string: $0.url) {
                imageURLArray.append(imageURL)
            }
        }
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

extension ProductDetailViewController {
    private func fetchProduct() {
        let session: URLSessionProtocol = URLSession.shared
        let networkManager: NetworkRequestable = NetworkManager(session: session)
        
        networkManager.request(from: URLManager.product(id: productID).url,
                               httpMethod: HttpMethod.get,
                               dataType: Product.self) { result in
            switch result {
            case .success(let data):
                self.product = data
                
                DispatchQueue.main.async {
                    self.configureUIComponent()
                    self.productImageCollectionView.reloadData()
                }
                
            case .failure(_):
                let alert = UIAlertController(title: "실패", message: "상품 정보를 가져오지 못했습니다.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                    self.dismiss(animated: true)
                }
                
                alert.addAction(okAction)
                self.present(alert, animated: true)
            }
        }
    }
}

extension ProductDetailViewController: UICollectionViewDelegate {
    
}

extension ProductDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return product?.images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = productImageCollectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCollectionViewCell.stringIdentifier(),
            for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configureImage(url: imageURLArray[indexPath.item])
        
        return cell
    }
}

extension ProductDetailViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = self.productImageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        var roundedIndex = round(index)
        
        if scrollView.contentOffset.x > targetContentOffset.pointee.x {
            roundedIndex = floor(index)
        } else {
            roundedIndex = ceil(index)
        }
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
}
