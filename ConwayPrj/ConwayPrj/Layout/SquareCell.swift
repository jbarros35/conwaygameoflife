import UIKit

@IBDesignable
class SquareCell: UICollectionViewCell {
    
    public var row:Int?
    public var col:Int?
    public var live:Bool?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.live = false
    }
    
    func change(_ state:Bool) {
        self.backgroundColor = state ? UIColor.black : UIColor.white
        self.live = state
    }
    /*
    override var isSelected: Bool {
        willSet {
            if isSelected {
                if let active = self.live {
                    change(!active)
                } else {
                    change(true)
                }
            }
        }
    }
 */
}

