// Comparable+Clamp.swift
// Circa
// Shared utility for clamping values to a range

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
