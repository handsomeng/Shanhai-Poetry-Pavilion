//
//  SupabaseClient.swift
//  山海诗馆
//
//  Supabase 客户端配置
//

import Foundation
import Supabase

/// Supabase 配置管理
enum SupabaseConfig {
    
    /// ⚠️ 替换为你的 Supabase 项目 URL
    /// 获取方式：Supabase Dashboard → Settings → API → Project URL
    static let url = URL(string: "https://your-project.supabase.co")!
    
    /// ⚠️ 替换为你的 Supabase anon/public key
    /// 获取方式：Supabase Dashboard → Settings → API → Project API keys → anon public
    static let anonKey = "your-anon-key-here"
    
    /// 检查配置是否正确
    static func validate() -> Bool {
        guard url.absoluteString != "https://your-project.supabase.co",
              anonKey != "your-anon-key-here" else {
            print("""
                ⚠️ Supabase 配置错误
                
                请按以下步骤配置：
                1. 访问 https://supabase.com/dashboard
                2. 选择你的项目
                3. 进入 Settings → API
                4. 复制 Project URL 和 anon public key
                5. 粘贴到 SupabaseClient.swift 文件中
                
                详细步骤请查看：Backend/SUPABASE_SETUP.md
                """)
            return false
        }
        print("✅ Supabase 配置正确")
        return true
    }
}

/// Supabase 客户端单例
let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.anonKey
)

