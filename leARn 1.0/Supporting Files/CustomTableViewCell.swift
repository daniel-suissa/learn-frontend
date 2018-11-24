import UIKit
class ItemCell : UITableViewCell {
     var item : Item? {
        didSet {
            itemImage.image = item?.image
            itemNameLabel.text = item?.label
            itemDescriptionLabel.text = item?.owner
            downloadButton.tag = (item?.id)!
        }
     }
    
     private let itemNameLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.boldSystemFont(ofSize: 18)
        lbl.textAlignment = .left
        return lbl
     }()
     
     
     private let itemDescriptionLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .gray
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
     }()
    
     
     private let itemImage : UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
     }()
    
    private let downloadButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitle("Download", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(MarketplaceViewController.didTapDownload), for: .touchUpInside)
        return button
    }()
     
     override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(itemImage)
        addSubview(itemNameLabel)
        addSubview(itemDescriptionLabel)
        addSubview(downloadButton)
        
        itemImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 90, height: 0, enableInsets: false)
        itemNameLabel.anchor(top: topAnchor, left: itemImage.rightAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width / 2, height: 0, enableInsets: false)
        itemDescriptionLabel.anchor(top: itemNameLabel.bottomAnchor, left: itemImage.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width / 2, height: 0, enableInsets: false)
        
        
        let stackView = UIStackView(arrangedSubviews: [downloadButton])
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.spacing = 5
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: itemNameLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 15, paddingLeft: 5, paddingBottom: 15, paddingRight: 10, width: 0, height: 70, enableInsets: false)
        
     }
     
     required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
     }
     
     
}
