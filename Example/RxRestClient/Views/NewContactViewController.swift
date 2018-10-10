//
//  NewContactViewController.swift
//  RxRestClient_Example
//
//  Created by Tigran Hambardzumyan on 3/27/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NewContactViewController: UIViewController {

    // MARK: - Dependencies
    private let disposeBag = DisposeBag()
    var contact: Contact?

    // MARK: - View Model
    private var viewModel: NewContactViewModel!

    // MARK: - Outlets
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var selectImageBtn: UIButton!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveBtn: UIBarButtonItem!

    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        initViewModel()

        doBindings()
        doDrivings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func initViewModel() {
        viewModel = NewContactViewModel(
            oldContact: contact,
            service: ContactsService()
        )
    }

    private func doBindings() {

        twoWayBind(viewModel.firstName, firstName.rx.text)
            .disposed(by: disposeBag)

        twoWayBind(viewModel.lastName, lastName.rx.text)
            .disposed(by: disposeBag)

        twoWayBind(viewModel.email, email.rx.text)
            .disposed(by: disposeBag)

        saveBtn.rx.tap
            .bind(to: viewModel.saveCommand)
            .disposed(by: disposeBag)
    }

    private func twoWayBind<Base>(_ variable: Variable<Base>, _ property: ControlProperty<Base>) -> Disposable {
        let d1 = property
            .skip(1)
            .bind(to: variable)

        let d2 = variable
            .asObservable()
            .bind(to: property)

        return Disposables.create(d1, d2)
    }

    private func doDrivings() {

        viewModel.image
            .asObservable()
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)

        Driver.merge(
            viewModel.createState,
            viewModel.updateState
            )
            .map { $0.success }
            .filter { $0 ?? false }
            .drive(onNext: { [navigationController] _ in
                navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        Driver.merge(
            viewModel.createState,
            viewModel.updateState
            )
            .map { $0.state?.badRequest }
            .filterNil()
            .drive(onNext: { [weak self] _ in
                let alert = UIAlertController(title: "Error", message: "Bad Request", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(defaultAction)

                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.imageUploadState
            .map { $0.tooLarge }
            .filterNil()
            .filter { $0 }
            .drive(onNext: { [weak self] _ in
                let alert = UIAlertController(title: "Error", message: "Image is too Large", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(defaultAction)

                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)

        selectImageBtn.rx.tap
            .subscribe { [weak self] _ in
                self?.presentImagePicker()
            }
            .disposed(by: disposeBag)

        viewModel.isValid
            .drive(saveBtn.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    private func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false

        self.present(imagePicker, animated: true, completion: nil)
    }
}

extension NewContactViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            viewModel.image.value = pickedImage
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
