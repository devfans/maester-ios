//
//  ViewMisc.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/18.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI
import Foundation

struct FittedImage: View
{
    let imageName: String
    let width: CGFloat
    let height: CGFloat
    let label: String? = nil

    var body: some View {
        VStack {
            Image(self.imageName)
                .resizable()
                .renderingMode(.template)
                .accessibility(label: Text(label ?? imageName))
                .aspectRatio(1, contentMode: .fit)
        }
        .frame(width: width, height: height)
    }
}


extension UIImageView {

    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

    @available(iOS 9.0, *)
    public func loadGif(asset: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(asset: asset)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

}

extension UIImage {

    public class func gif(data: Data, size: CGSize? = nil) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }

        return UIImage.animatedImageWithSource(source, size)
    }

    public class func gif(url: String) -> UIImage? {
        // Validate URL
        guard let bundleURL = URL(string: url) else {
            print("SwiftGif: This image named \"\(url)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(url)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    public class func gif(name: String) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = Bundle.main
          .url(forResource: name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    @available(iOS 9.0, *)
    public class func gif(asset: String, size: CGSize? = nil) -> UIImage? {
        // Create source from assets catalog
        guard let dataAsset = NSDataAsset(name: asset) else {
            print("SwiftGif: Cannot turn image named \"\(asset)\" into NSDataAsset")
            return nil
        }

        return gif(data: dataAsset.data, size: size)
    }

    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return delay
        }

        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)

        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        if let delayObject = delayObject as? Double, delayObject > 0 {
            delay = delayObject
        } else {
            delay = 0.1 // Make sure they're not too fast
        }

        return delay
    }

    internal class func gcdForPair(_ lhs: Int?, _ rhs: Int?) -> Int {
        var lhs = lhs
        var rhs = rhs
        // Check if one of them is nil
        if rhs == nil || lhs == nil {
            if rhs != nil {
                return rhs!
            } else if lhs != nil {
                return lhs!
            } else {
                return 0
            }
        }

        // Swap for modulo
        if lhs! < rhs! {
            let ctp = lhs
            lhs = rhs
            rhs = ctp
        }

        // Get greatest common divisor
        var rest: Int
        while true {
            rest = lhs! % rhs!

            if rest == 0 {
                return rhs! // Found it
            } else {
                lhs = rhs
                rhs = rest
            }
        }
    }

    internal class func gcdForArray(_ array: [Int]) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]

        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }

    internal class func animatedImageWithSource(_ source: CGImageSource, _ size: CGSize? = nil) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()

        // Fill arrays
        for index in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, index, nil) {
                images.append(image)
            }

            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(index),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }

        // Calculate full duration
        let duration: Int = {
            var sum = 0

            for val: Int in delays {
                sum += val
            }

            return sum
            }()

        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        
        if let newSize = size {
            let renderer = UIGraphicsImageRenderer(size: newSize)
            for index in 0..<count {
                let img_r = UIImage(cgImage: images[Int(index)])
                frame = renderer.image { _ in
                    img_r.draw(in: CGRect.init(origin: CGPoint.zero, size: newSize))
                }
                frameCount = Int(delays[Int(index)] / gcd)

                for _ in 0..<frameCount {
                    frames.append(frame)
                }
            }
        } else {
            for index in 0..<count {
                frame = UIImage(cgImage: images[Int(index)])
                frameCount = Int(delays[Int(index)] / gcd)
                for _ in 0..<frameCount {
                    frames.append(frame)
                }
            }
        }
        
        // Heyhey
        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)

        return animation
    }

}
/*
struct TextView: UIViewRepresentable {
    var placeholder: String
    @Binding var text: String

    var minHeight: CGFloat
    @Binding var calculatedHeight: CGFloat

    init(placeholder: String, text: Binding<String>, minHeight: CGFloat, calculatedHeight: Binding<CGFloat>) {
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
        self._calculatedHeight = calculatedHeight
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator

        // Decrease priority of content resistance, so content would not push external layout set in SwiftUI
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)

        // Set the placeholder
        textView.text = placeholder
        textView.textColor = UIColor.lightGray

        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        if textView.text != self.text {
            textView.text = self.text
        }

        recalculateHeight(view: textView)
    }

    func recalculateHeight(view: UIView) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if minHeight < newSize.height && $calculatedHeight.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                self.$calculatedHeight.wrappedValue = newSize.height // !! must be called asynchronously
            }
        } else if minHeight >= newSize.height && $calculatedHeight.wrappedValue != minHeight {
            DispatchQueue.main.async {
                self.$calculatedHeight.wrappedValue = self.minHeight // !! must be called asynchronously
            }
        }
    }

    class Coordinator : NSObject, UITextViewDelegate {

        var parent: TextView

        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }

        func textViewDidChange(_ textView: UITextView) {
            // This is needed for multistage text input (eg. Chinese, Japanese)
            if textView.markedTextRange == nil {
                parent.text = textView.text ?? String()
                parent.recalculateHeight(view: textView)
            }
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor.lightGray {
                textView.text = nil
                textView.textColor = UIColor.black
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.lightGray
            }
        }
    }
}*/
 
 fileprivate struct UITextViewWrapper: UIViewRepresentable {
     typealias UIViewType = UITextView

     @Binding var text: String
     @Binding var calculatedHeight: CGFloat
     var onDone: (() -> Void)?

     func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
         let textField = UITextView()
         textField.delegate = context.coordinator

         textField.isEditable = true
         textField.font = UIFont.preferredFont(forTextStyle: .body)
         textField.isSelectable = true
         textField.isUserInteractionEnabled = true
         textField.isScrollEnabled = false
         textField.backgroundColor = UIColor.clear
         if nil != onDone {
             textField.returnKeyType = .done
         }

         textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
         return textField
     }

     func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
         if uiView.text != self.text {
             uiView.text = self.text
         }
         if uiView.window != nil, !uiView.isFirstResponder {
             uiView.becomeFirstResponder()
         }
         UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
     }

     fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
         let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
         if result.wrappedValue != newSize.height {
             DispatchQueue.main.async {
                 result.wrappedValue = newSize.height // !! must be called asynchronously
             }
         }
     }

     func makeCoordinator() -> Coordinator {
         return Coordinator(text: $text, height: $calculatedHeight, onDone: onDone)
     }

     final class Coordinator: NSObject, UITextViewDelegate {
         var text: Binding<String>
         var calculatedHeight: Binding<CGFloat>
         var onDone: (() -> Void)?

         init(text: Binding<String>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil) {
             self.text = text
             self.calculatedHeight = height
             self.onDone = onDone
         }

         func textViewDidChange(_ uiView: UITextView) {
             text.wrappedValue = uiView.text
             UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
         }

         func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
             if let onDone = self.onDone, text == "\n" {
                 textView.resignFirstResponder()
                 onDone()
                 return false
             }
             return true
         }
     }

 }

 struct MultilineTextField: View {

     private var placeholder: String
     private var onCommit: (() -> Void)?

     @Binding private var text: String
    
     private var internalText: Binding<String> {
         Binding<String>(get: { self.text } ) {
             self.text = $0
             self.showingPlaceholder = $0.isEmpty
         }
     }

     @State private var dynamicHeight: CGFloat = 20
     @State private var showingPlaceholder = false

     init (_ placeholder: String = "", text: Binding<String>, onCommit: (() -> Void)? = nil) {
         self.placeholder = placeholder
         self.onCommit = onCommit
         self._text = text
         self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
     }

     var body: some View {
         UITextViewWrapper(text: self.internalText, calculatedHeight: $dynamicHeight, onDone: onCommit)
             .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
             .background(placeholderView, alignment: .topLeading)
     }

     var placeholderView: some View {
         Group {
             if showingPlaceholder {
                 Text(placeholder).foregroundColor(.gray)
                     .padding(.leading, 4)
                     .padding(.top, 8)
             }
         }
     }
 }

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
    
}
