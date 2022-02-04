//
//  VerticalSwipeDismissAnimator.swift
//  VerticalSwipeTransition
//  
//  Created by ji-no on R 4/02/04
//  

import UIKit

class VerticalSwipeDismissAnimator {
    enum State {
        case idle
        case swiping
        case shouldFinish
    }
    private let percentThreshold: CGFloat = 0.3
    private let shouldFinishVerocityY: CGFloat = 1200
    private var state: State = .idle
    private var headerOrigin: CGPoint = .zero
    private var footerOrigin: CGPoint = .zero
    private var targetOrigin: CGPoint = .zero
    private var isHiddenHeaderFooter: Bool = false

    var viewController: UIViewController?
    var headerView: UIView? {
        didSet {
            headerOrigin = headerView?.frame.origin ?? .zero
        }
    }
    var footerView: UIView? {
        didSet {
            footerOrigin = footerView?.frame.origin ?? .zero
        }
    }
    var targetView: UIView?{
        didSet {
            targetOrigin = targetView?.frame.origin ?? .zero
        }
    }
    var backgroundView: UIView?

    @objc func handleTransitionGesture(_ sender: UIPanGestureRecognizer) {
        guard let view = viewController?.view else { return }

        let verticalMovement = sender.translation(in: view).y / view.bounds.height
        let progress = CGFloat(verticalMovement)
        let velocity = sender.velocity(in: view).y

        switch sender.state {
        case .changed:
            if abs(progress) > percentThreshold || abs(velocity) > shouldFinishVerocityY {
                state = .shouldFinish
            } else {
                state = .swiping
            }
            update(progress)

        case .cancelled:
            cancel()

        case .ended:
            switch state {
            case .shouldFinish:
                if (progress > 0 && velocity > 0) || (progress < 0 && velocity < 0) {
                    finish(progress)
                } else {
                    cancel()
                }
            case .swiping, .idle:
                cancel()
            }

        default:
            break
        }
    }

}

extension VerticalSwipeDismissAnimator {
    
    private func update(_ progress: CGFloat) {
        updateHeaderFooter(hidden: true)

        targetView?.frame = calculateTargetViewFrame(progress)

        backgroundView?.alpha = 1 - abs(progress)
    }
    
    private func cancel() {
        updateHeaderFooter(hidden: false)

        let frame = calculateTargetViewFrame(0)

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.curveLinear],
            animations: { [weak self] in
                self?.targetView?.frame = frame
                self?.backgroundView?.alpha = 1
            }
        )
    }
    
    private func finish(_ progress: CGFloat) {
        let frame = calculateTargetViewFrame(progress < 0 ? -1 : 1)

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.curveLinear],
            animations: { [weak self] in
                self?.targetView?.frame = frame
                self?.backgroundView?.alpha = 0
            },
            completion: { [weak self] _ in
                self?.viewController?.dismiss(animated: false)
            }
        )
    }
    
    private func calculateTargetViewFrame(_ progress: CGFloat) -> CGRect {
        guard let viewController = viewController else { return .zero }
        guard let targetView = targetView else { return .zero }
        
        let y: CGFloat
        if progress < 0 {
            y = targetOrigin.y + (targetOrigin.y + targetView.frame.size.height) * progress
        } else {
            y = targetOrigin.y + (viewController.view.frame.height - targetOrigin.y) * progress
        }

        return CGRect(origin: CGPoint(x: targetView.frame.origin.x, y: y), size: targetView.bounds.size)
    }
    
    private func updateHeaderFooter(hidden: Bool) {
        guard isHiddenHeaderFooter != hidden else { return }
        isHiddenHeaderFooter = hidden
        
        let alpha: CGFloat = hidden ? 0 : 1

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseIn],
            animations: { [weak self] in
                guard let self = self else { return }
                if let headerView = self.headerView {
                    let origin: CGPoint
                    if hidden {
                        origin = CGPoint(x: self.headerOrigin.x, y: self.headerOrigin.y - headerView.frame.size.height)
                    } else {
                        origin = self.headerOrigin
                    }
                    headerView.frame.origin = origin
                    headerView.alpha = alpha
                }
                if let footerView = self.footerView {
                    let origin: CGPoint
                    if hidden {
                        origin = CGPoint(x: self.footerOrigin.x, y: self.footerOrigin.y + footerView.frame.size.height)
                    } else {
                        origin = self.footerOrigin
                    }
                    footerView.frame.origin = origin
                    footerView.alpha = alpha
                }
            }
        )
    }

}
