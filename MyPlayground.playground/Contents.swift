import UIKit

////////////////////////////////////////////////////////////////////////////////////////////////////
// DRYUI
extension UIView {
    func add_subview<SubviewType:UIView>(subviewBlocks: (SubviewType) -> Void ...) -> SubviewType {
        let subview = SubviewType()
        self.addSubview(subview)
        subviewBlocks.forEach { $0(subview) }
        return subview
    }
}

// Styles are just functions
func RedStyle(v: UIView) {
    v.backgroundColor = UIColor.redColor()
}

// Dynamic styles are just curried functions
func LabelTextStyle(s: String) -> (UILabel -> Void) {
    return { $0.text = s }
}

func SizeStyle(s: CGSize) -> (UIView -> Void) {
    return { $0.frame.size = s }
}

func ButtonStyle(s: String) -> (UIButton -> Void) {
    return {
        $0.setTitle(s, forState: UIControlState.Normal)
        $0.backgroundColor = UIColor.redColor()
    }
}

let v = UIView(frame: CGRectMake(0, 0, 400, 250))

v.add_subview {v in
    v.frame.size = v.superview!.frame.size
    v.backgroundColor = UIColor.blueColor()
    // Applying styles, view type is inferred from style types
    let button = v.add_subview(ButtonStyle("buttonText"), SizeStyle(CGSizeMake(300, 40)))
    let label = v.add_subview(RedStyle, LabelTextStyle("label text!"), {v in
        v.font = UIFont.systemFontOfSize(20)
        v.textColor = UIColor.whiteColor()
        v.sizeToFit()
        v.frame = CGRectMake(20, button.frame.origin.y + 50, 300, 40)
    })
    let otherButton = v.add_subview{(v: UIButton) in }
}

v

////////////////////////////////////////////////////////////////////////////////////////////////////
// Ultimate
extension Dictionary {
    func mapPairs<OutKey: Hashable, OutValue>(@noescape transform: (Key, Value) -> (OutKey, OutValue)?) -> Dictionary<OutKey, OutValue> {
        var retVal: Dictionary<OutKey, OutValue> = [:]
        self.forEach {e in
           let t = transform(e)
            if let transformed = t {
                retVal[transformed.0] = transformed.1
            }
        }
        return retVal
    }
}

enum UltimateSubview: Int {
    case
    LeftTop = 0,
    Left,
    LeftDetail,
    LeftLower,
    Right,
    RightDetail,
    RightLower,
    BottomLine
    
    static func collect<T>(b: (UltimateSubview) -> T) -> [UltimateSubview: T] {
        var retVal: [UltimateSubview: T] = [:]
        var i = 0
        while let v = UltimateSubview(rawValue: i) {
            retVal[v] = b(v)
            i += 1
        }
        return retVal
    }
}

typealias UltimateSubviewTypes = [UltimateSubview: UIView.Type]

class Ultimate <UserInfoT> {
    
    let userInfo: UserInfoT
    
    init(_ userInfo: UserInfoT, builder: Ultimate->Void) {
        self.userInfo = userInfo
        builder(self)
    }
    
    private typealias ViewBlock = (UIView -> Void)
    private typealias ViewBlockAndType = (ViewBlock, UIView.Type)
    
    private var configs: [UltimateSubview: [ViewBlockAndType]] = UltimateSubview.collect { _ in [] }
    
    private func addConfig<T:UIView>(ultimateView: UltimateSubview, _ config: (T,UserInfoT)->Void) {
        configs[ultimateView]!.append(({[unowned self] v in
            config(v as! T, self.userInfo)
        }, T.self))
    }
    
    private func addConfig<T:UIView>(ultimateView: UltimateSubview, _ config: T->Void) {
        configs[ultimateView]!.append(({v in
            config(v as! T)
        }, T.self))
    }
    
    private typealias ul = UltimateSubview
    func leftTop     <T:UIView> (c: (T,UserInfoT)->Void) { addConfig(ul.LeftTop    , c) }
    func left        <T:UIView> (c: (T,UserInfoT)->Void) { addConfig(ul.Left       , c) }
    func leftLower   <T:UIView> (c: (T,UserInfoT)->Void) { addConfig(ul.LeftLower  , c) }
    func leftDetail  <T:UIView> (c: (T,UserInfoT)->Void) { addConfig(ul.LeftDetail , c) }
    func right       <T:UIView> (c: (T,UserInfoT)->Void) { addConfig(ul.Right      , c) }
    func rightDetail <T:UIView> (c: (T,UserInfoT)->Void) { addConfig(ul.RightDetail, c) }
    func rightLower  <T:UIView> (c: (T,UserInfoT)->Void) { addConfig(ul.RightLower , c) }
    func bottomLine  <T:UIView> (c: (T,UserInfoT)->Void) { addConfig(ul.BottomLine , c) }
    func leftTop     <T:UIView> (c: (T          )->Void) { addConfig(ul.LeftTop    , c) }
    func left        <T:UIView> (c: (T          )->Void) { addConfig(ul.Left       , c) }
    func leftLower   <T:UIView> (c: (T          )->Void) { addConfig(ul.LeftLower  , c) }
    func leftDetail  <T:UIView> (c: (T          )->Void) { addConfig(ul.LeftDetail , c) }
    func right       <T:UIView> (c: (T          )->Void) { addConfig(ul.Right      , c) }
    func rightDetail <T:UIView> (c: (T          )->Void) { addConfig(ul.RightDetail, c) }
    func rightLower  <T:UIView> (c: (T          )->Void) { addConfig(ul.RightLower , c) }
    func bottomLine  <T:UIView> (c: (T          )->Void) { addConfig(ul.BottomLine , c) }
    
