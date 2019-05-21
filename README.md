# UIExpandableCVCellKit

A Framework to add a Apple Appstore like animation to expand the cell to fullscreen when selecting a UICollectionViewCell

<h2><b>Installation</b></h2>

1.  Install cocoapods
2.  add pod 'UIExpandableCVCellKit' to your Podfile
3.  run pod install from the command line your project directory with the Podfile

<h2><b>Setup</b></h2>

<b>UICollectionViewController: </b>
- Have your UICollectionView extend the ExpandableCVProtocol

- Add this line to your viewDidAppear(_ animated:) delegate function:
  collectionView.isScrollEnabled = (isCellOpen) ? false : true

  This will ensure when you swap between apps, that the scrolling is set to the correct setting when you swap between apps

- in collectionView(_ collectionView:, cellForItemAt indexPath:) dequeue your cell and then create the ExpandedCellViewModel and pass it to the cell using the ExpandableCVCellProtocol.configure(with: ExpandedCellViewMode) function, this will help the cell configure itself with all the settings it needs to function

- in collectionView(_ collectionView:, didSelectItemAt indexPath:) impliment animateCellOpen(indexPath:) inside that delegate function to allow the cell to open properly.  This is a manadatory implimentation.


<b>UICollectionViewCell:</b>
- Have your UICollectionViewCell extend ExpandablerCVCellProtocol

- Add setupPanGesture(selector: Selector) to your init(frame:) and init(coder:) initializers with your own gesturing funciton.  I usually call mine cellGestured(), inside that @objc function I add the default cellGesturedLogic() function.  You can of course override and write your own gesturing logic if required.

- Optionally you may impliment the following functions to add or write your own code to animate the cells open, close, or snap back:

  - func openCellHandler() -> (handler: Handler?, completion: Handler?, isAnimated: Bool)
  - func closeCellHandler() -> (handler: Handler?, completion: Handler?, isAnimated: Bool)
  - func snapBackCellHandler() -> (handler: Handler?, completion: Handler?, isAnimated: Bool)

  Example of how to the openCellHanlder() or any of the other optional handler functions:

	```
	func openCellHandler() -> (handler: Handler?, completion: Handler?, isAnimated: Bool) {

		let animations = {
			// your code that you would like animated into this block or any code you would like handled
		}

		let completion = {
			// any code you would like to run after the animations/handler
		}

		return (handler: animations, completion: completion, isAnimated: true)
	}
	```

<h2><b>Optional</b></h2>

If you want to hide and show the status bar when showing and hiding the expandable collectionViewCell do the following:
1. In your UICollectionView class

  Add:

	override var prefersStatusBarHidden: Bool {
		return statusBarShoudlBeHidden
	}

	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return .slide
	}

  You can choose another type of animation, if you like

2. Optionally you can use func animateStatusBar(duration: TimeInterval) to hide or show the status bar when required.  You should however set the setting for statusBarShouldBeHidden before you run this function.



<b>For an example project please see <link>https://github.com/yungdai/AppStoreAnimationDemo</link></b>
