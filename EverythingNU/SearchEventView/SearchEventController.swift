import UIKit
import FirebaseFirestore

class SearchEventController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    private let searchBar = UISearchBar()
    private let byNameButton = UIButton()
    private let byTagButton = UIButton()
    private let tableView = UITableView()
    private var allEvents: [Event] = [] // All events from Firestore
    private var filteredEvents: [Event] = [] // Filtered events based on search text
    private var isFilteringByName = true // Toggle between "By Name" and "By Tag"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchAllEvents()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // Setup Search Bar
        searchBar.delegate = self
        searchBar.placeholder = "Search events..."
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        // Setup Buttons
        byNameButton.setTitle("By Name", for: .normal)
        byNameButton.setTitleColor(.white, for: .normal)
        byNameButton.backgroundColor = .systemBlue
        byNameButton.addTarget(self, action: #selector(byNameButtonTapped), for: .touchUpInside)
        byNameButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(byNameButton)
        
        byTagButton.setTitle("By Tag", for: .normal)
        byTagButton.setTitleColor(.black, for: .normal)
        byTagButton.backgroundColor = .lightGray
        byTagButton.addTarget(self, action: #selector(byTagButtonTapped), for: .touchUpInside)
        byTagButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(byTagButton)
        
        // Setup TableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EventCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            byNameButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            byNameButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            byNameButton.widthAnchor.constraint(equalToConstant: 100),
            byNameButton.heightAnchor.constraint(equalToConstant: 40),
            
            byTagButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            byTagButton.leadingAnchor.constraint(equalTo: byNameButton.trailingAnchor, constant: 20),
            byTagButton.widthAnchor.constraint(equalToConstant: 100),
            byTagButton.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: byNameButton.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // MARK: - Button Actions
    @objc private func byNameButtonTapped() {
        isFilteringByName = true
        updateButtonStyles()
        filterEvents(searchText: searchBar.text ?? "")
    }
    
    @objc private func byTagButtonTapped() {
        isFilteringByName = false
        updateButtonStyles()
        filterEvents(searchText: searchBar.text ?? "")
    }
    
    private func updateButtonStyles() {
        if isFilteringByName {
            byNameButton.backgroundColor = .systemBlue
            byNameButton.setTitleColor(.white, for: .normal)
            byTagButton.backgroundColor = .lightGray
            byTagButton.setTitleColor(.black, for: .normal)
        } else {
            byTagButton.backgroundColor = .systemBlue
            byTagButton.setTitleColor(.white, for: .normal)
            byNameButton.backgroundColor = .lightGray
            byNameButton.setTitleColor(.black, for: .normal)
        }
    }
    
    // MARK: - Fetch Events
    private func fetchAllEvents() {
        let db = Firestore.firestore()
        db.collection("events").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching events: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else { return }
            
            self.allEvents = documents.compactMap { document in
                try? document.data(as: Event.self)
            }
            
            // Initially show all events
            // self.filteredEvents = self.allEvents
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Search Bar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterEvents(searchText: searchText)
    }
    
    
    private func filterEvents(searchText: String) {
        if searchText.isEmpty {
            //filteredEvents = allEvents
            self.filteredEvents.removeAll()
            self.tableView.reloadData()
            tableView.reloadData()
            return
        }
        
        if isFilteringByName {
            // Filter by event name
            filteredEvents = allEvents.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            tableView.reloadData()
        } else {
            // Filter by event tags
            self.filteredEvents.removeAll()
            self.tableView.reloadData()
            
            let db = Firestore.firestore()
            let dispatchGroup = DispatchGroup()
            
            for event in allEvents {
                dispatchGroup.enter()
                
                var matchesTag = false
                let tagReferences = event.eventTags // Array of document references
                
                // Resolve all tag references
                for tagRef in tagReferences {
                    tagRef.getDocument { document, error in
                        if let document = document, let tagName = document.data()?["name"] as? String {
                            if tagName.lowercased().contains(searchText.lowercased()) {
                                matchesTag = true
                            }
                        }
                        
                        if tagRef == tagReferences.last { // After resolving all references for this event
                            if matchesTag {
                                self.filteredEvents.append(event)
                                self.tableView.reloadData()
                            }
                            matchesTag = false
                            dispatchGroup.leave()
                        }
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.tableView.reloadData()
            }
        }
    }

    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        let event = filteredEvents[indexPath.row]
        cell.textLabel?.text = event.name
        return cell
    }
    
    // MARK: - TableView Delegate (Optional)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEvent = filteredEvents[indexPath.row]
        print("Selected Event: \(selectedEvent.name)")
        let detailVC = EventDetailViewController()
        detailVC.event = selectedEvent
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

