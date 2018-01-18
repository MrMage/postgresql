import Foundation

/// Supported `PostgreSQLData` data types.
public enum PostgreSQLData {
    case string(String)
    case data(Data)
    case date(Date)

    case bool(Bool)

    case int8(Int8)
    case int16(Int16)
    case int32(Int32)
    case int64(Int64)

    case float(Float)
    case double(Double)

    case point(x: Double, y: Double)

    case dictionary([String: PostgreSQLData])
    case array([PostgreSQLData])
    
    case null
}

/// MARK: Polymorphic

extension PostgreSQLData {
    /// Returns string value, `nil` if not a string.
    public var string: String? {
        switch self {
        case .string(let s): return s
        default: return nil
        }
    }

    /// Returns int value, `nil` if not an int.
    public var int: Int? {
        switch self {
        case .int8(let i): return Int(i)
        case .int16(let i): return Int(i)
        case .int32(let i): return Int(i)
        case .int64(let i):
            guard i <= Int64(Int.max) else { return nil }
            return Int(i)
        case .string(let s): return Int(s)
        default: return nil
        }
    }

    /// Returns bool value, `nil` if not a bool.
    public var bool: Bool? {
        if let int = self.int {
            switch int {
            case 1: return true
            case 0: return false
            default: return nil
            }
        } else if let string = self.string {
            switch string.lowercased() {
            case "t", "true": return true
            case "f", "false": return false
            default: return nil
            }
        } else {
            return nil
        }
    }

    /// Returns dictionary value, `nil` if not a dictionary.
    public var dictionary: [String: PostgreSQLData]? {
        switch self {
        case .dictionary(let d): return d
        default: return nil
        }
    }

    /// Returns array value, `nil` if not an array.
    public var array: [PostgreSQLData]? {
        switch self {
        case .array(let a): return a
        default: return nil
        }
    }
}

/// MARK: Equatable

extension PostgreSQLData: Equatable {
    /// See Equatable.==
    public static func ==(lhs: PostgreSQLData, rhs: PostgreSQLData) -> Bool {
        switch (lhs, rhs) {
        case (.string(let a), .string(let b)): return a == b
        case (.data(let a), .data(let b)): return a == b
        case (.date(let a), .date(let b)): return a == b
        case (.int8(let a), .int8(let b)): return a == b
        case (.int16(let a), .int16(let b)): return a == b
        case (.int32(let a), .int32(let b)): return a == b
        case (.int64(let a), .int64(let b)): return a == b
        case (.float(let a), .float(let b)): return a == b
        case (.double(let a), .double(let b)): return a == b
        case (.point(let a), .point(let b)): return a == b
        case (.dictionary(let a), .dictionary(let b)): return a == b
        case (.array(let a), .array(let b)): return a == b
        case (.null, .null): return true
        default: return false
        }
    }


}

/// MARK: Custom String

extension PostgreSQLData: CustomStringConvertible {
    /// See CustomStringConvertible.description
    public var description: String {
        switch self {
        case .string(let val): return "\"\(val)\""
        case .data(let val): return val.hexDebug
        case .date(let val): return val.description
        case .int8(let val): return "\(val) (int8)"
        case .int16(let val): return "\(val) (int16)"
        case .int32(let val): return "\(val) (int32)"
        case .int64(let val): return "\(val) (int64)"
        case .float(let val): return "\(val) (float)"
        case .double(let val): return "\(val) (double)"
        case .point(let x, let y): return "(\(x), \(y))"
        case .bool(let bool): return bool.description
        case .dictionary(let d): return d.description
        case .array(let a): return a.description
        case .null: return "null"
        }
    }
}