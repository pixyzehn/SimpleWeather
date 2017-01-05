//
//  WeatherViewController.swift
//  SimpleWeather
//
//  Created by Ryan Nystrom on 11/13/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

import UIKit
import IGListKit
import CoreLocation

class WeatherViewController: UIViewController, IGListAdapterDataSource, LocationTrackerDelegate {

    @IBOutlet weak var collectionView: IGListCollectionView!
    @IBOutlet weak var alertsButton: UIButton!

    lazy var pulser: ViewPulser = {
        return ViewPulser(view: self.alertsButton)
    }()

    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()

    var tracker: LocationTracker?
    var task: URLSessionDataTask?

    let stateMachine = WeatherStateMachine()

    var location: SavedLocation?
    var forecast: Forecast?

    deinit {
        task?.cancel()
    }

    // MARK: Private API

    func updateAlertButton() {
        if WeatherNavigationShouldDisplayAlerts(forecast: forecast) {
            pulser.enable()
        } else {
            pulser.disable()
        }
    }

    func fetch() {
        guard let location = location else { return }

        if location.userLocation == true {
            fetchCurrentLocation()
        } else {
            fetch(lat: location.latitude, lon: location.longitude)
        }
    }

    func fetchCurrentLocation() {
        tracker = LocationTracker()
        tracker?.delegate = self
        tracker?.getLocation()
    }

    func fetch(lat: Double, lon: Double) {
        guard let url = WundergroundForecastURL(apiKey: API_KEY, lat: lat, lon: lon),
            task?.originalRequest?.url != url || task?.state != .running
            else { return }

        let request = URLSessionDataTaskResponse(serializeJSON: true) { (json: Any) -> Forecast? in
            guard let json = json as? [String: Any] else { return nil }
            return Forecast.fromJSON(json: json)
        }

        task?.cancel()
        task = URLSession.shared.fetch(url: url, request: request) { [weak self] (result: URLSessionResult) in
            guard let location = self?.location else { return }

            switch result {
            case let .success(forecast):
                self?.stateMachine.state = .forecast(forecast)
                self?.forecast = forecast
                self?.title = WeatherNavigationTitle(location: location, forecast: forecast)
                self?.adapter.performUpdates(animated: true)
                self?.updateAlertButton()
            case .failure(_): break
            }
        }
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        fetch()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(WeatherViewController.applicationWillEnterForeground(notification:)),
            name: .UIApplicationWillEnterForeground,
            object: nil
        )

        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAlertButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pulser.disable()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let alertsVC = segue.destination as? AlertsViewController {
            alertsVC.alerts = forecast?.alerts
        }
    }

    // MARK: IGListAdapterDataSource

    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return stateMachine.objects
    }

    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        return stateMachine.sectionController(object: object)
    }

    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        return nil
    }

    // MARK: Notifications

    func applicationWillEnterForeground(notification: Notification) {
        let expiration: TimeInterval = 60 * 20 // 20 minutes
        if let observationDate = forecast?.observation?.date, -1 * observationDate.timeIntervalSinceNow >= expiration {
            fetchCurrentLocation()
        }
    }

    // MARK: LocationTrackerDelegate

    func didFinish(tracker: LocationTracker, result: LocationResult) {
        switch result {
        case let .success(location):
            fetch(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        default:
            print("Error tracking location")
        }
    }

}
