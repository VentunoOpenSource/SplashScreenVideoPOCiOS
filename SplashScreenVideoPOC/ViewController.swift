//
//  ViewController.swift
//  SplashScreenVideoPOC
//
//  Created by Ventuno Technologies on 18/03/20.
//  Copyright © 2020 Ventuno Technologies. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    private var mPlayerView = PlayerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let url = URL(string: "")
        
        if(!isLocalSplashVideoAvailable()){
            downloadAsset()
        }
        
        let splashVideoPath = getSplashScreenAsset(url!)
        createPlayer(splashVideoPath)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: mPlayerView.player?.currentItem, queue: .main) { [weak self] _ in
            self?.mPlayerView.player?.seek(to: CMTime.zero)
            self?.mPlayerView.player?.play()
        }
    }
    
    
}

extension ViewController{
    private func createPlayer(_ path:URL){
        
        
        
        
        mPlayerView.player = AVPlayer(url: path)
        //mPlayerView.playerLayer = AVPlayerLayer(player: mPlayerView.player)
        mPlayerView.playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(mPlayerView.playerLayer)
        mPlayerView.player?.play()
    }
    
    private func getSplashScreenAsset(_ cloudUrl:URL) -> URL{
        
        guard let localAssetPath = UserDefaults.standard.url(forKey: "splash_screen_video") else{return cloudUrl}
        
        if(FileManager.default.fileExists(atPath: localAssetPath.path)){
            print("Local asset found")
            return localAssetPath
        }
        
        return cloudUrl
       
    }
    
    private func isLocalSplashVideoAvailable() -> Bool{
        
        guard let localAssetPath = UserDefaults.standard.url(forKey: "splash_screen_video") else{return false}
        
        if(FileManager.default.fileExists(atPath: localAssetPath.path)){
            return true
        }
        return false
        
    }
    
}

extension ViewController{
    
    private func downloadAsset(){
        
        guard let documentsURL = self.getDocumentDirUrl() else{return}
        
        guard let url = URL(string: "") else {return}
        
        print("Downloading...")
        
        URLSession.shared.downloadTask(with: url) { (location, response, error) -> Void in
            
            guard let location = location else {return}
           
            print("Location \(String(describing: location))")
           
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode
            if(statusCode != 200){
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.downloadAsset()
                    return
                }
            }
            
            
            let destinationURL = documentsURL.appendingPathComponent( url.lastPathComponent )
            
            do{
                try FileManager.default.moveItem(at: location, to: destinationURL)
                print("File moved to: ",destinationURL.absoluteString)
                UserDefaults.standard.set(destinationURL, forKey: "splash_screen_video")
            }catch {
                print ("file error: \(error)")
            }
            
            if let error = error {
                print( "DataTask error: " , error.localizedDescription )
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.downloadAsset()
                }
            }
            
        }.resume()
    }
    
    private func getDocumentDirUrl() -> URL?{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}

class PlayerView: UIView {
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

