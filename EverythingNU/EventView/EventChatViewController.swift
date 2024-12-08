//
//  EventChatViewController.swift
//  final
//
//  Created by Sai Kiran Anumalla on 07/12/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class EventChatViewController: UIViewController {
    let chatView = ChatScreenView()
    let db = Firestore.firestore()
    var eventId: String
    var eventName: String
    var messages = [Message]()

    init(eventId: String, eventName: String) {
        self.eventId = eventId
        self.eventName = eventName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = chatView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Event Chat - \(eventName)"
        setupTableView()
        setupActions()
        loadMessages()
    }

    private func setupTableView() {
        chatView.tableViewMessages.delegate = self
        chatView.tableViewMessages.dataSource = self
        chatView.tableViewMessages.register(UITableViewCell.self, forCellReuseIdentifier: "messageCell")
    }

    private func setupActions() {
        chatView.buttonSend.addTarget(self, action: #selector(onSendButtonTapped), for: .touchUpInside)
    }

    @objc func onSendButtonTapped() {
        guard let text = chatView.textFieldMessage.text, !text.isEmpty else {
            alertScreen(title: "Empty Message", message: "Please enter a text")
            return
        }
        sendMessage(text: text)
    }

    private func alertScreen(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func loadMessages() {
        db.collection("events").document(eventId).collection("chatMessages")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error loading messages: \(error.localizedDescription)")
                    return
                }

                self.messages = snapshot?.documents.compactMap { try? $0.data(as: Message.self) } ?? []
                DispatchQueue.main.async {
                    self.chatView.tableViewMessages.reloadData()
                    self.scrollToBottom()
                }
            }
    }

    private func sendMessage(text: String) {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        let senderName = Auth.auth().currentUser?.displayName ?? "Anonymous"

        let messageData: [String: Any] = [
            "content": text,
            "senderId": currentUserId,
            "senderName": senderName,
            "timestamp": Timestamp()
        ]

        db.collection("events").document(eventId).collection("chatMessages").addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.chatView.textFieldMessage.text = ""
                }
            }
        }
    }

    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        chatView.tableViewMessages.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

extension EventChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        let message = messages[indexPath.row]

        // Configure message content
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        let isOutgoing = message.senderId == currentUserId

        // Main message content
        let content = "\(message.senderName): \(message.content)"
        cell.textLabel?.text = content
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textAlignment = isOutgoing ? .right : .left

        // Add timestamp below message
        let timestampLabel = UILabel()
        timestampLabel.font = UIFont.systemFont(ofSize: 12)
        timestampLabel.textColor = .gray
        timestampLabel.text = message.formattedTimestamp
        timestampLabel.textAlignment = isOutgoing ? .right : .left
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add timestamp label to the cell
        cell.contentView.addSubview(timestampLabel)

        NSLayoutConstraint.activate([
            timestampLabel.topAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10),
            timestampLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
            timestampLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10)
        ])

        return cell
    }

}
