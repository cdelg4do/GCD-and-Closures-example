//
//  GCDViewController.swift
//  EjemploGCD
//
//  Created by Carlos Delgado on 13/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import UIKit

class GCDViewController: UIViewController {

    // URLs de las imágenes de tamaño grande a descargar
    let url1 = URL(string: "https://norwaytraveler.files.wordpress.com/2014/08/nidarosdomenpanorama.jpg")!  // 19 MB
    let url2 = URL(string: "http://www.challey.com/WTC/wtc_huge.jpg")!                                      // 14 MB
    let url3 = URL(string: "https://upload.wikimedia.org/wikipedia/commons/6/65/Taj_Mahal_Sunset.jpg")!     // 29 MB
    
    // Referencia a la imagen de la ventana
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // Tareas tras crearse el controlador (se invocan una sola vez)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        showDefaultImage()
    }
    
    // Acción al deslizar el slider de la pantalla (actualizar el alpha de la imagen)
    @IBAction func updateAplha(_ sender: UISlider) {
        
        let value: CGFloat = CGFloat(sender.value)
        imageView.alpha = value
    }
    
    
    // Descarga síncrona (en la cola principal)
    // ----------------------------------------------------------------------------------------
    @IBAction func syncDownload(_ sender: AnyObject) {
        
        var data: Data = Data()
        
        // Descargar el contenido de la url remota
        print("\nIniciando descarga síncrona de imagen remota...\n")
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        // Incluímos el resto de la operación en un bloque asyncAfter para dar un segundo de tiempo
        // a que se muestre el activityIndicator en pantalla
        // (en caso contrario, se mostraría y ocultaría antes de que el usuario pudiera verlo)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) ) {
                
                do {
                    try data = Data(contentsOf: self.url1)
                    print("\nHecho!\n")
                
                    // Crear una UIImage escalada con los datos descargados y asociarla a la vista correspondiente
                    let img = UIImage(data: data)!
                    let resizedImage = self.resizeImage(image: img, targetSize: CGSize(width: 1920.0, height: 1920.0) )
                
                    self.imageView.image = resizedImage
                }
                catch {
                    print("** ERROR ** Fallo al descargar/mostrar la imagen remota!!")
                }
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
        }
        
    }
    
    
    // Descarga asíncrona (en una cola en segundo plano)
    // ----------------------------------------------------------------------------------------
    @IBAction func asyncDownload(_ sender: AnyObject) {
        
        print("\nIniciando descarga asíncrona de imagen remota...\n")
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        // El contenido de esta clausura se ejecutará secuencialmente en una cola en segundo plano
        DispatchQueue.global(qos: .userInitiated).async {
                
            var data: Data
            
            do {
                // Descargar el contenido de la url remota
                
                
                try data = Data(contentsOf: self.url2)
                let img = UIImage(data: data)!
                let resizedImage = self.resizeImage(image: img, targetSize: CGSize(width: 1920.0, height: 1920.0) )
                
                print("\nHecho!\n")
                
                // El siguiente código (mostrar la imagen descargada y ocultar el activityIndicator)
                // se ejecuta en la cola principal
                DispatchQueue.main.async {
                    self.imageView.image = resizedImage
                    
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            }
            catch {
                print("** ERROR ** Fallo al cargar la imagen remota!!")
            }
            
        }
    }
    
    
    // Descarga asíncrona (en segundo plano), usando una clausura de finalización
    // que se ejecutará en primer plano cuando la otra operación acabe
    // ----------------------------------------------------------------------------------------
    @IBAction func actorDownload(_ sender: AnyObject) {
        
        withURL(url3) { (img: UIImage) in
            
            self.imageView.image = img
        }
        
        /*
        // Otra sintaxis: la clausura como un parámetro más
        
        withUrl(url3, completion: { (img: UIImage) in
            
            self.imageView.image = img
        })
        
        */
    }
    
    
    // Al pulsar el botón de reset se muestra la imagen por defecto
    @IBAction func resetImage(_ sender: AnyObject) {
        
        showDefaultImage()
    }
    
    
    // DECLARACIONES AUXILIARES
    // ---------------------------------------------------
    
    // Tipo que define una función de clausura
    // para trabajar con una UIImage (sin devolver nada)
    typealias imageClosure = (UIImage) -> ()
    
    
    // Función que recibe una url y un bloque de tipo imageClosure.
    // Intenta descargar y convertir en imagen el contenido de una URL remota, todo ello en segundo plano.
    // Si no falla, invoca en la cola principal al bloque de tipo imageClosure recibido, pasándole la imagen descargada
    
    func withURL(_ url: URL, completion: imageClosure) {
        
        print("\nIniciando descarga en segundo plano de imagen remota...\n")
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        // Carga de datos y confección de la imagen (en segundo plano)
        DispatchQueue.global(qos: .userInitiated).async {
            
            do {
                let data = try Data(contentsOf: url)
                let img = UIImage(data: data)!
                let resizedImage = self.resizeImage(image: img, targetSize: CGSize(width: 1920.0, height: 1920.0) )
                
                // Operaciones con la imagen obtenida y ocultar el activityIndicator (en la cola principal)
                DispatchQueue.main.async {
                    completion(resizedImage)
                    
                    print("\nHecho\n")
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            }
            catch {
                print("** ERROR ** Fallo al cargar la imagen remota!!")
            }
        }
    }
    
    // Función que muestra la imagen por defecto
    func showDefaultImage() -> () {
        
        imageView.image = UIImage(named: "default-image.jpg")
    }
    
    // Función que escala una imagen (para ahorrar memoria)
    // (ver https://iosdevcenters.blogspot.com/2015/12/how-to-resize-image-in-swift-in-ios.html)
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}
