//
//  PoemImageGenerator.swift
//  山海诗馆
//
//  诗歌分享图片生成器
//

import UIKit
import SwiftUI

struct PoemImageGenerator {
    
    /// 生成诗歌分享图片
    static func generate(poem: Poem) -> UIImage {
        let width: CGFloat = 750  // 2x scale for better quality
        let height: CGFloat = 1334
        
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
            
            // 内容区域
            let contentRect = CGRect(x: 60, y: 200, width: width - 120, height: height - 400)
            
            // 绘制标题
            if !poem.title.isEmpty {
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: "PingFangSC-Semibold", size: 42) ?? UIFont.systemFont(ofSize: 42, weight: .semibold),
                    .foregroundColor: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
                ]
                
                let titleString = NSAttributedString(string: poem.title, attributes: titleAttributes)
                let titleSize = titleString.size()
                let titleRect = CGRect(
                    x: contentRect.minX,
                    y: contentRect.minY,
                    width: contentRect.width,
                    height: titleSize.height
                )
                titleString.draw(in: titleRect)
            }
            
            // 绘制正文
            let contentY = poem.title.isEmpty ? contentRect.minY : contentRect.minY + 80
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 16
            paragraphStyle.alignment = .left
            
            let contentAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "PingFangSC-Regular", size: 32) ?? UIFont.systemFont(ofSize: 32),
                .foregroundColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0),
                .paragraphStyle: paragraphStyle
            ]
            
            let contentString = NSAttributedString(string: poem.content, attributes: contentAttributes)
            let contentDrawRect = CGRect(
                x: contentRect.minX,
                y: contentY,
                width: contentRect.width,
                height: contentRect.height - (contentY - contentRect.minY)
            )
            contentString.draw(in: contentDrawRect)
            
            // 底部信息
            let bottomY = height - 180
            
            // 分隔线
            context.cgContext.setStrokeColor(UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.3).cgColor)
            context.cgContext.setLineWidth(1)
            context.cgContext.move(to: CGPoint(x: 60, y: bottomY))
            context.cgContext.addLine(to: CGPoint(x: width - 60, y: bottomY))
            context.cgContext.strokePath()
            
            // 作者和日期
            let infoAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "PingFangSC-Regular", size: 24) ?? UIFont.systemFont(ofSize: 24),
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
                x: 60,
                y: bottomY + 30,
                width: width - 120,
                height: 40
            )
            infoString.draw(in: infoRect)
            
            // App 标识
            let appNameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "PingFangSC-Medium", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .medium),
                .foregroundColor: UIColor(red: 0.4, green: 0.6, blue: 0.6, alpha: 1.0)
            ]
            
            let appNameString = NSAttributedString(string: "山海诗馆", attributes: appNameAttributes)
            let appNameRect = CGRect(
                x: 60,
                y: bottomY + 80,
                width: width - 120,
                height: 40
            )
            appNameString.draw(in: appNameRect)
        }
        
        return image
    }
}

