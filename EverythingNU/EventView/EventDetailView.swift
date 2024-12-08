//
//  EventDetailView.swift
//  final
//
//  Created by Sai Kiran Anumalla on 06/12/24.
//


import UIKit
import MapKit

class EventDetailView: UIView {

    // UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()

    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let eventChatButton = UIButton()
    let dateTimeLabel = UILabel()
    let locationMap = MKMapView()
    let tagsLabel = UILabel()
    let rsvpLabel = UILabel()
    let imageView = UIImageView()
    let editButton = UIButton(type: .system)
    let deleteButton = UIButton(type: .system)
    let rsvpButton = UIButton()
    let spinner = UIActivityIndicatorView(style: .large)
    let navigateButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        configureMap()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.systemGroupedBackground

        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Name Label
        nameLabel.font = .boldSystemFont(ofSize: 28)
        nameLabel.textColor = UIColor.label
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        // Edit Button
        let editIcon = UIImage(systemName: "pencil.circle")
        editButton.setImage(editIcon, for: .normal)
        editButton.tintColor = UIColor.systemBlue
        editButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(editButton)

        // Delete Button
        let deleteIcon = UIImage(systemName: "trash.circle")
        deleteButton.setImage(deleteIcon, for: .normal)
        deleteButton.tintColor = UIColor.systemRed
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deleteButton)

        // Description Label
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = UIColor.secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        eventChatButton.setTitle("Event Chat", for: .normal)
        eventChatButton.setTitleColor(.white, for: .normal)
        eventChatButton.backgroundColor = .systemBlue
        eventChatButton.layer.cornerRadius = 8
        eventChatButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(eventChatButton)

        // Date and Time Label
        dateTimeLabel.font = .systemFont(ofSize: 14)
        dateTimeLabel.textColor = UIColor.tertiaryLabel
        dateTimeLabel.numberOfLines = 0
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateTimeLabel)

        // RSVP Button
        rsvpButton.setTitle("RSVP", for: .normal)
        rsvpButton.setTitleColor(.white, for: .normal)
        rsvpButton.backgroundColor = UIColor.systemGreen
        rsvpButton.layer.cornerRadius = 8
        rsvpButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rsvpButton)

        // Map View
        locationMap.layer.cornerRadius = 10
        locationMap.layer.borderWidth = 1
        locationMap.layer.borderColor = UIColor.lightGray.cgColor
        locationMap.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(locationMap)

        // Tags Label
        tagsLabel.font = .systemFont(ofSize: 14)
        tagsLabel.textColor = UIColor.secondaryLabel
        tagsLabel.numberOfLines = 0
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagsLabel)

        // RSVP Label
        rsvpLabel.font = .systemFont(ofSize: 14)
        rsvpLabel.textColor = UIColor.secondaryLabel
        rsvpLabel.numberOfLines = 0
        rsvpLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rsvpLabel)

        // Image View
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        // Spinner for Image Loading
        spinner.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(spinner)
        
        navigateButton.setTitle("Navigate to Location", for: .normal)
        navigateButton.setTitleColor(.white, for: .normal)
        navigateButton.backgroundColor = .systemBlue
        navigateButton.layer.cornerRadius = 8
        navigateButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(navigateButton)

    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView Constraints
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Name Label
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Edit Button
            editButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            editButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            editButton.widthAnchor.constraint(equalToConstant: 30),
            editButton.heightAnchor.constraint(equalToConstant: 30),

            // Delete Button
            deleteButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30),

            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            eventChatButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            eventChatButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            eventChatButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            eventChatButton.heightAnchor.constraint(equalToConstant: 40),

            // Date and Time Label
            dateTimeLabel.topAnchor.constraint(equalTo: eventChatButton.bottomAnchor, constant: 20),
            dateTimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // RSVP Button
            rsvpButton.topAnchor.constraint(equalTo: dateTimeLabel.bottomAnchor, constant: 20),
            rsvpButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            rsvpButton.widthAnchor.constraint(equalToConstant: 120),
            rsvpButton.heightAnchor.constraint(equalToConstant: 40),

            // Map View
            locationMap.topAnchor.constraint(equalTo: rsvpButton.bottomAnchor, constant: 20),
            locationMap.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationMap.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            locationMap.heightAnchor.constraint(equalToConstant: 200),
            
            navigateButton.topAnchor.constraint(equalTo: locationMap.bottomAnchor, constant: 20),
            navigateButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            navigateButton.widthAnchor.constraint(equalToConstant: 200),
            navigateButton.heightAnchor.constraint(equalToConstant: 40),


            // Tags Label
            tagsLabel.topAnchor.constraint(equalTo: navigateButton.bottomAnchor, constant: 20),
            tagsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tagsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // RSVP Label
            rsvpLabel.topAnchor.constraint(equalTo: tagsLabel.bottomAnchor, constant: 20),
            rsvpLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            rsvpLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Image View
            imageView.topAnchor.constraint(equalTo: rsvpLabel.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            // Spinner
            spinner.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
        ])
    }

    // Show Spinner while loading image
    func startLoadingImage() {
        spinner.startAnimating()
    }

    // Hide Spinner once image is loaded
    func stopLoadingImage() {
        spinner.stopAnimating()
        spinner.isHidden = true
    }
    
    private func configureMap() {
        locationMap.isZoomEnabled = true
        locationMap.isScrollEnabled = true
        locationMap.isUserInteractionEnabled = true
    }
}
