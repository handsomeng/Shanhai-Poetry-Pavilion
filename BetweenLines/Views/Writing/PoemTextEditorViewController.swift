//
//  PoemTextEditorViewController.swift
//  山海诗馆
//
//  纯 UIKit 实现的诗歌编辑器
//  参考 iOS 备忘录的实现方式
//

import UIKit
import SwiftUI

/// 纯 UIKit 实现的诗歌编辑器 ViewController
class PoemTextEditorViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 标题回调
    var onTitleChange: ((String) -> Void)?
    /// 内容回调
    var onContentChange: ((String) -> Void)?
    
    private var initialTitle: String
    private var initialContent: String
    private let placeholder: String
    
    // MARK: - UI Components
    
    /// 标题输入框
    private lazy var titleTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "诗歌标题"
        field.font = .systemFont(ofSize: 22, weight: .medium)
        field.textColor = UIColor(red: 0.18, green: 0.16, blue: 0.14, alpha: 1.0) // Colors.textInk
        field.returnKeyType = .next
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    /// 分隔线
    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.88, blue: 0.85, alpha: 1.0) // Colors.divider
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 内容输入框
    private lazy var contentTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 17, weight: .regular)
        textView.textColor = UIColor(red: 0.18, green: 0.16, blue: 0.14, alpha: 1.0)
        textView.backgroundColor = .white
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 20, bottom: 100, right: 20)
        textView.keyboardDismissMode = .interactive
        textView.autocorrectionType = .default
        textView.autocapitalizationType = .sentences
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    /// 占位符 Label
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = placeholder
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(red: 0.18, green: 0.16, blue: 0.14, alpha: 0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    init(title: String, content: String, placeholder: String) {
        self.initialTitle = title
        self.initialContent = content
        self.placeholder = placeholder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupInitialValues()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 添加子视图
        view.addSubview(titleTextField)
        view.addSubview(dividerView)
        view.addSubview(contentTextView)
        contentTextView.addSubview(placeholderLabel)
        
        // 布局约束
        NSLayoutConstraint.activate([
            // 标题
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // 分隔线
            dividerView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 12),
            dividerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dividerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            
            // 内容 TextView
            contentTextView.topAnchor.constraint(equalTo: dividerView.bottomAnchor),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 占位符
            placeholderLabel.topAnchor.constraint(equalTo: contentTextView.topAnchor, constant: 16 + 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor, constant: 20 + 5),
        ])
    }
    
    private func setupInitialValues() {
        titleTextField.text = initialTitle
        contentTextView.text = initialContent
        updatePlaceholderVisibility()
    }
    
    // MARK: - Placeholder
    
    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !contentTextView.text.isEmpty
    }
    
    // MARK: - Public Methods
    
    func updateContent(title: String, content: String) {
        if titleTextField.text != title {
            titleTextField.text = title
        }
        if contentTextView.text != content {
            contentTextView.text = content
            updatePlaceholderVisibility()
        }
    }
}

// MARK: - UITextFieldDelegate

extension PoemTextEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 按回车，跳转到内容编辑
        contentTextView.becomeFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 限制标题最多 30 字
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count <= 30 {
            // 触发回调
            DispatchQueue.main.async { [weak self] in
                self?.onTitleChange?(updatedText)
            }
            return true
        }
        return false
    }
}

// MARK: - UITextViewDelegate

extension PoemTextEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
        
        // 触发回调
        onContentChange?(textView.text)
    }
}

// MARK: - SwiftUI Wrapper

/// SwiftUI 包装器
struct PoemTextEditor: UIViewControllerRepresentable {
    @Binding var title: String
    @Binding var content: String
    let placeholder: String
    
    func makeUIViewController(context: Context) -> PoemTextEditorViewController {
        let vc = PoemTextEditorViewController(
            title: title,
            content: content,
            placeholder: placeholder
        )
        
        // 设置回调
        vc.onTitleChange = { newTitle in
            if title != newTitle {
                title = newTitle
            }
        }
        
        vc.onContentChange = { newContent in
            if content != newContent {
                content = newContent
            }
        }
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PoemTextEditorViewController, context: Context) {
        // 只有外部数据变化时才更新
        uiViewController.updateContent(title: title, content: content)
    }
}

