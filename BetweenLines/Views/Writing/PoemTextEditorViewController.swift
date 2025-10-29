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
    /// 显示会员页面回调
    var onShowMembership: (() -> Void)?
    
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
    
    /// AI 灵感按钮（悬浮在右下角）
    private lazy var inspirationButton: UIButton = {
        let button = UIButton(type: .system)
        
        // 使用 SF Symbol
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let image = UIImage(systemName: "lightbulb", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(red: 0.38, green: 0.62, blue: 0.62, alpha: 1.0) // Colors.accentTeal
        
        // 白色背景 + 线条
        button.backgroundColor = .white
        button.layer.cornerRadius = 24
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(red: 0.9, green: 0.88, blue: 0.85, alpha: 1.0).cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.08
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(inspirationButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    /// 加载指示器（在按钮内）
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = UIColor(red: 0.38, green: 0.62, blue: 0.62, alpha: 1.0) // Colors.accentTeal
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - SubscriptionManager
    
    private var subscriptionManager = SubscriptionManager.shared
    
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
        view.addSubview(inspirationButton)
        inspirationButton.addSubview(loadingIndicator)
        
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
            
            // AI 灵感按钮（悬浮在右下角）
            inspirationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            inspirationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            inspirationButton.widthAnchor.constraint(equalToConstant: 48),
            inspirationButton.heightAnchor.constraint(equalToConstant: 48),
            
            // 加载指示器（居中在按钮内）
            loadingIndicator.centerXAnchor.constraint(equalTo: inspirationButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: inspirationButton.centerYAnchor),
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
    
    // MARK: - AI Inspiration
    
    @objc private func inspirationButtonTapped() {
        // 触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // 检查是否可以使用
        if !subscriptionManager.canUseInspiration() {
            showLimitReachedAlert()
            return
        }
        
        // 先弹窗确认
        showConfirmationAlert()
    }
    
    private func showLimitReachedAlert() {
        let alert = UIAlertController(
            title: "今日次数已用完",
            message: "免费用户每天可使用 2 次 AI 续写灵感\n\n升级会员即可无限使用 ✨",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "升级会员", style: .default) { [weak self] _ in
            // TODO: 打开订阅页面
            self?.showUpgradeHint()
        })
        
        present(alert, animated: true)
    }
    
    private func showUpgradeHint() {
        // 直接弹出会员付费页面
        onShowMembership?()
    }
    
    private func showConfirmationAlert() {
        let alert = UIAlertController(
            title: "💡 寻求灵感",
            message: "让 AI 帮你打开思路？",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "好的", style: .default) { [weak self] _ in
            self?.requestInspiration()
        })
        
        present(alert, animated: true)
    }
    
    private func requestInspiration() {
        // 开始加载
        setInspirationButtonLoading(true)
        
        // 异步调用 AI
        Task { @MainActor in
            do {
                let inspiration = try await AIService.shared.getWritingInspiration(
                    currentContent: contentTextView.text ?? "",
                    title: titleTextField.text ?? ""
                )
                
                // 使用一次额度
                subscriptionManager.useInspiration()
                
                // 停止加载
                setInspirationButtonLoading(false)
                
                // 展示灵感
                showInspirationAlert(inspiration: inspiration)
                
            } catch {
                // 停止加载
                setInspirationButtonLoading(false)
                
                // 展示错误
                showErrorAlert(error: error)
            }
        }
    }
    
    private func setInspirationButtonLoading(_ loading: Bool) {
        if loading {
            inspirationButton.setImage(nil, for: .normal)
            loadingIndicator.startAnimating()
            inspirationButton.isEnabled = false
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            let image = UIImage(systemName: "lightbulb", withConfiguration: config)
            inspirationButton.setImage(image, for: .normal)
            loadingIndicator.stopAnimating()
            inspirationButton.isEnabled = true
        }
    }
    
    private func showInspirationAlert(inspiration: String) {
        let alert = UIAlertController(
            title: "✨ 创作灵感",
            message: inspiration,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "获取灵感失败",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        
        present(alert, animated: true)
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
    var onShowMembership: (() -> Void)? // 显示会员页面回调
    
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
        
        vc.onShowMembership = onShowMembership
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PoemTextEditorViewController, context: Context) {
        // 只有外部数据变化时才更新
        uiViewController.updateContent(title: title, content: content)
    }
}

