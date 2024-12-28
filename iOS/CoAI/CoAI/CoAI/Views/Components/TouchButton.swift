//
//  TouchButton.swift
//  Geddy
//
//  Created by Yu Ho Kwok on 10/2/24.
//

import SwiftUI
import UIKit

struct TouchDownView: UIViewRepresentable {
    typealias TouchDownCallback = ((_ state: UIGestureRecognizer.State) -> Void)

    var callback: TouchDownCallback

    func makeUIView(context: UIViewRepresentableContext<TouchDownView>) -> TouchDownView.UIViewType {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.isUserInteractionEnabled = true
        view.image = UIImage(named: "google-gemini-icon")
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)


        let gesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.gestureRecognized)
        )

        gesture.minimumPressDuration = 0
        view.addGestureRecognizer(gesture)

        return view
    }

    class Coordinator: NSObject {
        var callback: TouchDownCallback

        init(callback: @escaping TouchDownCallback) {
            self.callback = callback
        }

        @objc fileprivate func gestureRecognized(gesture: UILongPressGestureRecognizer) {
            callback(gesture.state)
        }
    }

    func makeCoordinator() -> TouchDownView.Coordinator {
        return Coordinator(callback: callback)
    }

    func updateUIView(_ uiView: UIView,
                      context: UIViewRepresentableContext<TouchDownView>) {
    }
}
