//
//  TootViewController.swift
//  Demo
//
//  Created by sword on 2017/5/26.
//  Copyright © 2017年 Sword. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    let demoList = ["banner循环滚动", "wave波动"]
    lazy var tableView:UITableView = {
        var result = UITableView(frame: self.view.bounds, style: UITableViewStyle.plain)
        
        result.dataSource = self
        result.delegate = self
        
        return result
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension RootViewController:UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        struct cell {
            static let identifier = "cell"
        }
        var result = tableView.dequeueReusableCell(withIdentifier: cell.identifier)

        if nil == result {
            result = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cell.identifier)
        }
        result!.textLabel?.text = demoList[indexPath.row]
        
        return result!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var nextVC:UIViewController?
        switch indexPath.row {
        case 0:
            nextVC = BannerCircularlyVC()
        case 1:
            nextVC = WaveViewController()
        default:
            break
        }
        if let vc = nextVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