    func resolveTypes() -> UltimateSubviewTypes {
        return configs.mapPairs {config -> (UltimateSubview, UIView.Type) in
            var lowestClass = UIView.self
            config.1.forEach {viewBlockAndType in
                if viewBlockAndType.1.isSubclassOfClass(lowestClass) {
                    lowestClass = viewBlockAndType.1
                }
            }
            return (config.0, lowestClass)
        }
    }
    
    func applyToView(view: UltimateView) {
        configs.forEach {config in
            config.1.forEach {viewBlockAndType in
                viewBlockAndType.0(view.getView(config.0))
            }
        }
    }
}

class UltimateView : UIView {
    
    var ultimateSubviews: [UltimateSubview: UIView]
    
    func getView(u: UltimateSubview) -> UIView {
        return self.ultimateSubviews[u]!
    }
    
    private typealias ul = UltimateSubview
    var leftTop    : UIView { return self.getView(ul.LeftTop    ) }
    var left       : UIView { return self.getView(ul.Left       ) }
    var leftDetail : UIView { return self.getView(ul.LeftDetail ) }
    var leftLower  : UIView { return self.getView(ul.LeftLower  ) }
    var right      : UIView { return self.getView(ul.Right      ) }
    var rightDetail: UIView { return self.getView(ul.RightDetail) }
    var rightLower : UIView { return self.getView(ul.RightLower ) }
    var bottomLine : UIView { return self.getView(ul.BottomLine ) }
    
    init(types: UltimateSubviewTypes) {
        self.ultimateSubviews = types.mapPairs {pair -> (UltimateSubview, UIView) in
            let view = pair.1.init()
            return (pair.0, view)
        }
        
        super.init(frame: CGRectZero)
        
        self.ultimateSubviews.forEach {pair in
            self.addSubview(pair.1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

let obj = Ultimate("sdf") {o in
    o.left {(v: UIView) in
        v.backgroundColor = UIColor.brownColor()
    }
    o.left {(v: UILabel) in
        v.textAlignment = NSTextAlignment.Center
    }
    o.left {(v: UILabel, t) in
        v.backgroundColor = UIColor.redColor()
        v.text = t
        v.frame = CGRectMake(20, 20, 400, 90)
    }
    o.right {v,_ in
        v.backgroundColor = UIColor.blueColor()
        v.frame = CGRectMake(20, 130, 400, 90)
    }
}

let view = UltimateView(types: obj.resolveTypes())
obj.applyToView(view)

view.frame = CGRectMake(0, 0, 500, 500)
let aaaaa = UIView(frame: CGRectMake(0, 0, 500, 500))
aaaaa.addSubview(view)

aaaaa


////////////////////////////////////////////////////////////////////////////////////////////////////
// Pipeline operator
infix operator |> { associativity left precedence 140 }
func |><LeftT, OutT>(left: LeftT, right: (LeftT -> OutT)) -> OutT {
    return right(left)
}

func double(x : Int) -> Int {
    return x + x
}

func add(x: Int, _ y: Int) -> Int {
    return x + y
}

let a = 10 |> double |> { $0+4 } |> { $0*2}
a



////////////////////////////////////////////////////////////////////////////////////////////////////
// Can I have Ultimate's subview types as generic type params? It seems like it...
class TypeTest<A: UIView, B: UIView> {
    init(a: (A -> Void)? = nil, b: (B -> Void)? = nil) {
        print(A.self)
        print(B.self)
        print("------------")
    }
}

func list<A: UIView, B: UIView>(l: TypeTest<A, B>...) -> TypeTest<A, B> {
    return TypeTest()
}

let why = [{(_: UILabel) in}, {(_: UIView) in}]

let it = TypeTest(
    a: {(_: UIView) in },
    b: {(_: UILabel) in }
)

let thing = list(
    it,
    TypeTest(
        a: {(_: UIView) in }
    ),
    TypeTest(
        a: {(_: UIView) in },
        b: {(_: UIView) in }
    )
)
