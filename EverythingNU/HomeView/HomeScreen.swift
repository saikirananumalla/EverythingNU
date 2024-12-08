import UIKit

class HomeScreen: UIView {

    private let firstSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        if let imagePath = Bundle.main.path(forResource: "applogo", ofType: "png"),
           let image = UIImage(contentsOfFile: imagePath) {
            // Use the image
            imageView.image = image
        } else {
            print("Image not found!")
        }

        // imageView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: "your_image_name", ofType: "png"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "EverythingNU"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let secondSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var currentEventsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Current Events", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var rsvpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("RSVP By You", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var createdByYouButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Created By You", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var thirdSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let fourthSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var iconButton1: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "house.circle"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var iconButton2: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var iconButton3: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "map.circle"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var iconButton4: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setupView() {
        // Adding subviews to the first section
        firstSection.addSubview(logoImageView)
        firstSection.addSubview(appNameLabel)
        firstSection.addSubview(searchButton)
        
        // Adding subviews to the second section
        secondSection.addSubview(currentEventsButton)
        secondSection.addSubview(rsvpButton)
        secondSection.addSubview(createdByYouButton)
        
        // Adding subviews to the fourth section
        fourthSection.addSubview(iconButton1)
        fourthSection.addSubview(iconButton2)
        fourthSection.addSubview(iconButton3)
        fourthSection.addSubview(iconButton4)
        
        // Adding all sections to the main view
        self.addSubview(firstSection)
        self.addSubview(secondSection)
        self.addSubview(thirdSection)
        self.addSubview(fourthSection)
    }

    // MARK: - Setup Constraints

    public func setupConstraints() {
        NSLayoutConstraint.activate([
            // First Section Constraints
            firstSection.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            firstSection.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            firstSection.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            firstSection.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.075),
            
            logoImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            logoImageView.leadingAnchor.constraint(equalTo: firstSection.leadingAnchor, constant: 8),
            logoImageView.trailingAnchor.constraint(equalTo: firstSection.leadingAnchor, constant: 64),
            logoImageView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.075),
            
            appNameLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            appNameLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 8),
            appNameLabel.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -8),
            appNameLabel.centerYAnchor.constraint(equalTo: firstSection.centerYAnchor),
            
            searchButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            searchButton.trailingAnchor.constraint(equalTo: firstSection.trailingAnchor, constant: -16),
            searchButton.centerYAnchor.constraint(equalTo: firstSection.centerYAnchor),
            
            // Second Section Constraints
            secondSection.topAnchor.constraint(equalTo: firstSection.bottomAnchor),
            secondSection.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            secondSection.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            secondSection.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.075),
            
            currentEventsButton.leadingAnchor.constraint(equalTo: secondSection.leadingAnchor),
            currentEventsButton.widthAnchor.constraint(equalTo: secondSection.widthAnchor, multiplier: 1/3),
            currentEventsButton.centerYAnchor.constraint(equalTo: secondSection.centerYAnchor),
            
            rsvpButton.leadingAnchor.constraint(equalTo: currentEventsButton.trailingAnchor),
            rsvpButton.widthAnchor.constraint(equalTo: secondSection.widthAnchor, multiplier: 1/3),
            rsvpButton.centerYAnchor.constraint(equalTo: secondSection.centerYAnchor),
            
            createdByYouButton.leadingAnchor.constraint(equalTo: rsvpButton.trailingAnchor),
            createdByYouButton.trailingAnchor.constraint(equalTo: secondSection.trailingAnchor),
            createdByYouButton.centerYAnchor.constraint(equalTo: secondSection.centerYAnchor),
            
            // Third Section Constraints
            thirdSection.topAnchor.constraint(equalTo: secondSection.bottomAnchor),
            thirdSection.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            thirdSection.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            thirdSection.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.75),
            
            // Fourth Section Constraints
            fourthSection.topAnchor.constraint(equalTo: thirdSection.bottomAnchor),
            fourthSection.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            fourthSection.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            fourthSection.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            iconButton1.leadingAnchor.constraint(equalTo: fourthSection.leadingAnchor),
            iconButton1.widthAnchor.constraint(equalTo: fourthSection.widthAnchor, multiplier: 0.25),
            iconButton1.centerYAnchor.constraint(equalTo: fourthSection.centerYAnchor),
            
            iconButton2.leadingAnchor.constraint(equalTo: iconButton1.trailingAnchor),
            iconButton2.widthAnchor.constraint(equalTo: fourthSection.widthAnchor, multiplier: 0.25),
            iconButton2.centerYAnchor.constraint(equalTo: fourthSection.centerYAnchor),
            
            iconButton3.leadingAnchor.constraint(equalTo: iconButton2.trailingAnchor),
            iconButton3.widthAnchor.constraint(equalTo: fourthSection.widthAnchor, multiplier: 0.25),
            iconButton3.centerYAnchor.constraint(equalTo: fourthSection.centerYAnchor),
            
            iconButton4.leadingAnchor.constraint(equalTo: iconButton3.trailingAnchor),
            iconButton4.trailingAnchor.constraint(equalTo: fourthSection.trailingAnchor),
            iconButton4.centerYAnchor.constraint(equalTo: fourthSection.centerYAnchor)
        ])
    }
}

