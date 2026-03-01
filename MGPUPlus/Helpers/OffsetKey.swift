//
//  OffsetKey.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 28.02.2026.
//

import SwiftUI

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
