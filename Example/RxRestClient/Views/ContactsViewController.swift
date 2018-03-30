//
//  ContactsViewController.swift
//  RxRestClient_Example
//
//  Created by Tigran Hambardzumyan on 3/27/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage

class ContactsViewController: UIViewController {

    private let disposeBag = DisposeBag()

    private var viewModel: ContactsViewModel!

    @IBOutlet weak var tableView: UITableView!

    private let refresh = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = ContactsViewModel(refresh: refresh.asDriver(onErrorJustReturn: ()), service: ContactsService())

        doDriving()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh.onNext(())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func doDriving() {
        viewModel.contactsState
            .map { $0.contacts }
            .drive(tableView.rx.items(cellIdentifier: "cell")) { _, element, cell in
                cell.textLabel?.text = [element.firstName, element.lastName].joined(separator: " ")
                cell.detailTextLabel?.text = element.email
                cell.imageView?.contentMode = .scaleAspectFit
                if let imageURL = element.imageURL {
                    cell.imageView?.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "contacts"), options: [
                        SDWebImageOptions.retryFailed,
                        SDWebImageOptions.refreshCached
                    ])
                }
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(Contact.self)
            .subscribe(onNext: { [weak self] contact in
                self?.navigateToEdit(contact: contact)
            })
            .disposed(by: disposeBag)
    }

    private func navigateToEdit(contact: Contact) {
        self.performSegue(withIdentifier: "toEditSegue", sender: contact)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toEditSegue"?:
            let vc = segue.destination as? NewContactViewController
            vc?.contact = sender as? Contact
        default:
            break
        }
    }
}
