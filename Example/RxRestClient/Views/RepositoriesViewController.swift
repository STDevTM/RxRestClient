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

        viewModel = RepositoriesViewModel(service: RepositoriesService())

        doBindings()
    }

    func doBindings() {
        // Inputs
        searchBar.rx.text.orEmpty.changed
            .bind(to: viewModel.search)
            .disposed(by: disposeBag)

        tableView.rx.contentOffset
            .flatMap { [unowned self] state in
                return self.tableView.isNearBottomEdge(edgeOffset: 20.0)
                    ? Signal.just(())
                    : Signal.empty()
            }
            .bind(to: viewModel.loadMore)
            .disposed(by: disposeBag)

        // Outputs
        viewModel.repositories
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) { _, element, cell in
                cell.textLabel?.text = element.name
                cell.detailTextLabel?.text = element.description
            }
            .disposed(by: disposeBag)

        viewModel.baseState
            .map { $0.validationProblem }
            .filterNil()
            .map { _ in "Please enter any search query" }
            .bind(to: errorText)
            .disposed(by: disposeBag)

        viewModel.baseState
            .map { $0.forbidden }
            .filterNil()
            .map { _ in "You have exceed API limit" }
            .bind(to: errorText)
            .disposed(by: disposeBag)

        viewModel.repositories
            .withLatestFrom(viewModel.baseState) { $0.isEmpty && $1.isSuccess }
            .filter { $0 }
            .map { _ in "Unable to find repo with this search query" }
            .bind(to: errorText)
            .disposed(by: disposeBag)

        viewModel.repositories
            .filter { $0.isNotEmpty }
            .map { _ in nil }
            .bind(to: errorText)
            .disposed(by: disposeBag)

        errorText
            .observeOn(MainScheduler.instance)
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
