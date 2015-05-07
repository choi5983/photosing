//
//  ViewController.swift
//  AVFoundationStarter
//
//  Created by Jae Hoon Lee on 5/4/15.
//  Copyright (c) 2015 Jae Hoon Lee. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class PictureViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var imagePicker: UIImagePickerController!
    var moviePlayer : MPMoviePlayerController!
    var songIndex = 0
    var songs = [Int]()
    let videosAvailable = 8
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet var playSong: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func takePhoto(sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoHasEnded:", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
        playSong.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        playSong.hidden = true
    }
    
    @IBAction func playSongTouched(sender: UIButton) {
        playVideo("\(songs[0])")
        songIndex=0
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        //initilize the song
        songs.removeAll(keepCapacity: true)
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        playSong.hidden=false
        
        var color = getPixelColor(imageView.image!, pos: CGPoint(x: 2, y: 2))
        songs.append(Int(color[0])%videosAvailable)
        songs.append(Int(color[1])%videosAvailable)
        songs.append(Int(color[2])%videosAvailable)
        color = getPixelColor(imageView.image!, pos: CGPoint(x: 20, y: 20))
        songs.append(Int(color[0])%videosAvailable)
        songs.append(Int(color[1])%videosAvailable)
        songs.append(Int(color[2])%videosAvailable)
        color = getPixelColor(imageView.image!, pos: CGPoint(x: 40, y: 40))
        songs.append(Int(color[0])%videosAvailable)
        songs.append(Int(color[1])%videosAvailable)
        songs.append(Int(color[2])%videosAvailable)
    }
    
    func getPixelColor(image: UIImage, pos: CGPoint) -> [CGFloat] {
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage))
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var pixelInfo: Int = ((Int(image.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        var r = CGFloat(data[pixelInfo])
        var g = CGFloat(data[pixelInfo+1])
        var b = CGFloat(data[pixelInfo+2])
        var a = CGFloat(data[pixelInfo+3])
        
        return [r,g,b,a]
    }
    
    func createSong(){
        
    }
    
    func playVideo(letter: String) {
        let path = NSBundle.mainBundle().pathForResource(letter, ofType:"mp4")
        
        if path == nil {
            print("could not find \(letter).mp4")
        } else {
            let url = NSURL.fileURLWithPath(path!)
            if url == nil {
                print("could not find the file \(letter)>.mp4")
                return
            }
            self.moviePlayer = MPMoviePlayerController(contentURL: url)
            if let player = self.moviePlayer {
                
                let frame = videoView.frame
                
                player.view.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
//                player.view.sizeToFit()
                player.scalingMode = MPMovieScalingMode.None
                player.fullscreen = false
                player.controlStyle = MPMovieControlStyle.None
                player.movieSourceType = MPMovieSourceType.File
                player.repeatMode = MPMovieRepeatMode.None
                player.play()
                videoView.addSubview(player.view)
            }
        }
    }
    
    func videoHasEnded(notification: NSNotification) {
        let reasonValue = notification.userInfo![MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as! Int
        switch MPMovieFinishReason(rawValue: reasonValue)! {
        case .PlaybackEnded:
            if(songIndex++ < songs.count-1) {
                playVideo("\(songs[songIndex])")
            }
        default:
            // another code
            break
        }
    }
    
}
