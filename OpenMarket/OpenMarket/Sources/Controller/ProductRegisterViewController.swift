//
//  OpenMarket - ProductRegisterViewController.swift
//  Created by Zhilly, Dragon. 22/12/02
//  Copyright © yagom. All rights reserved.
//

import UIKit

final class ProductRegisterViewController: UIViewController {
    private var imageArray: [UIImage] = []
    private let imagePicker: UIImagePickerController = .init()
    private var imageIndex: Int = 0
    private var keyHeight: CGFloat = 0
    @IBOutlet private weak var mainView: ProductRegisterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.delegate = self
        
        configureCollectionView()
        configureImagePicker()
        configureTextComponent()
        checkKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imageArray.removeAll()
        imageArray.append(UIImage(named: "PlusImage") ?? UIImage())
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
    }
    
    private func postProduct() {
        let session: URLSessionProtocol = URLSession.shared
        let networkManager: NetworkPostable = NetworkManager(session: session)
        
        guard let name = mainView.productNameTextField.text,
              let description = mainView.productsContentTextView.text,
              let priceString = mainView.productPriceTextField.text,
              let price = Double(priceString) else { return }
        let currency = mainView.currencySelector.selectedSegmentIndex == 0 ? Currency.KRWString : Currency.USDString
        
        var param: ParamsProduct = .init(name: name,
                                         description: description,
                                         price: price,
                                         currency: currency,
                                         secret: "rzeyxdwzmjynnj3f")
        
        if let bargainPriceString = mainView.productBargainTextField.text,
           let bargainPrice = Double(bargainPriceString),
           let stockString = mainView.productStockTextField.text,
           let stock = Int(stockString) {
            param.discountedPrice = bargainPrice
            param.stock = stock
        }
        
        imageArray.removeLast()
        networkManager.post(to: URLManager.post.url, param: param, imageArray: imageArray)
    }
    
    private func checkKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func checkRequirements() throws {
        if imageArray.count < 2 {
            throw ProductPostRequirementError.imageError
        }
        
        if let nameLength = mainView.productNameTextField.text?.count, nameLength < 3 {
            throw ProductPostRequirementError.productNameError
        }
        
        if mainView.productPriceTextField.hasText == false {
            throw ProductPostRequirementError.priceError
        }
        
        if let bargainPrice = mainView.productBargainTextField.text,
           let originPrice = mainView.productPriceTextField.text,
           bargainPrice > originPrice {
            throw ProductPostRequirementError.bargainPriceError
        }
        
        if mainView.productsContentTextView.text.count < 10 ||
            mainView.productsContentTextView.textColor == .lightGray {
            throw ProductPostRequirementError.descriptionError
        }
    }
    
    private func configureTextComponent() {
        mainView.productsContentTextView.delegate = self
        mainView.productsContentTextView.text = "상품 설명을 입력해주세요.(1000글자 제한)"
        mainView.productsContentTextView.textColor = .lightGray
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textFieldDidChange(_:)),
                                               name: UITextField.textDidChangeNotification,
                                               object: nil)
    }
    
    private func configureCollectionView() {
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        
        registerCellNib()
    }
    
    private func registerCellNib() {
        let collectionViewCellNib = UINib(nibName: ImageCollectionViewCell.stringIdentifier(),
                                          bundle: nil)
        
        mainView.collectionView.register(collectionViewCellNib,
                                         forCellWithReuseIdentifier: ImageCollectionViewCell.stringIdentifier())
    }
    
    private func configureImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        imageArray.append(UIImage(named: "PlusImage") ?? UIImage())
    }
    
    @objc
    private func keyboardWillShow(_ sender: Notification) {
        guard let senderUserInfo = sender.userInfo else { return }
        let userInfo: NSDictionary = senderUserInfo as NSDictionary
        
        if let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            var keyboardHeight = keyboardRectangle.height
            
            if keyHeight == 0 {
                keyHeight = keyboardHeight
                view.frame.size.height -= keyboardHeight
            } else if keyHeight > keyboardHeight {
                keyboardHeight = keyboardHeight - keyHeight
                keyHeight = keyHeight + keyboardHeight
                view.frame.size.height -= keyboardHeight
            }
        }
    }
    
    @objc
    private func keyboardWillHide(_ sender: Notification) {
        view.frame.size.height += keyHeight
        keyHeight = 0
    }
    
    @objc
    private func textFieldDidChange(_ notification: Notification) {
        if let textField = notification.object as? UITextField {
            switch textField {
            case mainView.productNameTextField:
                if mainView.productNameTextField.text?.count ?? 0 > 100 {
                    mainView.productNameTextField.deleteBackward()
                }
            default:
                return
            }
        }
    }
}

