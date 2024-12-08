import UIKit

class TableViewEventCell: UITableViewCell {

    var wrapperCellView: UIView!
    var eventImageView: UIImageView!
    var nameLabel: UILabel!
    var descriptionLabel: UILabel!
    var tagsLabel: UILabel!
    var rsvpLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupWrapperCellView()
        setupEventImageView()
        setupNameLabel()
        setupDescriptionLabel()
        setupTagsLabel()
        setupRsvpLabel()
        initConstraints()
    }

    func setupWrapperCellView() {
        wrapperCellView = UIView()
        wrapperCellView.backgroundColor = .white
        wrapperCellView.layer.cornerRadius = 12
        wrapperCellView.layer.shadowColor = UIColor.gray.cgColor
        wrapperCellView.layer.shadowOpacity = 0.2
        wrapperCellView.layer.shadowOffset = CGSize(width: 0, height: 2)
        wrapperCellView.layer.shadowRadius = 4
        wrapperCellView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(wrapperCellView)
    }

    func setupEventImageView() {
        eventImageView = UIImageView()
        eventImageView.contentMode = .scaleAspectFill
        eventImageView.clipsToBounds = true
        eventImageView.layer.cornerRadius = 8
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(eventImageView)
    }

    func setupNameLabel() {
        nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(nameLabel)
    }

    func setupDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(descriptionLabel)
    }

    func setupTagsLabel() {
        tagsLabel = UILabel()
        tagsLabel.font = UIFont.italicSystemFont(ofSize: 12)
        tagsLabel.textColor = .blue
        tagsLabel.numberOfLines = 1
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(tagsLabel)
    }

    func setupRsvpLabel() {
        rsvpLabel = UILabel()
        rsvpLabel.font = UIFont.systemFont(ofSize: 12)
        rsvpLabel.textColor = .gray
        rsvpLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(rsvpLabel)
    }

    func initConstraints() {
        NSLayoutConstraint.activate([
            // Wrapper View Constraints
            wrapperCellView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            wrapperCellView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            wrapperCellView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            wrapperCellView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),

            // Event Image Constraints
            eventImageView.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 10),
            eventImageView.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 10),
            eventImageView.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -10),
            eventImageView.heightAnchor.constraint(equalToConstant: 200),

            // Name Label Constraints
            nameLabel.topAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -10),

            // Description Label Constraints
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -10),

            // Tags Label Constraints
            tagsLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            tagsLabel.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 10),
            tagsLabel.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -10),

            // RSVP Label Constraints
            rsvpLabel.topAnchor.constraint(equalTo: tagsLabel.bottomAnchor, constant: 5),
            rsvpLabel.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 10),
            rsvpLabel.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -10),
            rsvpLabel.bottomAnchor.constraint(equalTo: wrapperCellView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
