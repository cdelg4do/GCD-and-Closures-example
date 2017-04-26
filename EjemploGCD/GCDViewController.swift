//
//  GCDViewController.swift
//  EjemploGCD
//
//  This is just an example to illustrate the diference between performing
//  a heavy-load action in the foreground and in the background.
//

import UIKit

class GCDViewController: UIViewController {

    // URLs of large images to be downloaded
    let url1 = URL(string: "https://norwaytraveler.files.wordpress.com/2014/08/nidarosdomenpanorama.jpg")!          // 19 MB
    let url2 = URL(string: "http://joumxyzptlk.de/pics/normal/google_earth/Earth_13k_(13645x13645)_030,000.jpg")!   // 23 MB
    let url3 = URL(string: "https://upload.wikimedia.org/wikipedia/commons/6/65/Taj_Mahal_Sunset.jpg")!             // 29 MB
    
    // Reference to UI elements
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // What to do after the controller is created (called once)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        showDefaultImage()
    }
    
    
    //MARK: Actions to perform when the user interacts with the UI elements
    
    // When the slider is moved, the alpha of the image will change
    @IBAction func updateAplha(_ sender: UISlider) {
        
        let value: CGFloat = CGFloat(sender.value)
        imageView.alpha = value
    }
    
    // "Sync" button -> Synchronous download of image (in the main queue)
    @IBAction func syncDownload(_ sender: AnyObject) {
        
        var data: Data = Data()
        
        print("\nInitiating synchronous download of remote image...")
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        
        // The download operation is wrapped inside an asyncAfter block, just to add a one second delay before starting
        // (this gives the activityIndicator time enough to show on screen)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) ) {
            
            do {
                try data = Data(contentsOf: self.url1)
                print("Done!")
                
                // Create an scaled UIImage with the downloaded data and show it on screen
                let img = UIImage(data: data)!
                let resizedImage = self.resizeImage(image: img, targetSize: CGSize(width: 1920.0, height: 1920.0) )
                self.imageView.image = resizedImage
            }
            catch {
                print("** ERROR ** Failed to download/show the remote image!")
            }
                
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
    
    // "Async #1" button -> Asynchronous download of image (using a background queue)
    @IBAction func asyncDownload(_ sender: AnyObject) {
        
        print("\nInitiating asynchronous download of remote image...")
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
                
            var data: Data
            
            do {
                try data = Data(contentsOf: self.url2)
                print("Done!")
                
                let img = UIImage(data: data)!
                let resizedImage = self.resizeImage(image: img, targetSize: CGSize(width: 1920.0, height: 1920.0) )
                
                // Showing the image and hiding the activityIndicator are done in the main queue
                DispatchQueue.main.async {
                    self.imageView.image = resizedImage
                    
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            }
            catch {
                print("** ERROR ** Failed to download/show the remote image!")
            }
        }
    }
    
    
    // "Async #2" button -> Asynchronous download of image (using a closure)
    @IBAction func asyncDownloadWithClosure(_ sender: AnyObject) {
        
        downloadImageInBackground(url3) { (img: UIImage) in
            
            self.imageView.image = img
        }
        
        /*  Alternate syntax: the closure as a parameter
         
         downloadImageInBackground(url3, completion: { (img: UIImage) in
         
         self.imageView.image = img
         })
         */
    }
    
    
    // "Reset" button -> Show the default image
    @IBAction func resetImage(_ sender: AnyObject) {
        
        showDefaultImage()
    }
    
    
    //MARK: Auxiliary declarations
    
    // Tipo que define una función de clausura
    // para trabajar con una UIImage (sin devolver nada)
    typealias imageClosure = (UIImage) -> ()
    
    
    // Function that receives an url and a block of imageClosure type.
    // It attempts to download the data from the url and convert it into a resized image (in a background queue).
    // If the operation is successful, invokes the imageClosure block passing the image to it (in the main queue).
    func downloadImageInBackground(_ url: URL, completion: @escaping imageClosure) {
        
        print("\nInitiating asynchronous download of remote image...")
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            do {
                let data = try Data(contentsOf: url)
                let img = UIImage(data: data)!
                let resizedImage = self.resizeImage(image: img, targetSize: CGSize(width: 1920.0, height: 1920.0) )
                
                DispatchQueue.main.async {
                    completion(resizedImage)
                    
                    print("Done!")
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            }
            catch {
                print("** ERROR ** Failed to download/show the remote image!")
            }
        }
    }
    
    // Shows the default image on screen
    func showDefaultImage() -> () {
        
        imageView.image = UIImage(named: "default-image.jpg")
    }
    
    
    // Escalates an image to fit into a given size (to prevent memory crashes when showing it)
    // (see https://iosdevcenters.blogspot.com/2015/12/how-to-resize-image-in-swift-in-ios.html)
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        
        let initialSize = image.size
        
        let widthRatio  = targetSize.width  / initialSize.width
        let heightRatio = targetSize.height / initialSize.height
        
        // Figure out what our orientation is, and use that to calculate the new image size
        var newSize: CGSize
        
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: initialSize.width * heightRatio, height: initialSize.height * heightRatio)
        }
        else {
            newSize = CGSize(width: initialSize.width * widthRatio, height: initialSize.height * widthRatio)
        }
        
        // Build the new rect to resize the image
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}
