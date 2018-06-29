# Our-Coding-Conventions-And-Architecture
***Thank to*** https://github.com/eure/swift-style-guide. Here is a style guide coding for my team.  
Here is the reason why we do it
- Clean
- Maintainance
- Hotfix
- UnitTest
- Productivity
- Good Communication in team
# Table of Contents
- [Coding Conventions](#coding-conventions)
    - [Formatting](#formatting)
        - [Semicolons (`;`)](#semicolons) `//TODO`
        - [Whitespaces](#whitespaces) `//TODO`
        - [Commas (`,`)](#commas) `//TODO`
        - [Colons (`:`)](#colons) `//TODO`
        - [Braces (`{}`)](#braces) `//TODO`
        - [Control Flow Statements](#control-flow-statements)
    - [Naming](#naming)
        - [Capitalization (`class`,`struct`,`enum`,`protocol`)](#capitalization)
        - [Properties](#properties)
        - [Outlet](#outlet)
        - [Computed Properties](#computed-properties)
- [Architecture](#architecture)
    - [MVVM](#mvvm)
    - [API Network Intregration](#apinetworkintregration) `//TODO`
    - [Model](#model)
## Formatting
### Whitespaces 
<!-- <table>
<tr><th>OK</th></tr>
<tr>
<td><pre lang=swift>
class BaseViewController: UIViewController {
    // ...
    override viewDidLoad() {
        // ...
    }

    override viewWillAppear(animated: Bool) {
        // ...
    }
}
</pre>
</tr>
</table>  -->
| Left-aligned | Center-aligned | Right-aligned |
| :---         |     :---:      |          ---: |
| git status   | git status     | git status    |
| git diff     | git diff       | git diff      |

### Control flow statements
#### `if`, `else`, `switch`, `do`, `catch`, `repeat`, `guard`, `for`, `while`, and `defer` statements should be left-aligned with their respective close braces (`}`).
<table>
<tr><th>OK</th><th>NG</th></tr>
<tr>
<td><pre lang=swift>
if array.isEmpty {
    // ...
}
else {
    // ...
}
</pre></td>
<td><pre lang=swift>

if array.isEmpty {
    // ...
} else {
    // ...
}
</pre></td>
</tr>
</table> 

## Naming 
### Capitalization
#### Type names (`class`, `struct`, `enum`, `protocol`) should be in *UpperCamelCase*. 
<table>
<tr><th>OK</th><th>NO</th></tr>
<tr>
<td><pre lang=swift>
class ImageButton {
    enum ButtonState {
        // ...
    }
}
</pre></td>
<td><pre lang=swift>
class image_button {
    enum buttonState {
        // ...
    }
}
</pre></td>
</tr>
</table>

### Properties
<table>
<tr><th>OK</th><th>NO</th></tr>
<tr>
<td><pre lang=swift>
var rightIcon = "pencil"
</pre></td>
<td><pre lang=swift>
var right_icon = "pencil"
</pre></td>
</tr>
</table>


### Computed Properties
<table>
<tr><th>OK</th><th>NO</th></tr>
<tr>
<td><pre lang=swift>
class ButtonWithRightIcon { 
    var _rightIcon : Float = 0.0
    var rightIcon: Float {
        get {
            return _rightIcon
        }
        set {
            _rightIcon = newValue
        }
    }
}

</pre></td>
<td><pre lang=swift>
class ButtonWithRightIcon {  
    var RightIcon : Float = 0.0
    var right_icon: Float {
        get{
            return RightIcon
        }
        set{
            RightIcon = newValue
        }
    }
}
</pre></td>
</tr>
</table>

### Outlet
We name an outlet according to the number of vowels. Get only the first characters of each vowels after `UI` prefix and make them concatenating. For example  
- UILabel = lb
- UIImageView = imv
- UIButton = bt
- UIView = v
- UICollectionView = cltv
- UIScrollView = scv  
- UITableView = tbv

and so on
<table>
<tr><th>OK</th><th>NO</th></tr>
<tr>
<td><pre lang=swift>
@IBOutlet dynamic var imv_profile: UIImageView!
</pre></td>
<td><pre lang=swift>
@IBOutlet dynamic var profileImageZView: UIImageView!
</pre></td>
</tr>
</table>  
  
## Architecture
### MVVM
We create an instance of viewmodel on lazy property for convinient usage and set delegate back to its `ViewController`. ViewModel does call delegate upon on its need of the ViewController. ViewModel can emit somekind of data or an success/failure data of API.
```swift
class ExampleViewController : UIViewController {
    lazy var viewModel = ExampleViewModel(instance : self)
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.requestAsynchronousFromNetwork()
    }
}
extension ExampleViewController : ExampleViewDelegate {
    func didFinishInitilization(){
        print("didFinishInitilization")
    }
}
protocol ExampleViewDelegate : AnyObject {
    func didFinishInitilization()
    func didFinishRequestAsynchronousFromNetwork(isFinish : Bool)
}
class ExampleViewModel {
    weak var delegate :  ExampleViewDelegate
    var models = [String]()
    init(instance : ExampleViewDelegate) {
        self.delegate = instance
        
    }
    func requestAsynchronousFromNetwork(){
        API.request ({ isFinish in 
            delegate.didFinishRequestAsynchronousFromNetwork(isFinish : isFinish)
        })
    }
    func initilization(){
        models.append("1")
        models.append("2")
        models.append("3")
        models.append("4")
        delegate.didFinishInitilization()
    }
} 
```

### Model
<table>
<tr><th>OK</th><th>NO</th></tr>
<tr>
<td><pre lang=swift>
class ProfileModel {
    // ...
}
</pre></td>
<td><pre lang=swift>
class Profile {
    // ...
}
</pre></td>
</tr>
</table>