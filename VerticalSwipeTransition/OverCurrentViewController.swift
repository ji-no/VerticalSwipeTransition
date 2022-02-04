//
//  OverCurrentViewController.swift
//  VerticalSwipeTransition
//
//  Created by ji-no on R 4/02/04.
//

import UIKit

class OverCurrentViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var dismissAnimator = VerticalSwipeDismissAnimator()

    override func viewDidLoad() {
        super.viewDidLoad()

        let panGestureRecognizer = UIPanGestureRecognizer(target: dismissAnimator, action: #selector(VerticalSwipeDismissAnimator.handleTransitionGesture(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        dismissAnimator.viewController = self
        dismissAnimator.targetView = imageView
        dismissAnimator.headerView = headerView
        dismissAnimator.footerView = footerView
        dismissAnimator.backgroundView = backgroundView
    }
    
    @IBAction func onTappedDismissButton(_ sender: Any) {
        dismiss(animated: true)
    }

}
