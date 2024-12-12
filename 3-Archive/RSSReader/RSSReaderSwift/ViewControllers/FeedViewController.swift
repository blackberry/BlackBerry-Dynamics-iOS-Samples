/* Copyright (c) 2023 BlackBerry Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import UIKit

private func FeedDownloader() -> FeedDownloadBase {
    return FeedDownloadNSUrl()
}

class SWFeedViewController : UITableViewController, XMLParserDelegate, FeedDownloadBaseDelegateProtocol {
    
    var rssFeed : RSSFeed?
    var spinner : UIActivityIndicatorView?
    
    fileprivate(set) var currentURL : String?
    
    // variables to store xml parsing elements
    fileprivate var parser: XMLParser?
    fileprivate var element: String?
    fileprivate var itemDict: [String : String]?
    // variable to store xml parsing elements
    fileprivate var storyArray : [[String : String]] = [[String : String]]()
    
    // extracted elements for each story in a feed
    fileprivate var itemTitle : String?
    fileprivate var itemDescription : String?
    fileprivate var itemDate : String?
    fileprivate var itemLink : String?
    
    fileprivate var feedDownloader : FeedDownloadBase = FeedDownloader()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = self.rssFeed?.rssName
        
        self.currentURL = self.rssFeed?.rssUrl.absoluteString
        
        //See if the feed request type changes whilst stories are showing
        //Although not used in the is example - is good to know
        NotificationCenter.default.addObserver(self,
			selector:#selector(SWFeedViewController.feedModeChanged(_:)),
            name: NSNotification.Name(rawValue: kRSSRequestModeChangedNotification),
            object: nil)
        
        self.feedDownloader.delegate = self
        
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {  self.refresh(nil) })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = UIAccessibilityIdentifiers.SRSSFeedViewID
    }
    
    /*
    * This method reloads the feed file and redisplays the data
    */
    @IBAction func refresh(_ sender: UIBarButtonItem?) {
        self.startSpinner()
        reachabilityStateOutputInfo()
        
        storyArray = [[String : String]]()
        self.tableView.reloadData()
        if (self.currentURL != nil) {
            parseDataFromSite(currentURL!)
        }
    }
    
    /*
    * This method cancels the load by calling abort
    */
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.stopSpinner()
        self.feedDownloader.abortRequest()
    }
    
    // MARK: - FeedDownloadBaseDelegateProtocol
    
    func downloadDone(_ data: Data?) {
        DispatchQueue.main.async {
            self.stopSpinner()
        }
        guard let unwrappedData = data else {
            return
        }
        if (unwrappedData.count > 0) {
            parser = XMLParser(data: unwrappedData)
            parser?.delegate = self
            parser?.parse()
        }
    }
    
    func alert(_ alert: UIAlertController) {
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    @objc fileprivate func feedModeChanged(_ notification: Notification) {
        
    }
    
    /*
    * This method requests the feed file from the supplied URL
    */
    fileprivate func parseDataFromSite(_ url: String) {
        DispatchQueue.main.async { () -> Void in
            self.feedDownloader.requestData(url)
            
        }
        
    }
    
    // MARK: - NSXMLParser delegate
    
    /*
    * called when the parser starts an element
    */
    func parser(_ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String]) {
        
            element = elementName
            
            if element == "item" {
                itemDict = [String : String]()
                itemTitle = ""
                itemDescription = ""
                itemDate = ""
                itemLink = ""
            }
    }
    
    /*
    * called when the parser completes an element
    */
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            self.itemDict!["title"] = self.itemTitle
            self.itemDict!["description"] = self.itemDescription
            self.itemDict!["pubDate"] = self.itemDate
            self.itemDict!["link"] = self.itemLink
            self.storyArray.append(self.itemDict!)
        }
    }
    
    /*
    * called when the parser finds a tag
    */
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if (element == "title") {
            itemTitle? += string
        } else if ( element == "link" ) {
            itemLink? += string
        } else if ( element == "description" ) {
            itemDescription? += string
        } else if ( element == "pubDate" ) {
            itemDate? += string
        }
    }
    
    /*
    * called when the parser completes
    */
    func parserDidEndDocument(_ parser: XMLParser) {
        DispatchQueue.main.async(execute: {
            self.tableView!.reloadData()
        })
    }
    
    /*
    * handle any parser error by showing an error dialog
    */
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        if Thread.isMainThread {
            let error = parseError as NSError
            let dialogAlert = UIAlertController(title: "Error Parsing File",
                message: error.description,
                preferredStyle: .alert)
            dialogAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(dialogAlert, animated: true, completion: nil)
        } else {
            DispatchQueue.main.async {
                self.parser(parser, parseErrorOccurred: parseError)
            }
        }
    }
    
    // MARK: - Table view data source and delegate implementation
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storyArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let desc = self.storyArray[indexPath.row]["description"]!.trimmingCharacters(in: CharacterSet.whitespaces)
        
        var maxSize = CGSize(width: 0, height:CGFloat.greatestFiniteMagnitude)
        maxSize.width = screenAccordingToOrientation()
        
        maxSize.height = (desc.heightWithConstrainedWidth(maxSize.width, font:UIFont(name: "Helvetica", size:12)!))
        
        return maxSize.height + 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storyTableViewCell")
        
        cell?.textLabel?.text = self.storyArray[indexPath.row]["title"]
        cell?.detailTextLabel?.text = self.storyArray[indexPath.row]["description"]!.trimmingCharacters(in: CharacterSet.whitespaces)
        
        return cell!
    }
    
    func startSpinner() {
        self.spinner = UIActivityIndicatorView(style: .large)
        self.spinner?.color = .darkGray
        self.spinner?.center = self.view.center
        self.view.addSubview(self.spinner!)
        self.spinner?.startAnimating()
    }
    
    func stopSpinner() {
        if (self.spinner != nil) {
            self.spinner?.stopAnimating()
            self.spinner?.removeFromSuperview()
        }
    }
}
