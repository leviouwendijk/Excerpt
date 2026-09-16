import Foundation
import Position

public struct SourceExcerpt:
    Sendable,
    Codable,
    Hashable
{
    public struct Options:
        Sendable,
        Codable,
        Hashable
    {
        public var contextLines: UInt
        public var mergeGap: UInt

        public init(
            contextLines: UInt = 2,
            mergeGap: UInt = 0
        ) {
            self.contextLines = contextLines
            self.mergeGap = mergeGap
        }
    }

    public struct Window:
        Sendable,
        Codable,
        Hashable
    {
        public let slice: FileLineSlice
        public let ranges: [LineRange]

        public init(
            slice: FileLineSlice,
            ranges: [LineRange]
        ) {
            self.slice = slice
            self.ranges = ranges
        }
    }

    public let file: URL
    public let windows: [Window]

    public init(
        file: URL,
        windows: [Window]
    ) {
        self.file = file.standardizedFileURL
        self.windows = windows
    }

    public static func make(
        file: URL,
        lines: [String],
        ranges: [LineRange],
        options: Options = .init()
    ) -> Self {
        let standardizedFile = file.standardizedFileURL

        guard !lines.isEmpty else {
            return .init(
                file: standardizedFile,
                windows: []
            )
        }

        let bounds = LineRange(
            uncheckedStart: 1,
            uncheckedEnd: lines.count
        )
        let exactRanges = uniqueSortedRanges(
            ranges.compactMap { range in
                range.intersection(
                    bounds
                )
            }
        )

        guard !exactRanges.isEmpty else {
            return .init(
                file: standardizedFile,
                windows: []
            )
        }

        var windows: [Window] = []
        var activeRange: LineRange?
        var activeMembers: [LineRange] = []

        func appendActiveWindow() {
            guard let activeRange,
                  let slice = FileLineSlice(
                    file: standardizedFile,
                    lines: lines,
                    range: activeRange
                  )
            else {
                return
            }

            windows.append(
                .init(
                    slice: slice,
                    ranges: activeMembers
                )
            )
        }

        for range in exactRanges {
            guard let expanded = range.expanded(
                by: options.contextLines,
                within: bounds
            ) else {
                continue
            }

            guard let current = activeRange else {
                activeRange = expanded
                activeMembers = [
                    range,
                ]
                continue
            }

            if let merged = current.union(
                expanded,
                maximumGap: options.mergeGap
            ) {
                activeRange = merged
                activeMembers.append(
                    range
                )
            } else {
                appendActiveWindow()
                activeRange = expanded
                activeMembers = [
                    range,
                ]
            }
        }

        appendActiveWindow()

        return .init(
            file: standardizedFile,
            windows: windows
        )
    }

    private static func uniqueSortedRanges(
        _ ranges: [LineRange]
    ) -> [LineRange] {
        let sorted = ranges.sorted { lhs, rhs in
            if lhs.start != rhs.start {
                return lhs.start < rhs.start
            }

            return lhs.end < rhs.end
        }

        var result: [LineRange] = []

        for range in sorted where result.last != range {
            result.append(
                range
            )
        }

        return result
    }
}
