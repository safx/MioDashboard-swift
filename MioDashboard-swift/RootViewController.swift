//
//  RootViewController.swift
//  MioDashboard-swift
//
//  Created by Safx Developer on 2015/05/17.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import UIKit
import IIJMioKit

class RootViewController: UIViewController, UIPageViewControllerDelegate {

    var pageViewController: UIPageViewController?


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func dataDidLoad() {
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController!.delegate = self

        let startingViewController: DataViewController = modelController.viewControllerAtIndex(0, storyboard: storyboard!)!
        let viewControllers = [startingViewController]
        pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })

        pageViewController!.dataSource = modelController

        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)

        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = view.bounds
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0)
        }
        pageViewController!.view.frame = pageViewRect

        pageViewController!.didMoveToParentViewController(self)

        // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
        view.gestureRecognizers = pageViewController!.gestureRecognizers
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let client = MIORestClient.sharedClient
        if client.authorized {
            getData()
        } else {
            let status = client.loadAccessToken()
            if status == .Success {
                getData()
            } else {
                authorize { [weak self] err in
                    if err != nil {
                        self?.getData()
                    }
                }
            }
        }
    }

    private func authorize(closure: MIORestClient.OAuthCompletionClosure) {
        let app = UIApplication.sharedApplication()
        let window = app.windows[0] as! UIWindow
        let view = window.rootViewController!.view
        MIORestClient.sharedClient.authorizeInView(view!, closure: closure)
    }

    private func getData() {
        MIORestClient.sharedClient.getMergedInfo { [weak self] (response, error) -> Void in
            if let s = self, r = response, info = r.couponInfo {
                s.modelController.pageData = info
                s.dataDidLoad()
            }
        }
    }

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }

    var _modelController: ModelController? = nil

    // MARK: - UIPageViewController delegate methods

    func pageViewController(pageViewController: UIPageViewController, spineLocationForInterfaceOrientation orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        if (orientation == .Portrait) || (orientation == .PortraitUpsideDown) || (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
            let currentViewController = pageViewController.viewControllers[0] as! UIViewController
            let viewControllers = [currentViewController]
            pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {done in })

            pageViewController.doubleSided = false
            return .Min
        }

        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = pageViewController.viewControllers[0] as! DataViewController
        let viewControllers: [AnyObject]

        let indexOfCurrentViewController = modelController.indexOfViewController(currentViewController)
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = modelController.pageViewController(pageViewController, viewControllerAfterViewController: currentViewController)
            viewControllers = [currentViewController, nextViewController!]
        } else {
            let previousViewController = modelController.pageViewController(pageViewController, viewControllerBeforeViewController: currentViewController)
            viewControllers = [previousViewController!, currentViewController]
        }
        pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {done in })

        return .Mid
    }


}
