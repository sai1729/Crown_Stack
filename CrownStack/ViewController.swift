//
//  ViewController.swift
//  CrownStack
//
//  Created by Dondeti, Sai Krishna on 20/07/21.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = songsView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! MyTableViewCell
        cell.artistName.text = albums[indexPath.row].artistName
        cell.songName.text = albums[indexPath.row].songName
        cell.songTime.text = albums[indexPath.row].songTime
        
        let url = URL(string: albums[indexPath.row].imageUrl)!

          // Create Data Task
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                DispatchQueue.main.async {
                    cell.imageView?.image = UIImage(data: data)
                }
            }
        }
          dataTask.resume()
        return cell
    }
    
    @IBOutlet weak var songsView: UITableView!
    private var albums = [musicAlbum]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Songs"
        loadDataValues()
        songsView.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier:"cellIdentifier")
        self.songsView.reloadData()
    }
    
    struct musicAlbum {
        var songName: String = ""
        var artistName: String = ""
        var songTime: String = ""
        var imageUrl: String = ""
    }
    
//    https://itunes.apple.com/search?term=Michael+jackson
    
    func loadDataValues() {
        
        guard let itunesUrl = URL(string: "https://itunes.apple.com/search?term=Michael+jackson") else {
            return
        }
     
        let request = URLRequest(url: itunesUrl)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
     
            if let error = error {
                print(error)
                return
            }
     
            // Parse JSON data
            if let data = data {
                self.albums = self.parseJsonData(data: data)
     
                // Reload table view
                OperationQueue.main.addOperation({
                    self.songsView.reloadData()
                })
            }
        })
     
        task.resume()
    }
        
    
     
    func parseJsonData(data: Data) -> [musicAlbum] {
     
        var albums = [musicAlbum]()
     
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
     
            // Parse JSON data
            let jsonMusic = jsonResult?["results"] as! [AnyObject]
            for jsonmusic in jsonMusic {
                var music = musicAlbum()
                music.artistName = jsonmusic["artistName"] as! String
                music.imageUrl = jsonmusic["artworkUrl100"] as! String
                music.songName = jsonmusic["collectionName"] as? String ?? "Anonymous"
                music.songTime = jsonmusic["trackTimeMillis"] as? String ?? "3.48"
                albums.append(music)
            }
     
        } catch {
            print(error)
        }
     
        return albums
    }
}


