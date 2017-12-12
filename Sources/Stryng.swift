//
//  Stryng.swift
//  Stryng
//
//  Created by Patrick Balestra on 12/2/17.
//  Copyright © 2017 Stryng. All rights reserved.
//

import Foundation

public extension String {
    
    // String[1]
    public subscript(index: Int) -> Character? {
        
        guard index >= 0 else {
            guard let slice = makeSlice(offset: index) else { return nil }
            return slice.content[slice.offset]
        }
        
        guard let stringIndex = indexOffset(by: index) else { return nil }
        return self[stringIndex]
    }
    
    // String[0..<1]
    public subscript(range: Range<Int>) -> Substring? {
        guard let left = indexOffset(by: range.lowerBound) else { return nil }
        guard let right = index(left, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) else { return nil }
        return self[left..<right]
    }
    
    // String[0...1]
    public subscript(range: ClosedRange<Int>) -> Substring? {
        
        guard range.lowerBound >= 0, range.upperBound >= 0 else {
        
            guard let left = range.lowerBound >= 0 ? range.lowerBound : negative(index: range.lowerBound),
                let right = range.upperBound >= 0 ? range.upperBound : negative(index: range.upperBound),
                right > left else {
                    return nil
            }
            
            return self[left...right]
        }
        
        guard range.upperBound >= 0 else {
            guard let right = negative(index: range.upperBound) else { return nil }
            return self[range.lowerBound...right]
        }
        
        guard let left = indexOffset(by: range.lowerBound) else { return nil }
        guard let right = index(left, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) else { return nil }
        return self[left...right]
    }
    
    // String[..<1]
    public subscript(value: PartialRangeUpTo<Int>) -> Substring? {
        guard value.upperBound >= 0 else {
            guard let index = negative(index: value.upperBound) else { return nil }
            return self[..<index]
        }
        
        guard let right = self.indexOffset(by: value.upperBound) else { return nil }
        return self[..<right]
    }
    
    // String[...1]
    public subscript(value: PartialRangeThrough<Int>) -> Substring? {
        guard let right = self.indexOffset(by: value.upperBound) else { return nil }
        return self[...right]
    }
    
    // String[1...]
    public subscript(value: PartialRangeFrom<Int>) -> Substring? {
        guard let left = self.indexOffset(by: value.lowerBound) else { return nil }
        return self[left...]
    }
    
    // String["substring"]
    public subscript(string: String) -> [Range<String.Index>] {
        var occurences = [Range<String.Index>]()
        var initialLeftBound = startIndex
        while initialLeftBound < endIndex {
            guard let range = self.range(of: string, options: [], range: initialLeftBound..<endIndex, locale: nil) else { break }
            occurences.append(range)
            initialLeftBound = range.upperBound
        }
        return occurences
    }
    
    // String["begin"..."end"]
    public subscript(range: ClosedRange<String>) -> [ClosedRange<String.Index>] {
        var occurences = [ClosedRange<String.Index>]()
        var initialLeftBound = startIndex
        while initialLeftBound < endIndex {
            guard let beginRange = self.range(of: range.lowerBound, options: [], range: initialLeftBound..<endIndex, locale: nil) else { break }
            guard let endRange = self.range(of: range.upperBound, options: [], range: beginRange.upperBound..<endIndex, locale: nil) else { break }
            occurences.append(beginRange.lowerBound...endRange.upperBound)
            initialLeftBound = endRange.upperBound
        }
        return occurences
    }
    
    // String["begin"..<"end"]
    public subscript(range: Range<String>) -> [Range<String.Index>] {
        var occurences = [Range<String.Index>]()
        var initialLeftBound = startIndex
        while initialLeftBound < endIndex {
            guard let beginRange = self.range(of: range.lowerBound, options: [], range: initialLeftBound..<endIndex, locale: nil) else { break }
            guard let endRange = self.range(of: range.upperBound, options: [], range: beginRange.upperBound..<endIndex, locale: nil) else { break }
            occurences.append(beginRange.upperBound..<endRange.lowerBound)
            initialLeftBound = endRange.upperBound
        }
        return occurences
    }
    
    // String[Character("a")]
    public subscript(character: Character) -> [String.Index] {
        var occurences = [String.Index]()
        var initialLeftBound = startIndex
        while initialLeftBound < endIndex {
            guard let beginRange = self.range(of: String(character), options: [], range: initialLeftBound..<endIndex, locale: nil) else { break }
            occurences.append(beginRange.lowerBound)
            initialLeftBound = beginRange.upperBound
        }
        return occurences
    }
    
    // String["begin"...]
    public subscript(range: PartialRangeFrom<String>) -> PartialRangeFrom<String.Index>? {
        guard self.indexOffset(by: range.lowerBound.count) != nil else { return nil }
        guard let beginRange = self.range(of: range.lowerBound, options: [], range: startIndex..<endIndex, locale: nil) else { return nil }
        return beginRange.upperBound...
    }
    
    // String[..."end"]
    public subscript(range: PartialRangeThrough<String>) -> PartialRangeThrough<String.Index>? {
        guard self.indexOffset(by: range.upperBound.count) != nil else { return nil }
        guard let endRange = self.range(of: range.upperBound, options: [], range: startIndex..<endIndex, locale: nil) else { return nil }
        return ...endRange.lowerBound
    }
}

public extension Substring {
    
    var string: String {
        return String(self)
    }
}

public extension Optional where Wrapped == Substring {
    
    var string: String? {
        guard let substring = self else { return nil }
        return String(substring)
    }
}

extension String {
    
    // String + 1
    func indexOffset(by distance: Int) -> String.Index? {
        return index(startIndex, offsetBy: distance, limitedBy: endIndex)
    }

    // Indexes
    private func last(indexOf target: String?) -> Int? {
        guard let target = target, let range = self.range(of: target, options: .backwards) else {
            return nil
        }
        
        return distance(from: startIndex, to: range.lowerBound)
    }
    
    private func negative(index: Int) -> Int? {
        guard let slice = makeSlice(offset: index), let lastChar = slice.content[slice.offset] else { return nil }
        return last(indexOf: String(lastChar))
    }
 
    // Slices
    private struct Slice {
        let content: String
        let offset: Int
    }
    
    private func makeSlice(offset index: Int) -> Slice? {
        guard index >= 0 else {
            
            let adjustedIndex = abs(index) - 1
            
            if adjustedIndex < self.count {
                return Slice(content: String(self.reversed()), offset: adjustedIndex)
            }
            
            return nil
        }
        
        return Slice(content: self, offset: index)
    }
}

