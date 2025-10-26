//
//  PoemActionsMenu.swift
//  山海诗馆
//
//  诗歌操作菜单：分享、编辑、复制、删除
//  从右上角 ⋯ 按钮弹出的下拉菜单
//

import SwiftUI

struct PoemActionsMenu: View {
    
    let onShare: () -> Void
    let onEdit: () -> Void
    let onCopy: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 分享
            MenuItem(
                icon: "square.and.arrow.up",
                title: "分享",
                action: onShare
            )
            
            Divider()
                .background(Colors.divider)
            
            // 编辑
            MenuItem(
                icon: "pencil",
                title: "编辑",
                action: onEdit
            )
            
            Divider()
                .background(Colors.divider)
            
            // 复制
            MenuItem(
                icon: "doc.on.doc",
                title: "复制",
                action: onCopy
            )
            
            Divider()
                .background(Colors.divider)
            
            // 删除（红色）
            MenuItem(
                icon: "trash",
                title: "删除",
                color: .red,
                action: onDelete
            )
        }
        .frame(width: 160)
        .background(Colors.white)
        .cornerRadius(CornerRadius.medium)
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Menu Item

struct MenuItem: View {
    
    let icon: String
    let title: String
    var color: Color = Colors.textInk
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(color)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(color)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isPressed ? Colors.backgroundCream : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Colors.backgroundCream
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            HStack {
                Spacer()
                PoemActionsMenu(
                    onShare: { print("分享") },
                    onEdit: { print("编辑") },
                    onCopy: { print("复制") },
                    onDelete: { print("删除") }
                )
                .padding(.trailing, 16)
            }
            .padding(.top, 60)
            Spacer()
        }
    }
}

