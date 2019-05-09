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
  collectionView.isScrollEnabled = (isOpen) ? false : true
  
  This will ensure when you swap between apps, that the scrolling is set to the correct setting when you swap betweena apps
  
- in collectionView(_ collectionView:, cellForItemAt indexPath:) dequeue your cell and then create the ExpandedCellViewModel and pass it to the cell using the ExpandableCVCellProtocol.configure(with: ExpandedCellViewMode) function, this will help the cell configure itself with all the settings it needs to function


<b>UICollectionViewCell:</b>
- Have your UICollectionViewCell extend ExpandablerCVCellProtocol

- Add setupPanGesture(selector: Selector) to your init(frame:) and init(coder:) initializers with your own gesturing funciton.  I usually call mine cellGestured(), inside that @objc function I add the default cellGesturedLogic() function.  You can of course override and write your own gesturing logic if required.

- You must impliment the following functions:

    openCell(), closeCell(), and snapBackCell()
   
   There are handy default logic for each of the functions if you want the bare minimum, you can then customize the functions with any of your own required animations in each of the functions.


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
  
2. The statusBarShouldBeHidden propertly should be set up as:

```
  var statusBarShoudlBeHidden = false {
		didSet {
			UIView.animate(withDuration: 0.3) {
				self.setNeedsStatusBarAppearanceUpdate()
			}
		}
	}
```
  
You can of course change the animation duration.  You can also impliment this optional setting your own way.



<b>For an example project please see <link>https://github.com/yungdai/AppStoreAnimationDemo</link></b>

