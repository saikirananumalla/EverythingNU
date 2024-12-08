import UIKit
import FirebaseAuth
import FirebaseFirestore
import MapKit

class HomeViewController: UIViewController {
    
    let homePage = HomeScreen()
    
    let mapView = MKMapView()
    
    let tableView = UITableView()
    
    var currentUser:FirebaseAuth.User?
    
    let locationManager = CLLocationManager()
    
    let db = Firestore.firestore()
    
    var activeEvents = [Event]()
    
    let notificationCenter = NotificationCenter.default
    
    override func loadView() {
        view = homePage
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.hidesBackButton = true
        tableView.prefetchDataSource = self
        
        homePage.currentEventsButton.addTarget(self, action: #selector(onCurrentEventsButtonTapped), for: .touchUpInside)
        homePage.rsvpButton.addTarget(self, action: #selector(onRsvpButtonTapped), for: .touchUpInside)
        homePage.createdByYouButton.addTarget(self, action: #selector(onCreatedByYouButtonTapped), for: .touchUpInside)
        homePage.searchButton.addTarget(self, action: #selector(onSearchButtonTapped), for: .touchUpInside)
        
        homePage.iconButton1.addTarget(self, action: #selector(onHomeButtonTapped), for: .touchUpInside)
        homePage.iconButton2.addTarget(self, action: #selector(onAddButtonTapped), for: .touchUpInside)
        homePage.iconButton3.addTarget(self, action: #selector(onMapButtonTapped), for: .touchUpInside)
        homePage.iconButton4.addTarget(self, action: #selector(onUserInfoButtonTapped), for: .touchUpInside)
        
        
        notificationCenter.addObserver(
            self, selector: #selector(notificationReceivedForAddEvent(notification:)),
            name: .addFromAddEventScreen,
            object: nil)
        
        notificationCenter.addObserver(
            self, selector: #selector(notificationReceivedForEditEvent(notification:)),
            name: .editFromEditScreen,
            object: nil)
        
        notificationCenter.addObserver(
            self, selector: #selector(notificationReceivedForDeleteEvent(notification:)),
            name: .deleteFromDetailScreen,
            object: nil)
        
        populateEvents()

    }
    
    @objc func onButtonCurrentLocationTapped(){
        self.mapView.centerToLocation(location: locationManager.location!)
    }
    
    @objc func onAddButtonTapped() {
        let createEventVC = CreateEventViewController()
        self.navigationController?.pushViewController(createEventVC, animated: true)
    }
    
    @objc func onMapButtonTapped() {
        
        print("In the map view")
        
        homePage.thirdSection.removeFromSuperview()
        //self.mapView.buttonCurrentLocation.addTarget(self, action: #selector(onButtonCurrentLocationTapped), for: .touchUpInside)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layer.cornerRadius = 10
        setupLocationManager()
        onButtonCurrentLocationTapped()
        annotatePlaces()
        self.mapView.delegate = self
        self.homePage.thirdSection = self.mapView
        
        let northeasternCenter = CLLocationCoordinate2D(latitude: 42.3398, longitude: -71.0892)
        let regionSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let northeasternRegion = MKCoordinateRegion(center: northeasternCenter, span: regionSpan)
        mapView.setRegion(northeasternRegion, animated: true)
        
        homePage.setupView()
        homePage.setupConstraints()
        
    }
    
    func annotatePlaces() {
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        print("Annotating now...")
        
        fetchEvents { result in
            switch result {
            case .success(let events):
                for event in events {
                    print("Event present...")
                    let tempLocation = Place(
                        title: event.name,
                        coordinate: CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude),
                        info: event.description
                    )
                    self.mapView.addAnnotation(tempLocation)
                }
            case .failure(let error):
                print("Error fetching events: \(error)")
            }
        }
        
    }
    
    @objc func onUserInfoButtonTapped() {
        
        let userInfoScreen = UserInfoViewController()
        userInfoScreen.currentUser = self.currentUser
        navigationController?.pushViewController(userInfoScreen, animated: true)
        
    }
    
    @objc func onSearchButtonTapped() {
        
        let searchScreen = SearchEventController()
        navigationController?.pushViewController(searchScreen, animated: true)
        
    }
    
    @objc func notificationReceivedForAddEvent(notification: Notification){
        populateEvents()
    }
    
    @objc func notificationReceivedForEditEvent(notification: Notification){
        populateEvents()
    }
    
    @objc func notificationReceivedForDeleteEvent(notification: Notification){
        populateEvents()
    }
    
    func populateEvents() {
        
        fetchEvents { result in
            switch result {
            case .success(let events):
                print("Fetched Events:")
            case .failure(let error):
                print("Error fetching events: \(error)")
            }
        }
        
        self.tableView.register(TableViewEventCell.self, forCellReuseIdentifier: "events")
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        homePage.thirdSection = tableView
    
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = .systemGroupedBackground
        homePage.setupView()
        homePage.setupConstraints()
        
    }
    
    func fetchEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
        let db = Firestore.firestore()
        let eventsRef = db.collection("events")
        
        self.activeEvents.removeAll()
        
        eventsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.success([])) // Return empty array if no documents found
                return
            }
            
            // Convert documents to Event objects
            var events: [Event] = []
            //self.activeEvents.removeAll()
            for document in documents {
                do {
                    let event = try document.data(as: Event.self) // Decodes using Codable
                    events.append(event)
                    print("Adding the event")
                    self.activeEvents.append(event)
                } catch {
                    print("Error decoding event: \(error)")
                    completion(.failure(error))
                    return
                }
            }
            
            self.tableView.reloadData()
            
            completion(.success(events))
        }
    }
    
    
    private func fetchImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: URL(string: url)!), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "events", for: indexPath) as! TableViewEventCell
        let event = activeEvents[indexPath.row]

        cell.eventImageView.image = UIImage(systemName: "photo")
        
        // Populate cell data
        cell.nameLabel.text = event.name
        cell.descriptionLabel.text = event.description
        let tagReferences = event.eventTags
        var tagString = ""
        let dispatchGroup = DispatchGroup()
        for tagRef in tagReferences {
            dispatchGroup.enter()
            tagRef.getDocument { document, error in
                if let document = document, let tagName = document.data()?["name"] as? String {
                    tagString = tagString + " " + tagName.lowercased()
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            cell.tagsLabel.text = "Tags: \(tagString)"
        }
        cell.rsvpLabel.text = "RSVP Count: \(event.rsvpList.count)"

        if let imageURL = event.pictures.first {
            fetchImage(from: imageURL) { image in
                cell.eventImageView.image = image
            }
        } else {
            cell.eventImageView.image = UIImage(systemName: "photo")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEvent = activeEvents[indexPath.row]
        let detailVC = EventDetailViewController()
        detailVC.event = selectedEvent
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

extension MKMapView{
    func centerToLocation(location: CLLocation, radius: CLLocationDistance = 1000){
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        setRegion(coordinateRegion, animated: true)
    }
}

extension HomeViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let event = activeEvents[indexPath.row]
            if let imageURL = event.pictures.first {
                fetchImage(from: imageURL, completion: { _ in })
            }
        }
    }
}


extension HomeViewController {

    @objc func onHomeButtonTapped() {
        fetchEvents { [weak self] result in
            switch result {
            case .success(let events):
                self?.updateTableView(with: events)
                print("Fetched all events.")
            case .failure(let error):
                print("Error fetching all events: \(error)")
            }
        }
    }

    @objc func onCurrentEventsButtonTapped() {
        fetchEvents { [weak self] result in
            switch result {
            case .success(let events):
                let currentDate = Date()
                let activeEvents = events.filter { $0.endTime.dateValue() > currentDate }
                self?.updateTableView(with: activeEvents)
                print("Fetched active events.")
            case .failure(let error):
                print("Error fetching active events: \(error)")
            }
        }
    }

    @objc func onRsvpButtonTapped() {
        guard let userId = currentUser?.uid else { return }
        fetchFilteredEvents(filter: "rsvpByYou", userId: userId) { [weak self] result in
            switch result {
            case .success(let events):
                self?.updateTableView(with: events)
                print("Fetched RSVP events.")
            case .failure(let error):
                print("Error fetching RSVP events: \(error)")
            }
        }
    }

    @objc func onCreatedByYouButtonTapped() {
        guard let userId = currentUser?.uid else { return }
        fetchFilteredEvents(filter: "createdByYou", userId: userId) { [weak self] result in
            switch result {
            case .success(let events):
                self?.updateTableView(with: events)
                print("Fetched created-by-you events.")
            case .failure(let error):
                print("Error fetching created-by-you events: \(error)")
            }
        }
    }

    func fetchFilteredEvents(filter: String, userId: String, completion: @escaping (Result<[Event], Error>) -> Void) {
        var query: Query

        switch filter {
        case "createdByYou":
            query = db.collection("events").whereField("createdBy", isEqualTo: db.collection("users").document(userId))
        case "rsvpByYou":
            query = db.collection("events").whereField("rsvpList", arrayContains: db.collection("users").document(userId))
        default:
            completion(.success([])) // Return empty result for unsupported filters
            return
        }

        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let documents = querySnapshot?.documents else {
                completion(.success([])) // No documents found
                return
            }

            let events = documents.compactMap { try? $0.data(as: Event.self) }
            completion(.success(events))
        }
    }


    private func updateTableView(with events: [Event]) {
        DispatchQueue.main.async {
            self.activeEvents = events
            self.tableView.register(TableViewEventCell.self, forCellReuseIdentifier: "events")
            self.tableView.translatesAutoresizingMaskIntoConstraints = false
            self.homePage.thirdSection = self.tableView
        
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.separatorStyle = .none
            self.tableView.backgroundColor = .systemGroupedBackground
            self.homePage.setupView()
            self.homePage.setupConstraints()
            self.tableView.reloadData()
        }
    }
}

