import UIKit

class ChatScreenView: UIView {
    
    var tableViewMessages: UITableView!
    var textFieldMessage: UITextField!
    var buttonSend: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupTableView()
        setupMessageInputArea()
    }
    
    func setupTableView() {
        tableViewMessages = UITableView()
        tableViewMessages.translatesAutoresizingMaskIntoConstraints = false
        tableViewMessages.separatorStyle = .none
        tableViewMessages.allowsSelection = false
        self.addSubview(tableViewMessages)
        
        NSLayoutConstraint.activate([
            tableViewMessages.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            tableViewMessages.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableViewMessages.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableViewMessages.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -70)
        ])
    }
    
    func setupMessageInputArea() {
        let inputAreaView = UIView()
        inputAreaView.translatesAutoresizingMaskIntoConstraints = false
        inputAreaView.backgroundColor = UIColor.systemGray6
        self.addSubview(inputAreaView)
        
        textFieldMessage = UITextField()
        textFieldMessage.placeholder = "Enter message"
        textFieldMessage.borderStyle = .roundedRect
        textFieldMessage.translatesAutoresizingMaskIntoConstraints = false
        inputAreaView.addSubview(textFieldMessage)
        
        buttonSend = UIButton(type: .system)
        buttonSend.setTitle("Send", for: .normal)
        buttonSend.translatesAutoresizingMaskIntoConstraints = false
        inputAreaView.addSubview(buttonSend)
        
        NSLayoutConstraint.activate([
            inputAreaView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            inputAreaView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            inputAreaView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            inputAreaView.heightAnchor.constraint(equalToConstant: 60),
            
            textFieldMessage.leadingAnchor.constraint(equalTo: inputAreaView.leadingAnchor, constant: 10),
            textFieldMessage.centerYAnchor.constraint(equalTo: inputAreaView.centerYAnchor),
            textFieldMessage.heightAnchor.constraint(equalToConstant: 40),
            
            buttonSend.leadingAnchor.constraint(equalTo: textFieldMessage.trailingAnchor, constant: 10),
            buttonSend.trailingAnchor.constraint(equalTo: inputAreaView.trailingAnchor, constant: -10),
            buttonSend.centerYAnchor.constraint(equalTo: inputAreaView.centerYAnchor),
            buttonSend.widthAnchor.constraint(equalToConstant: 60),
            
            textFieldMessage.trailingAnchor.constraint(equalTo: buttonSend.leadingAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
