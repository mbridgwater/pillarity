//
//  AcaiaScaleTableVC.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/12/25.
//

import UIKit
import CoreBluetooth      // ⬅️ add this
import AcaiaSDK

class AcaiaScaleTableVC: UITableViewController, CBCentralManagerDelegate {

    private var central: CBCentralManager!
    private var pendingScanSeconds: Double?
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        _setRefreshControl()
//        _addAcaiaEventsObserver()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        AcaiaManager.shared().startScan(0.5)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        central = CBCentralManager(delegate: self, queue: .main)   // ⬅️ start monitoring BT state
        _setRefreshControl()
        _addAcaiaEventsObserver()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestScan(12.0)   // ⬅️ 0.5s is often too short; use 6–10s while testing
    }
    
    // Gate the scan until BT is ready
    private func requestScan(_ seconds: Double) {
        switch central.state {
        case .poweredOn:
            // small delay gives AcaiaSDK’s own central time to reach poweredOn too
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                AcaiaManager.shared().startScan(seconds)
            }
        default:
            pendingScanSeconds = seconds
            // will fire when centralManagerDidUpdateState becomes .poweredOn
        }
    }

    // CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn, let s = pendingScanSeconds {
            pendingScanSeconds = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                AcaiaManager.shared().startScan(s)
            }
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        _activityIndicatorView.stopAnimating()
        
        _timerForConnectTimeOut?.invalidate()
        _timerForConnectTimeOut = nil
        
        _removeScaleEventObservers()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AcaiaManager.shared().scaleList.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScaleCell", for: indexPath)

        let scale = AcaiaManager.shared().scaleList[indexPath.row]

        cell.textLabel?.text = scale.name
        cell.detailTextLabel?.text = scale.modelName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _activityIndicatorView.isHidden = false
        _activityIndicatorView.startAnimating()
        
        let scale = AcaiaManager.shared().scaleList[indexPath.row]
        scale.connect()
        
        _timerForConnectTimeOut = Timer.scheduledTimer(timeInterval: 10.0,
                                                       target: self,
                                                       selector: #selector(_connectTimeOut(_:)),
                                                       userInfo: nil,
                                                       repeats: false)
    }
    
    
    // MARK: Private
    
    private var _timerForConnectTimeOut: Timer? = nil
    
    lazy private var _activityIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.isHidden = true
        
        view.addSubview(indicator)
        indicator.center = view.center
        
        return indicator
    }()
    
    private func _setRefreshControl() {
        tableView.refreshControl = .init()
        tableView.refreshControl?.attributedTitle = .init(string: "Scanning")
        tableView.refreshControl?.addAction(
//            UIAction { _ in AcaiaManager.shared().startScan(0.5 },
            UIAction { _ in self.requestScan(12.0) },
            for: .valueChanged
        )
    }
    
    private func _addAcaiaEventsObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(_didConnected),
                                               name: .init(rawValue: AcaiaScaleDidConnected),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(_didFinishScan),
                                               name: .init(rawValue: AcaiaScaleDidFinishScan),
                                               object: nil)
    }
    
    private func _removeScaleEventObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func _didConnected(notification: NSNotification) {
        _activityIndicatorView.stopAnimating()
        
        _timerForConnectTimeOut?.invalidate()
        _timerForConnectTimeOut = nil
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func _didFinishScan(notification: NSNotification) {
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    @objc private func _connectTimeOut(_ timer: Timer) {
        _activityIndicatorView.stopAnimating()
        
        _timerForConnectTimeOut?.invalidate()
        _timerForConnectTimeOut = nil
        
        AcaiaManager.shared().startScan(0.1)
        
        let alert = UIAlertController(title: nil,
                                      message: "Connect timeout",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        
        present(alert, animated: true)
    }
}
