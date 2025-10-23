//
//  PoemImageGenerator.swift
//  山海诗馆
//
//  诗歌分享图片生成器（智能调整高度）
//

import UIKit
import SwiftUI

struct PoemImageGenerator {
    
    /// 生成诗歌分享图片（根据内容自动调整高度）
    static func generate(poem: Poem) -> UIImage {
        let width: CGFloat = 750  // 固定宽度
        
        // 边距和间距常量
        let horizontalPadding: CGFloat = 60
        let topPadding: CGFloat = 200
        let bottomPadding: CGFloat = 200
        let titleBottomSpacing: CGFloat = 80
        let contentWidth = width - horizontalPadding * 2
        
        // 字体和样式
        let titleFont = UIFont(name: "PingFangSC-Semibold", size: 42) ?? UIFont.systemFont(ofSize: 42, weight: .semibold)
        let contentFont = UIFont(name: "PingFangSC-Regular", size: 32) ?? UIFont.systemFont(ofSize: 32)
        let infoFont = UIFont(name: "PingFangSC-Regular", size: 24) ?? UIFont.systemFont(ofSize: 24)
        let appNameFont = UIFont(name: "PingFangSC-Medium", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .medium)
        
        // 段落样式
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 16
        paragraphStyle.alignment = .left
        
        // 计算标题高度
        var titleHeight: CGFloat = 0
        if !poem.title.isEmpty {
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
            ]
            let titleString = NSAttributedString(string: poem.title, attributes: titleAttributes)
            let titleSize = titleString.boundingRect(
                with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            ).size
            titleHeight = ceil(titleSize.height)
        }
        
        // 计算内容高度
        let contentAttributes: [NSAttributedString.Key: Any] = [
            .font: contentFont,
            .foregroundColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0),
            .paragraphStyle: paragraphStyle
        ]
        let contentString = NSAttributedString(string: poem.content, attributes: contentAttributes)
        let contentSize = contentString.boundingRect(
            with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        let contentHeight = ceil(contentSize.height)
        
        // 计算总高度
        let totalHeight = topPadding 
            + titleHeight 
            + (titleHeight > 0 ? titleBottomSpacing : 0)
            + contentHeight 
            + bottomPadding
        
        // 确保最小高度（至少和iPhone屏幕一样长）
        let height = max(totalHeight, 1334)
        
        print("📐 [PoemImageGenerator] 图片尺寸计算：")
        print("   标题高度: \(titleHeight)")
        print("   内容高度: \(contentHeight)")
        print("   总高度: \(height)")
        
        // 开始绘制
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        
        let image = renderer.image { context in
            // 背景渐变
            let gradient = CAGradientLayer()
            gradient.frame = CGRect(x: 0, y: 0, width: width, height: height)
            gradient.colors = [
                UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1.0).cgColor,
                UIColor(red: 0.95, green: 0.94, blue: 0.92, alpha: 1.0).cgColor
            ]
            gradient.locations = [0.0, 1.0]
            gradient.render(in: context.cgContext)
            
            var currentY: CGFloat = topPadding
            
            // 绘制标题
            if !poem.title.isEmpty {
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: titleFont,
                    .foregroundColor: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
                ]
                
                let titleString = NSAttributedString(string: poem.title, attributes: titleAttributes)
                let titleRect = CGRect(
                    x: horizontalPadding,
                    y: currentY,
                    width: contentWidth,
                    height: titleHeight
                )
                titleString.draw(in: titleRect)
                currentY += titleHeight + titleBottomSpacing
            }
            
            // 绘制正文
            let contentRect = CGRect(
                x: horizontalPadding,
                y: currentY,
                width: contentWidth,
                height: contentHeight
            )
            contentString.draw(in: contentRect)
            currentY += contentHeight + 60
            
            // 底部信息
            let bottomY = currentY
            
            // 分隔线
            context.cgContext.setStrokeColor(UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.3).cgColor)
            context.cgContext.setLineWidth(1)
            context.cgContext.move(to: CGPoint(x: horizontalPadding, y: bottomY))
            context.cgContext.addLine(to: CGPoint(x: width - horizontalPadding, y: bottomY))
            context.cgContext.strokePath()
            
            // 作者和日期
            let infoAttributes: [NSAttributedString.Key: Any] = [
                .font: infoFont,
                .foregroundColor: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            ]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            let dateString = dateFormatter.string(from: poem.createdAt)
            
            let infoString = NSAttributedString(
                string: "\(poem.authorName) · \(dateString)",
                attributes: infoAttributes
            )
            
            let infoRect = CGRect(
                x: horizontalPadding,
                y: bottomY + 30,
                width: contentWidth,
                height: 40
            )
            infoString.draw(in: infoRect)
            
            // App 标识
            let appNameAttributes: [NSAttributedString.Key: Any] = [
                .font: appNameFont,
                .foregroundColor: UIColor(red: 0.4, green: 0.6, blue: 0.6, alpha: 1.0)
            ]
            
            let appNameString = NSAttributedString(string: "山海诗馆", attributes: appNameAttributes)
            let appNameRect = CGRect(
                x: horizontalPadding,
                y: bottomY + 80,
                width: contentWidth,
                height: 40
            )
            appNameString.draw(in: appNameRect)
        }
        
        return image
    }
}