extension ProductRegisterViewController: ProductDelegate {
    func tappedDismissButton() {
        self.dismiss(animated: true)
    }
    
    func tappedDoneButton() {
        do {
            try checkRequirements()
            postProduct()
            let alert: UIAlertController = UIAlertController(title: "상품등록 완료",
                                                             message: nil,
                                                             preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: "확인", style: .default) { _ in
                self.dismiss(animated: true)
            }
            
            alert.addAction(okAction)
            present(alert, animated: true)
        } catch {
            var errorMessage: String = .init()
            
            switch error {
            case ProductPostRequirementError.imageError:
                errorMessage = "이미지는 최소 1장, 최대 5장입니다."
            case ProductPostRequirementError.productNameError:
                errorMessage = "상품이름은 최소 3자, 최대 100자 입니다."
            case ProductPostRequirementError.priceError:
                errorMessage = "상품가격은 필수 입력입니다."
            case ProductPostRequirementError.descriptionError:
                errorMessage = "상품설명은 최소 10자, 최대 1000자 입니다."
            case ProductPostRequirementError.bargainPriceError:
                errorMessage = "할인가격은 상품가격을 넘을 수 없습니다."
            default :
                errorMessage = "\(error.localizedDescription)"
            }
            
            let alert: UIAlertController = UIAlertController(title: "상품등록 정보를 확인해주세요",
                                                             message: errorMessage,
                                                             preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: "확인", style: .default)
            
            alert.addAction(okAction)
            present(alert, animated: true)
        }
    }
}

extension ProductRegisterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}

extension ProductRegisterViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if imageArray.count - 1 != indexPath.item && imageArray.count < 7 {
            let alert = UIAlertController(title: "이미지 편집",
                                          message: nil,
                                          preferredStyle: .actionSheet)
            let edit = UIAlertAction(title: "수정", style: .default) { _ in
                self.imageIndex = indexPath.item
                self.imageArray.remove(at: indexPath.item)
                self.present(self.imagePicker, animated: true)
            }
            let delete = UIAlertAction(title: "삭제", style: .destructive) { _ in
                self.imageArray.remove(at: indexPath.item)
                self.mainView.collectionView.reloadData()
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            
            alert.addAction(edit)
            alert.addAction(delete)
            alert.addAction(cancel)
            present(alert, animated: true)
        } else {
            if imageArray.count < 6 {
                self.imageIndex = imageArray.count - 1
                present(imagePicker, animated: true)
            } else {
                let alert = UIAlertController(title: "안내",
                                              message: "사진 추가는 최대 5장입니다.",
                                              preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default)
                
                alert.addAction(action)
                present(alert, animated: true)
            }
        }
    }
}

extension ProductRegisterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCollectionViewCell.stringIdentifier(),
            for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configureImage(imageFile: imageArray[indexPath.item])
        
        return cell
    }
}

extension ProductRegisterViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard var image = info[.editedImage] as? UIImage else { return }
        
        let isSquare = image.size.width == image.size.height
        
        if isSquare == false {
            if let squareImage = cropSquare(image) {
                image = squareImage
            }
        }
        
        image = image.resize(newWidth: 100)
        imageArray.insert(image, at: imageIndex)
        mainView.collectionView.reloadData()
        mainView.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                             at: .left,
                                             animated: false)
        dismiss(animated: true)
    }
    
    private func cropSquare(_ image: UIImage) -> UIImage? {
        let imageSize = image.size
        let shortLength = imageSize.width < imageSize.height ? imageSize.width : imageSize.height
        let origin = CGPoint(
            x: imageSize.width / 2 - shortLength / 2,
            y: imageSize.height / 2 - shortLength / 2
        )
        let size = CGSize(width: shortLength, height: shortLength)
        let square = CGRect(origin: origin, size: size)
        guard let squareImage = image.cgImage?.cropping(to: square) else {
            return nil
        }
        return UIImage(cgImage: squareImage)
    }
}

extension ProductRegisterViewController: UINavigationControllerDelegate {}

extension ProductRegisterViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if mainView.productsContentTextView.hasText == false {
            mainView.productsContentTextView.text = "상품 설명을 입력해주세요.(1000글자 제한)"
            mainView.productsContentTextView.textColor = .lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if mainView.productsContentTextView.textColor == .lightGray {
            mainView.productsContentTextView.text = nil
            mainView.productsContentTextView.textColor = .black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = mainView.productsContentTextView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return changedText.count <= 1000
    }
}
