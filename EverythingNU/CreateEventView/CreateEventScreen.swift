import UIKit
import FirebaseFirestore

class CreateEventScreen: UIView {

    var scrollView: UIScrollView!
    var contentView: UIView!

    var textFieldName: UITextField!
    var textViewDescription: UITextView!
    var labelStartTime: UILabel!
    var datePickerStartTime: UIDatePicker!
    var labelEndTime: UILabel!
    var datePickerEndTime: UIDatePicker!
    var buttonAddImage: UIButton!
    var imageViewSelected: UIImageView!
    var buttonSelectLocation: UIButton!
    var labelSelectedLocation: UILabel!
    var buttonSubmit: UIButton!
    var selectedLocation: GeoPoint?
    var textFieldTags: UITextField!
    var collectionViewTags: UICollectionView!
    var selectedTags = [String]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        self.backgroundColor = UIColor.systemGroupedBackground

        // Create and add UIScrollView
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView)

        // Create and add contentView
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Event Name Field
        textFieldName = UITextField()
        textFieldName.placeholder = "Enter event name"
        textFieldName.borderStyle = .roundedRect
        textFieldName.layer.borderWidth = 1
        textFieldName.layer.borderColor = UIColor.lightGray.cgColor
        textFieldName.layer.cornerRadius = 8
        textFieldName.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textFieldName)

        // Description Field
        textViewDescription = UITextView()
        textViewDescription.layer.borderWidth = 1.0
        textViewDescription.layer.borderColor = UIColor.lightGray.cgColor
        textViewDescription.layer.cornerRadius = 8.0
        textViewDescription.text = "Enter event description here..."
        textViewDescription.textColor = UIColor.lightGray
        textViewDescription.font = UIFont.systemFont(ofSize: 14)
        textViewDescription.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textViewDescription)

        // Start Time Label
        labelStartTime = UILabel()
        labelStartTime.text = "Start Time"
        labelStartTime.font = UIFont.boldSystemFont(ofSize: 16)
        labelStartTime.textColor = .darkGray
        labelStartTime.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelStartTime)

        // Start Time Picker
        datePickerStartTime = UIDatePicker()
        datePickerStartTime.datePickerMode = .dateAndTime
        datePickerStartTime.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(datePickerStartTime)

        // End Time Label
        labelEndTime = UILabel()
        labelEndTime.text = "End Time"
        labelEndTime.font = UIFont.boldSystemFont(ofSize: 16)
        labelEndTime.textColor = .darkGray
        labelEndTime.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelEndTime)

        // End Time Picker
        datePickerEndTime = UIDatePicker()
        datePickerEndTime.datePickerMode = .dateAndTime
        datePickerEndTime.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(datePickerEndTime)

        // Add Image Button
        buttonAddImage = UIButton(type: .system)
        buttonAddImage.setTitle("Add Image", for: .normal)
        buttonAddImage.setTitleColor(.white, for: .normal)
        buttonAddImage.backgroundColor = UIColor.systemBlue
        buttonAddImage.layer.cornerRadius = 8
        buttonAddImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonAddImage)

        // Selected Image Preview
        imageViewSelected = UIImageView()
        imageViewSelected.contentMode = .scaleAspectFill
        imageViewSelected.clipsToBounds = true
        imageViewSelected.layer.cornerRadius = 8
        imageViewSelected.layer.borderWidth = 1.0
        imageViewSelected.layer.borderColor = UIColor.lightGray.cgColor
        imageViewSelected.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageViewSelected)

        // Select Location Button
        buttonSelectLocation = UIButton(type: .system)
        buttonSelectLocation.setTitle("Select Location", for: .normal)
        buttonSelectLocation.setTitleColor(.white, for: .normal)
        buttonSelectLocation.backgroundColor = UIColor.systemBlue
        buttonSelectLocation.layer.cornerRadius = 8
        buttonSelectLocation.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonSelectLocation)

        // Selected Location Label
        labelSelectedLocation = UILabel()
        labelSelectedLocation.text = "No location selected"
        labelSelectedLocation.textAlignment = .center
        labelSelectedLocation.textColor = .darkGray
        labelSelectedLocation.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelSelectedLocation)

        // Tags Input Field
        textFieldTags = UITextField()
        textFieldTags.placeholder = "Enter a tag and press Enter"
        textFieldTags.borderStyle = .roundedRect
        textFieldTags.layer.cornerRadius = 8
        textFieldTags.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textFieldTags)

        // Tags Collection View
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionViewTags = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionViewTags.backgroundColor = .white
        collectionViewTags.layer.cornerRadius = 8
        collectionViewTags.layer.borderWidth = 1.0
        collectionViewTags.layer.borderColor = UIColor.lightGray.cgColor
        collectionViewTags.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionViewTags)

        // Submit Button
        buttonSubmit = UIButton(type: .system)
        buttonSubmit.setTitle("Save Event", for: .normal)
        buttonSubmit.setTitleColor(.white, for: .normal)
        buttonSubmit.backgroundColor = UIColor.systemGreen
        buttonSubmit.layer.cornerRadius = 8
        buttonSubmit.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonSubmit)

        setupConstraints()
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView Constraints
            scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            // ContentView Constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Event Name Field
            textFieldName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            textFieldName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textFieldName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Description Field
            textViewDescription.topAnchor.constraint(equalTo: textFieldName.bottomAnchor, constant: 20),
            textViewDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textViewDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textViewDescription.heightAnchor.constraint(equalToConstant: 100),

            // Start Time Label
            labelStartTime.topAnchor.constraint(equalTo: textViewDescription.bottomAnchor, constant: 20),
            labelStartTime.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            // Start Time Picker
            datePickerStartTime.topAnchor.constraint(equalTo: labelStartTime.bottomAnchor, constant: 5),
            datePickerStartTime.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            datePickerStartTime.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // End Time Label
            labelEndTime.topAnchor.constraint(equalTo: datePickerStartTime.bottomAnchor, constant: 20),
            labelEndTime.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            // End Time Picker
            datePickerEndTime.topAnchor.constraint(equalTo: labelEndTime.bottomAnchor, constant: 5),
            datePickerEndTime.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            datePickerEndTime.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Add Image Button
            buttonAddImage.topAnchor.constraint(equalTo: datePickerEndTime.bottomAnchor, constant: 20),
            buttonAddImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            buttonAddImage.widthAnchor.constraint(equalToConstant: 150),
            buttonAddImage.heightAnchor.constraint(equalToConstant: 40),

            // Selected Image Preview
            imageViewSelected.topAnchor.constraint(equalTo: buttonAddImage.bottomAnchor, constant: 20),
            imageViewSelected.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageViewSelected.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageViewSelected.heightAnchor.constraint(equalToConstant: 200),

            // Location Label
            labelSelectedLocation.topAnchor.constraint(equalTo: imageViewSelected.bottomAnchor, constant: 20),
            labelSelectedLocation.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            labelSelectedLocation.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Select Location Button
            buttonSelectLocation.topAnchor.constraint(equalTo: labelSelectedLocation.bottomAnchor, constant: 10),
            buttonSelectLocation.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            buttonSelectLocation.widthAnchor.constraint(equalToConstant: 150),
            buttonSelectLocation.heightAnchor.constraint(equalToConstant: 40),

            // Tags Field
            textFieldTags.topAnchor.constraint(equalTo: buttonSelectLocation.bottomAnchor, constant: 20),
            textFieldTags.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textFieldTags.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Tags Collection View
            collectionViewTags.topAnchor.constraint(equalTo: textFieldTags.bottomAnchor, constant: 10),
            collectionViewTags.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            collectionViewTags.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            collectionViewTags.heightAnchor.constraint(equalToConstant: 50),

            // Submit Button
            buttonSubmit.topAnchor.constraint(equalTo: collectionViewTags.bottomAnchor, constant: 20),
            buttonSubmit.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            buttonSubmit.widthAnchor.constraint(equalToConstant: 150),
            buttonSubmit.heightAnchor.constraint(equalToConstant: 40),
            buttonSubmit.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}
