# Our-Coding-Conventions-And-Architecture
Here is a style guide coding for my team. To make the code more readable, reliable and clean.
# Table of Contents
- [Styles and Conventions](#styles-and-conventions)
    - [Formatting](#formatting)
        - [Semicolons (`;`)](#semicolons)
        - [Whitespaces](#whitespaces)
        - [Commas (`,`)](#commas)
        - [Colons (`:`)](#colons)
        - [Braces (`{}`)](#braces)
        - [Control Flow Statements](#control-flow-statements)
    - [Naming](#naming)
        - [Capitalization (`class`,`struct`,`enum`,`protocol`)](#capitalization)
        - [Properties](#properties)
        - [Outlet](#outlet)
        - [Computed Properties](#computed-properties)

# Naming 
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

    get
    {
        return RightIcon
    }
    set
    {
        RightIcon = newValue
    }
}
}
</pre></td>
</tr>
</table>

### Outlet
We name an outlet according to the number of vowels. Get only the first characters of each vowels afther `UI` prefix and make them concatenating. For example  
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
@IBOutlet dynamic var iv_profile: UIImageView!
</pre></td>
<td><pre lang=swift>
@IBOutlet dynamic var profileImageZView: UIImageView!
</pre></td>
</tr>
</table>
