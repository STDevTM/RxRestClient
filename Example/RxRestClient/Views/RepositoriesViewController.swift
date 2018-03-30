//
//  RepositoriesViewController.swift
//  RxRestClient
//
//  Created by Tigran Hambardzumyan on 03/02/2018.
//  Copyright (c) 2018 Tigran Hambardzumyan. All rights reserved.
//

import UIKit
import RxRestClient
import RxSwift
import RxCocoa
import RxOptional

class RepositoriesViewController: UIViewController {

    private let disposeBag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var viewModel: RepositoriesViewModel!

    private var errorText = PublishSubject<String?>()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = RepositoriesViewModel(search: searchBar.rx.text.orEmpty, service: RepositoriesService())

        doDriving()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func doDriving() {
        viewModel.repositoriesState
            .map { $0.data ?? [] }
            .drive(tableView.rx.items(cellIdentifier: "cell")) { _, element, cell in
                cell.textLabel?.text = element.name
                cell.detailTextLabel?.text = element.description
            }
            .disposed(by: disposeBag)

        viewModel.repositoriesState
            .map { $0.state?.validationProblem }
            .filterNil()
            .map { _ in "Please enter any search query" }
            .drive(errorText)
            .disposed(by: disposeBag)

        viewModel.repositoriesState
            .map { $0.state?.forbidden }
            .filterNil()
            .map { _ in "You have exceed API limit" }
            .drive(errorText)
            .disposed(by: disposeBag)

        viewModel.repositoriesState
            .map { $0.data }
            .filterNil()
            .filter { $0.isEmpty }
            .map { _ in "Unable to find repo with this search query" }
            .drive(errorText)
            .disposed(by: disposeBag)

        viewModel.repositoriesState
            .map { $0.data?.isNotEmpty ?? false }
            .filter { $0 }
            .map { _ in nil }
            .drive(errorText)
            .disposed(by: disposeBag)

        errorText
            .subscribe(onNext: { [tableView] msg in
                guard let msg = msg else {
                    tableView?.backgroundView = nil
                    return
                }
                let errorLbl = UILabel()
                errorLbl.textAlignment = .center
                errorLbl.text = msg
                tableView?.backgroundView = errorLbl
            })
            .disposed(by: disposeBag)
    }

}
