//
//  PoemExtensions.swift
//  山海诗馆
//
//  诗歌模型转换扩展
//

import Foundation

// MARK: - SquarePoem → Poem

extension SquarePoem {
    /// 转换为本地 Poem 模型（用于 UI 显示）
    func toLocalPoem() -> Poem {
        return Poem(
            id: id,
            title: title,
            content: content,
            authorName: authorUsername,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            tags: tags ?? [],
            inSquare: true,
            squareLikeCount: likeCount,
            isPublished: true
        )
    }
}

// MARK: - RemotePoem → Poem

extension RemotePoem {
    /// 转换为本地 Poem 模型（用于 UI 显示）
    func toLocalPoem(authorName: String = "匿名诗人") -> Poem {
        return Poem(
            id: id,
            title: title,
            content: content,
            authorName: authorName,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            tags: tags ?? [],
            inSquare: isPublic,
            squareLikeCount: likeCount,
            isPublished: isPublic
        )
    }
}

