import UIKit

@IBDesignable
class SquareCell: UICollectionViewCell {
    
    public var row:Int = 0
    public var col:Int = 0
    public var live:Bool = false
    
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
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    func change(_ state:Bool) {
        self.backgroundColor = state ? .black : .white
        self.live = state
    }
}

