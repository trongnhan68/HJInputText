//
//  ValidationTextfield.swift
//  ValidationTextField
//
//  Created by Nhan Nguyen Le Trong on 10/28/19.
//  Copyright © 2019 Nhan Nguyen Le Trong. All rights reserved.
//

import UIKit

public class NibView: UIView {
    var view: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
}

private extension NibView {
    
    func xibSetup() {
        backgroundColor = UIColor.clear
        view = loadNib()
        view.backgroundColor = .clear
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
    }
}

extension UIView {
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}

public enum ValidationTextFieldState: Int {
    case normal = 0
    case normalActive
    case valid
    case error
}

public enum HJInputTextValidation {
    
    case valid(String?) // action title
    case invalid(String?, String?) // (error message, action title)
    
    var errorMessage: String? {
        switch self {
        case .invalid(let errorMessage, _):
            return errorMessage
        default:
            return nil
        }
    }
    
    var actionButtonTitle: String? {
        switch self {
        case .invalid(_, let actionButtonTitle):
            return actionButtonTitle
        default:
            return nil
        }
    }

}

public struct HJInputTextProperty {
    
    // top label
    public var titleLabelTitle: String? = nil
    public var titleLabelTextColorNormal: UIColor = .black
    public var titleLabelTextColorActive: UIColor = .blue
    public var titleLabelTextColorError: UIColor = .red
    public var titleLabelFont: UIFont = .systemFont(ofSize: 10)
    
    // textfield
    public var placeholderText: String = "Enter text here"
    public var placeholderColor: UIColor = .black
    public var placeholderFont: UIFont = .systemFont(ofSize: 12)
    
    // hint label
    public var hintLabelColor: UIColor = .black
    public var hintLabelFont: UIFont = .systemFont(ofSize: 10)
    
    // error label
    public var errorLabelColor: UIColor = .red
    public var errorLabelFont: UIFont = .systemFont(ofSize: 10)
    
    // textfield
    public var textfieldTextColorNormal: UIColor = .black
    public var textfieldTextColorActive: UIColor = .blue
    public var textfieldTextColorError: UIColor = .red
    public var textfieldTextFont: UIFont = .systemFont(ofSize: 12)
    
    // right status imageview
    public var rightValidIcon: UIImage? = nil
    public var rightInvalidIcon: UIImage? = nil
    
    // action button
    public var actionButtonTitle: String?
    public var actionButtonTitleColor: UIColor = .blue
    public var actionButtonFont: UIFont = .systemFont(ofSize: 12)
    
    // left view
    public var leftSubview: UIView = UILabel()
    
    // padding
    public var commonPadding: CGFloat = 10.0
    
    public var borderWidth: CGFloat = 1
    public var cornerRadius: CGFloat = 10
    public var borderColorNormal: UIColor = .clear
    public var borderColorActive: UIColor = .blue
    public var borderColorError: UIColor = .red
    
    public var backgroundColor: UIColor = .clear
    public var mainContentColor: UIColor = .white
    
    public init() {}
}

public protocol HJInputTextProtocol: class {
    func actionButtonDidTap()
    func textDidChanged(_ text: String?)
    func validateText(_ text: String?) -> HJInputTextValidation
}

final public class HJInputText: NibView {
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var textfield: HJTextfield!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topStackView: UIStackView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var contentStackView: UIStackView!
    
    @IBOutlet weak var bottomLabelStackView: UIStackView!
    public weak var delegate: HJInputTextProtocol?
    
    private var property = HJInputTextProperty()
    
    /// The value of the title appearing duration
    @objc dynamic var titleFadeInDuration: TimeInterval = 0.2
    /// The value of the title disappearing duration
    @objc dynamic var titleFadeOutDuration: TimeInterval = 0.3
    
    private var _errorMessage: String?
    private var _actionButtonTitle: String?
    private var _hintText: String?
    
