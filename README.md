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
        - [Whitespaces](#whitespaces)
        - [Commas (`,`)](#commas)
        - [Colons (`:`)](#colons)
        - [Braces (`{}`)](#braces) `//TODO`
        - [Control Flow Statements](#control-flow-statements)
    - [Naming](#naming)
        - [Capitalization (`class`,`struct`,`enum`,`protocol`)](#capitalization)
        - [Properties](#properties)
        - [Outlet](#outlet)
        - [Computed Properties](#computed-properties)
- [Architecture](#architecture)
    - [MVVM](#mvvm)
        - [Submiting Data](#submitting-data)
    - [API Network Intregration](#apinetworkintregration) `//TODO`
    - [Model](#model)
## Formatting
### Whitespaces 
<table>
<tr><th>OK</th></tr>
<tr>
<td><pre lang=swift>
class BaseViewController: UIViewController {
        //<-- new line
        override viewDidLoad() {
            // ...
        }
        //<-- new line
        override viewWillAppear(animated: Bool) {
            // ...
        }
        //<-- new line
}
</pre>
</tr>
</table> 

### Commas
#### Commas (`,`) should have no whitespace before it, and should have either one space or one newline after.
<table>
<tr><th>OK</th><th>NG</th></tr>
<tr>
<td><pre lang=swift>
let array = [1, 2, 3]
</pre></td>
<td><pre lang=swift>
let array = [1,2,3]
let array = [1 ,2 ,3]
let array = [1 , 2 , 3]
</pre></td>
</tr>
<tr>
<td><pre lang=swift>
self.presentViewController(
    controller,
    animated: true,
    completion: nil
)
</pre></td>
<td><pre lang=swift>
self.presentViewController(
    controller ,
    animated: true,completion: nil
)
</pre></td>
</tr>
</table>


### Colons  
#### Colons (`:`)  used to indicate type should have one space after it and should have no whitespace before it.
<table>
<tr><th>OK</th><th>NG</th></tr>
<tr>
<td><pre lang=swift>
func createItem(item: Item)
</pre></td>
<td><pre lang=swift>
func createItem(item:Item)
func createItem(item :Item)
func createItem(item : Item)
</pre></td>
</tr>
<tr>
<td><pre lang=swift>
var item: Item? = nil
</pre></td>
<td><pre lang=swift>
var item:Item? = nil
var item :Item? = nil
var item : Item? = nil
</pre></td>
</tr>
</table>

### Control flow statements
#### `if`, `else`, `switch`, `do`, `catch`, `repeat`, `guard`, `for`, `while`, and `defer` statements should be left-aligned with their respective close braces (`}`).
<table>
<tr><th>OK</th><th>NG</th></tr>
<tr>
<td valign="top"><pre lang=swift>
if array.isEmpty {
    // ...
} else if array.count > 2 {
    // ...
} else {
    // ...
}
</pre></td>
<td valign="top"><pre lang=swift>
if array.isEmpty {
    // ...
}
else if array.count > 2 {
    // ...
}
else {
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
    weak var delegate :  ExampleViewDelegate!
    var models = [String]()
    var email: String = ""
    var fullName: String = ""
    init(instance: ExampleViewDelegate) {
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

    func isvalidated(email : String?, fullName : String?) -> Bool{
        if email.isNilOrEmpty() ||  fullName.isNilOrEmpty {
            return false
        }
        self.email = email!
        self.fullName = fullName!
        return true
    }

    func submit(){
        API.register(email: self.email, fullname: self.fullName ){
            //...
        }
    }
} 
```
#### Submitting Data
##### Option 1 : Simple
I extends UITextField class to handle validation of empty/nil string by itself. Here is my custom textfield ([BHTextField](https://github.com/tylerlantern/BHTextField)) which i have been using for several projects. Have a look for better understading.
```swift
class ExampleViewController: UIViewController {
    @IBOutlet weak var tb_email: UITextField!
    @IBOutlet weak var tb_fullName: UITextField!
    lazy var viewModel = ExampleViewModel(instance : self)

    @IBAction func action_submit(_ sender: Any) {
       guard viewmodel.isvalidated( email: self.tb_email.text, fullName: self.tb_fullName.text) else {
           tb_email.showErrorOnRequiredField()
           tb_fullName.showErrorOnRequiredField()
           return
       }
        viewModel.submit()
    }

}
extension ExampleViewController: ExampleViewDelegate {
    func didFinishSubmitting(isSuccess: Bool){
        //..
    }
}
protocol ExampleViewDelegate: AnyObject {
    func didFinishSubmitting(isSuccess: Bool)
}
class ExampleViewModel {
    weak var delegate: ExampleViewDelegate!
    var models = [String]()
    var email: String = ""
    var fullName: String = ""

    init(instance: ExampleViewDelegate) {
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

    func isvalidated(email : String?, fullName : String?) -> Bool{
        if email.isNilOrEmpty() ||  fullName.isNilOrEmpty {
            return false
        }
        self.email = email!
        self.fullName = fullName!
        return true
    }

    func submit(){
        API.register(email: self.email, fullname: self.fullName ){ isSuccess in
            delegate.didFinishSubmitting(isSuccess: isSuccess)
        }
    }

} 
```
##### Option 2 : Two Way Data Binding
//TODO

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