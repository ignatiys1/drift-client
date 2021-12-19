//
//  StagePairViewController.swift
//  Drift
//
//  Created by Ignat Urbanovich on 13.12.21.
//

import UIKit

class StagePairViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    var grid = Grid()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        createScrollView()
    }
    
    func createScrollView() {
        let imgToBgr = UIImage(named: "решетка")
        var img = imgToBgr
        let stepY = 39.25
        let stepX = 577.5
        
        
        for topGrid: Dictionary<Int, Driver> in grid.grids {
            for (position, driver) in topGrid {
                switch topGrid.count {
                case 32:
                    var x = 52.0
                    var y = 11.0
                    
                    switch position {
                    case 2...16:
                        y += Double((position-1))*stepY
                    case 17:
                        x += stepX
                    case 18...32:
                        x += stepX
                        y += Double((position-17)) * stepY
                    default: break
                    }
                  
                    let text = driver.FIO.replacingOccurrences(of: " ", with: "\n")
                    
                    img = add(text: text as NSString, toImage: img!, atPoint: CGPoint(x: x, y: y))
                    
                default: break
                }
            }
        }
        
        
        
        let imgView = UIImageView(image: img)
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(tap:)))
        tap.numberOfTapsRequired = 2
        
        scrollView.addGestureRecognizer(tap)
        
        
        scrollView.addSubview(imgView)
        let size = CGSize(width: imgView.bounds.size.width, height: imgView.bounds.size.height)
        
        imgView.bounds.size = size
        scrollView.contentSize = size
        scrollView.delegate = self
        
        scrollView.minimumZoomScale = CGFloat(self.view.bounds.width/imgView.bounds.width)
        scrollView.maximumZoomScale = CGFloat(self.view.bounds.height/imgView.bounds.height)
        
        
        scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        
        
    }
    
    @objc func doubleTapped(tap: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.minimumZoomScale{
            self.scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        } else {
            self.scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        scrollView.subviews[0]
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale < scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else if scrollView.zoomScale > scrollView.maximumZoomScale {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    func add(text: NSString, toImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica Bold", size: 9)!
        
        let scale = UIScreen.main.scale
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        image.draw(in: CGRect(origin: .zero, size: image.size))
        
        
        let attr = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor
        ]
        let rect = CGRect(origin: point , size: image.size)
        text.draw(in: rect , withAttributes: attr)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}