    public func setProperty(_ property: HJInputTextProperty) {
        self.property = property
        updateProperty()
        updateControl()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public func setText(_ text: String?) {
        textfield.text = text
    }
    
    public func dismissKeyboard() {
        textfield.resignFirstResponder()
        updateControl()
    }
    
    public func focusKeyboard() {
        textfield.becomeFirstResponder()
        updateControl()
    }
    
    public func reset() {
        dismissKeyboard()
        setText(nil)
        errorMessage = nil
        updateControl()
    }
    
    public var text: String? {
        return textfield.text
    }
    
    func updateProperty() {
        backgroundColor = property.backgroundColor
        titleLabel.backgroundColor = .clear
        textfield.backgroundColor = .clear
        errorLabel.backgroundColor = .clear
        hintLabel.backgroundColor = .clear
        
        topView.layer.masksToBounds = true
        topView.backgroundColor = property.mainContentColor
        topView.layer.borderWidth = property.borderWidth
        topView.layer.cornerRadius = property.cornerRadius
        topView.layer.borderColor = property.borderColorNormal.cgColor
        
        textfield.borderStyle = .none
        textfield.attributedPlaceholder = NSAttributedString(string: property.placeholderText,
                                                             attributes: [NSAttributedString.Key.foregroundColor: property.placeholderColor, NSAttributedString.Key.font: property.placeholderFont])
        textfield.font = property.textfieldTextFont
        textfield.textColor = property.textfieldTextColorNormal
        
        titleLabel.text = property.titleLabelTitle
        titleLabel.isHidden = true
        titleLabel.font = property.titleLabelFont
        
        hintLabel.isHidden = true
        hintLabel.font = property.hintLabelFont
        
        errorLabel.isHidden = true
        errorLabel.font = property.errorLabelFont
        
        statusButton.isHidden = true
        statusButton.isUserInteractionEnabled = false
        statusButton.setImage(nil, for: .normal)
        
        actionButton.setTitleColor(property.actionButtonTitleColor, for: .normal)
        actionButton.titleLabel?.font = property.actionButtonFont
        actionButton.isHidden = true
        
        bottomStackView.isHidden = true
        if property.leftSubview.superview == nil {
            leftView.addSubview(property.leftSubview)
        }
        property.leftSubview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            property.leftSubview.widthAnchor.constraint(equalTo: leftView.widthAnchor),
            property.leftSubview.heightAnchor.constraint(equalTo: leftView.heightAnchor),
            property.leftSubview.centerXAnchor.constraint(equalTo: leftView.centerXAnchor),
            property.leftSubview.centerYAnchor.constraint(equalTo: leftView.centerYAnchor),
            ])
    }
    
    func setup() {
        textfield.addTarget(self, action: #selector(textDidChanged), for: .editingChanged)
        textfield.customDelegate = self
        textfield.delegate = self
        actionButton.addTarget(self, action: #selector(actionButtonDidTap), for: .touchUpInside)
        
        updateProperty()
        updateControl()
    }
    
    private func updateControl(animated: Bool = false) {
        updateTitleLabel(animated: true)
        updateStatusButton()
        updateCorner()
        updateErrorLabel()
        updateHintLabel()
        updateActionButton()
        updateBottomView()
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    fileprivate func updateActionButton() {
        actionButton.isHidden = !hasActionButton
    }
    
    fileprivate func updateBottomView() {
        bottomStackView.isHidden = actionButton.isHidden && errorLabel.isHidden && hintLabel.isHidden
    }
    
    fileprivate func updateErrorLabel() {
        errorLabel.textColor = property.errorLabelColor
        errorLabel.text = _errorMessage
        
        if state == .error && hasErrorMessage {
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
    }
    
    fileprivate func updateHintLabel() {
        if errorLabel.isHidden == false {
            hintLabel.isHidden = true
            return
        }
        hintLabel.textColor = property.hintLabelColor
        hintLabel.text = _hintText
        hintLabel.isHidden = String.isNilOrEmpty(_hintText)
    }
    
    fileprivate func updateCorner(animated: Bool = false) {
        switch state {
        case .normal:
            topView.layer.borderColor = property.borderColorNormal.cgColor
        case .normalActive:
            topView.layer.borderColor = property.borderColorActive.cgColor
        case .valid:
            topView.layer.borderColor = property.borderColorActive.cgColor
        case .error:
            topView.layer.borderColor = property.borderColorError.cgColor
        }
    }
    
    fileprivate func updateTitleLabel(animated: Bool = false) {
        switch state {
        case .normal:
            titleLabel.textColor = property.titleLabelTextColorNormal
        case .normalActive:
            titleLabel.textColor = property.titleLabelTextColorActive
        case .valid:
            titleLabel.textColor = property.titleLabelTextColorActive
        case .error:
            titleLabel.textColor = property.titleLabelTextColorError
        }
        titleLabel.text = property.titleLabelTitle
        updateTitleVisibility(animated)
    }
    
    fileprivate func updateStatusButton() {
        switch state {
        case .normal, .normalActive:
            statusButton.isHidden = true
        case .valid, .error:
            statusButton.isHidden = false
        }
    }
    
    fileprivate func updateTitleVisibility(_ animated: Bool = false, completion: ((_ completed: Bool) -> Void)? = nil) {
        if isTitleVisible {
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }
    }
    
    public var isTitleVisible: Bool {
        var hasText = false
        if let text = textfield.text {
            hasText = !text.isEmpty
        }
        if editingOrSelected && hasText {
            return true
        }
        return false
    }
    
    /// A Boolean value that determines whether the textfield is being edited or is selected.
    public var editingOrSelected: Bool {
        return textfield.editingOrSelected
    }
    
    /// A Boolean value that determines whether the receiver has an error message.
    public var hasErrorMessage: Bool {
        return _errorMessage != nil && _errorMessage != ""
    }
    
    public var hasActionButton: Bool {
        guard let actionButtonTitle = _actionButtonTitle else { return false }
        return !actionButtonTitle.isEmpty
    }
    
    public var actionButtonTitle: String? {
        set {
            _actionButtonTitle = newValue
            actionButton.setTitle(_actionButtonTitle, for: .normal)
        }
        get {
            return _actionButtonTitle
        }
    }
    
    public var errorMessage: String? {
        set {
            _errorMessage = newValue
        }
        get {
            return _errorMessage
        }
    }
    
    public var hintText: String? {
        set {
            _hintText = newValue
        }
        get {
            return _hintText
        }
    }
    
    public var isValidText: Bool = false {
        didSet {
            statusButton.setImage(isValidText ? property.rightValidIcon : property.rightInvalidIcon, for: .normal)
        }
    }
    
    public var state: ValidationTextFieldState {
        get {
            if textfield.text == nil || (textfield.text ?? "").isEmpty {
                if editingOrSelected {
                    return .normalActive
                } else {
                    return .normal
                }
            } else if isValidText {
                return .valid
            } else {
                return .error
            }
        }
    }
    
    fileprivate var _renderingInInterfaceBuilder: Bool = false
    
    // MARK: Responder handling
    /**
     Attempt the control to become the first responder
     - returns: True when successfull becoming the first responder
     */
    @discardableResult
    override public func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        updateControl(animated: true)
        return result
    }
    
    /**
     Attempt the control to resign being the first responder
     - returns: True when successfull resigning being the first responder
     */
    @discardableResult
    override public func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        updateControl(animated: true)
        return result
    }
    
    @objc
    public func actionButtonDidTap() {
        delegate?.actionButtonDidTap()
    }
}

extension HJInputText: HJTextfieldProtocol, UITextFieldDelegate {
    
    func becomeFirstResponde() {
        updateControl(animated: true)
    }
    
    func resignFirstResponder() {
        updateControl(animated: true)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textDidChanged() {
        if let delegate = delegate {
            let validation = delegate.validateText(textfield.text)
            switch validation {
            case .valid(let _actionButtonTitle):
                isValidText = true
                errorMessage = nil
                actionButtonTitle = _actionButtonTitle
            case .invalid(let _errorMessage, let _actionButtonTitle):
                isValidText = false
                errorMessage = _errorMessage
                actionButtonTitle = _actionButtonTitle
            }
        } else {
            isValidText = true
            errorMessage = nil
            actionButtonTitle = nil
        }
        updateControl()
        delegate?.textDidChanged(textfield.text)
    }
}

private extension String {
    static func isNilOrEmpty(_ text: String?) -> Bool {
        if let text = text, text.isEmpty == false {
            return false
        }
        return true
    }
}
