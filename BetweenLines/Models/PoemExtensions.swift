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
            style: style,
            tags: tags ?? [],
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            isPublic: true,
            squareLikeCount: likeCount,
            squareCommentCount: commentCount
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
            style: style,
            tags: tags ?? [],
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            isPublic: isPublic,
            squareLikeCount: likeCount,
            squareCommentCount: commentCount
        )
    }
}

