//
//  ViewController.swift
//  MyFund
//
//  Created by Jason Fan on 14/11/2017.
//  Copyright © 2017 QooApp. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit
import Whisper

class ViewController: UIViewController, UISearchBarDelegate {

    var fund: FundModel?
    var searchBar: UISearchBar?
    var historyArray: [String]?
    var historyList: UITableView?
    var currentFundCode: String = "163407"
    
    var codeLabel: UILabel?     //基金代码
    var nameLabel: UILabel?     //基金名称
    var jzDateLabel: UILabel?   //净值日期
    var dwjzLabel: UILabel?     //单位净值
    var gszLabel: UILabel?      //估算值
    var gszzfLabel: UILabel?    //估算值涨幅
    var gszDateLabel: UILabel?  //估算值日期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "我的基金"
        self.navigationItem.rightBarButtonItem = setupRightBar()
        let screenWidth = UIScreen.main.bounds.size.width
        searchBar = UISearchBar(frame: CGRect(x: 20, y: 64, width: screenWidth - 40, height: 40))
        searchBar?.searchBarStyle = .minimal
        searchBar?.delegate = self
        self.view.addSubview(searchBar!)
    }
    
    func setupRightBar() -> UIBarButtonItem {
        let refreshBtn = UIButton(type: .custom)
        refreshBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        refreshBtn.setTitle("刷新", for: .normal)
        refreshBtn.setTitleColor(UIColor.black, for: .normal)
        refreshBtn.addTarget(self, action: #selector(refreshBtnOnClick), for: .touchUpInside)
        
        return UIBarButtonItem(customView: refreshBtn)
    }
    
    func setupSubViews() {
        nameLabel?.removeFromSuperview()
        codeLabel?.removeFromSuperview()
        dwjzLabel?.removeFromSuperview()
        jzDateLabel?.removeFromSuperview()
        gszLabel?.removeFromSuperview()
        gszzfLabel?.removeFromSuperview()
        gszDateLabel?.removeFromSuperview()

        guard let dwjz = fund?.dwjz, let gsz = fund?.gsz else {
            return
        }
        let dwjzFV = (dwjz as NSString).floatValue
        let gszFV = (gsz as NSString).floatValue
        let redColor = colorWithRGB(red: 254, green: 4, blue: 2)
        let greenColor = colorWithRGB(red: 2, green: 154, blue: 2)
        let gzColor: UIColor = dwjzFV > gszFV ? greenColor : redColor
        
        nameLabel = UILabel()
        nameLabel?.text = fund?.name
        nameLabel?.font = UIFont.systemFont(ofSize: 24)
        self.view.addSubview(nameLabel!)
        
        codeLabel = UILabel()
        codeLabel?.text = fund?.fundcode
        codeLabel?.font = UIFont.systemFont(ofSize: 14)
        self.view.addSubview(codeLabel!)
        
        dwjzLabel = UILabel()
        let dwjzStr = "单位净值: \(fund?.dwjz ?? "0.0")"
        let dwjzLength = dwjz.lengthOfBytes(using: String.Encoding.utf8)
        let range = getNumRange(from: dwjzStr, numLength: dwjzLength)
        let dwjzAttrStr = NSMutableAttributedString(string: dwjzStr)
        dwjzAttrStr.addAttributes([NSAttributedStringKey.foregroundColor : redColor], range: range)
        dwjzLabel?.font = UIFont.systemFont(ofSize: 24)
        dwjzLabel?.attributedText = dwjzAttrStr
        self.view.addSubview(dwjzLabel!)
        
        jzDateLabel = UILabel()
        jzDateLabel?.text = "(\(fund?.jzrq ?? ""))"
        jzDateLabel?.font = UIFont.systemFont(ofSize: 16)
        self.view.addSubview(jzDateLabel!)
        
        gszLabel = UILabel()
        let gszStr = "盘中估值: \(fund?.gsz ?? "0.0")"
        let gszLength = gsz.lengthOfBytes(using: String.Encoding.utf8)
        let gszrange = getNumRange(from: gszStr, numLength: gszLength)
        let gszAttrStr = NSMutableAttributedString(string: gszStr)
        gszAttrStr.addAttributes([NSAttributedStringKey.foregroundColor : gzColor], range: gszrange)
        gszLabel?.font = UIFont.systemFont(ofSize: 24)
        gszLabel?.attributedText = gszAttrStr
        self.view.addSubview(gszLabel!)
        
        gszzfLabel = UILabel()
        gszzfLabel?.text = "\(fund?.gszzl ?? "0")%"
        gszzfLabel?.textColor = gzColor
        gszzfLabel?.font = UIFont.systemFont(ofSize: 24)
        self.view.addSubview(gszzfLabel!)
        
        gszDateLabel = UILabel()
        gszDateLabel?.text = "估值日期: (\(fund?.gztime ?? ""))"
        gszDateLabel?.font = UIFont.systemFont(ofSize: 16)
        self.view.addSubview(gszDateLabel!)
        
        setupUI()
    }
    
    func setupUI() {
        nameLabel?.snp.makeConstraints({ (make) in
            make.top.equalTo(114)
            make.centerX.equalTo(self.view.snp.centerX)
        })
        
        codeLabel?.snp.makeConstraints({ (make) in
            make.top.equalTo((nameLabel?.snp.bottom)!).offset(10)
            make.centerX.equalTo(self.view.snp.centerX)
        })
        
        dwjzLabel?.snp.makeConstraints({ (make) in
            make.top.equalTo((codeLabel?.snp.bottom)!).offset(30)
            make.left.equalTo(20)
        })
        
        jzDateLabel?.snp.makeConstraints({ (make) in
            make.left.equalTo((dwjzLabel?.snp.right)!).offset(5)
            make.centerY.equalTo((dwjzLabel?.snp.centerY)!)
        })
        
        gszLabel?.snp.makeConstraints({ (make) in
            make.top.equalTo((dwjzLabel?.snp.bottom)!).offset(10)
            make.left.equalTo(20)
        })
        
        gszzfLabel?.snp.makeConstraints({ (make) in
            make.left.equalTo((gszLabel?.snp.right)!).offset(15)
            make.centerY.equalTo((gszLabel?.snp.centerY)!)
        })
        
        gszDateLabel?.snp.makeConstraints({ (make) in
            make.top.equalTo((gszLabel?.snp.bottom)!).offset(10)
            make.left.equalTo(20)
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//Events
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    @objc func refreshBtnOnClick() {
        fetchServerData(fundCode: self.currentFundCode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view != searchBar {
            searchBar?.resignFirstResponder()
            if historyList != nil { historyList?.removeFromSuperview() }
        }
    }
    
    @objc func fetchServerData(fundCode: String) {
        let requestUrl = "http://fundgz.1234567.com.cn/js/\(fundCode).js"
        Alamofire.request(requestUrl).responseJSON { response in
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
                let headStr = "jsonpgz("
                let footStr = ");"
                let finalStr = utf8Text.components(separatedBy: headStr).last?.components(separatedBy: footStr).first
                if let fund = FundModel(JSONString: finalStr!) {
                    let message = Message(title: "刷新成功", backgroundColor: .black)
                    Whisper.show(whisper: message, to: self.navigationController!, action: .show)
                    self.fund = fund
                    self.setupSubViews()
                    
                    if let history = UserDefaults.standard.array(forKey: "History") {
                        var temp = history as! Array<String>
                        if !temp.contains(fundCode) {
                            temp.append(fundCode)
                            UserDefaults.standard.set(temp, forKey: "History")
                            UserDefaults.standard.synchronize()
                        }
                    } else {
                        var history = [String]()
                        history.append(fundCode)
                        UserDefaults.standard.set(history, forKey: "History")
                        UserDefaults.standard.synchronize()
                        
                    }
                }
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let history = UserDefaults.standard.array(forKey: "History") {
            self.historyArray = history as? Array<String>
            historyList = UITableView(frame: CGRect(x: 30, y: 104, width: UIScreen.main.bounds.size.width - 60, height: 100))
            historyList?.delegate = self
            historyList?.dataSource = self
            historyList?.tableFooterView = UIView()
            historyList?.register(UITableViewCell.self, forCellReuseIdentifier: "historyCell")
            self.view.addSubview(historyList!)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let fundCode = searchBar.text, fundCode != "" {
            searchBar.resignFirstResponder()
            if historyList != nil { historyList?.removeFromSuperview() }
            self.currentFundCode = fundCode
            fetchServerData(fundCode: fundCode)
        }
    }
    
    //MARK: - table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.historyArray?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let historyCode = self.historyArray![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell")
        cell?.backgroundColor = colorWithRGB(red: 242, green: 242, blue: 242)
        cell?.selectionStyle = .none
        cell?.layer.cornerRadius = 20.0
        cell?.layer.masksToBounds = true
        cell?.textLabel?.text = historyCode
        return cell!
    }
    
    //MARK: - table view delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let historyCode = self.historyArray![indexPath.row]
        searchBar?.text = historyCode
        searchBarSearchButtonClicked(searchBar!)
        historyList?.removeFromSuperview()
    }
}

//tools
extension ViewController {
    func colorWithRGB(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    func getNumRange(from reviewStr: String, numLength: Int) -> NSRange {
        var location: Int = 0
        for (i,char) in reviewStr.enumerated() {
            let s = String(char)
            if let _ = Int(s) {
                location = i
                break
            }
        }
        return NSRange(location: location, length: numLength)
    }
}



