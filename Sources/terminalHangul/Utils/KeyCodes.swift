import CoreGraphics

// macOS Virtual Key Codes
// Reference: https://developer.apple.com/documentation/coregraphics/1572097-virtual_key_codes

struct KeyCodes {

    // MARK: - Letter Keys (QWERTY layout)

    static let a: Int64 = 0x00
    static let s: Int64 = 0x01
    static let d: Int64 = 0x02
    static let f: Int64 = 0x03
    static let h: Int64 = 0x04
    static let g: Int64 = 0x05
    static let z: Int64 = 0x06
    static let x: Int64 = 0x07
    static let c: Int64 = 0x08
    static let v: Int64 = 0x09
    static let b: Int64 = 0x0B
    static let q: Int64 = 0x0C
    static let w: Int64 = 0x0D
    static let e: Int64 = 0x0E
    static let r: Int64 = 0x0F
    static let y: Int64 = 0x10
    static let t: Int64 = 0x11
    static let o: Int64 = 0x1F
    static let u: Int64 = 0x20
    static let i: Int64 = 0x22
    static let p: Int64 = 0x23
    static let l: Int64 = 0x25
    static let j: Int64 = 0x26
    static let k: Int64 = 0x28
    static let n: Int64 = 0x2D
    static let m: Int64 = 0x2E

    // MARK: - Special Keys

    static let space: Int64 = 0x31
    static let enter: Int64 = 0x24
    static let tab: Int64 = 0x30
    static let delete: Int64 = 0x33 // Backspace
    static let forwardDelete: Int64 = 0x75
    static let escape: Int64 = 0x35

    // MARK: - Arrow Keys

    static let leftArrow: Int64 = 0x7B
    static let rightArrow: Int64 = 0x7C
    static let downArrow: Int64 = 0x7D
    static let upArrow: Int64 = 0x7E

    // MARK: - Modifier Keys

    static let command: Int64 = 0x37
    static let shift: Int64 = 0x38
    static let capsLock: Int64 = 0x39
    static let option: Int64 = 0x3A
    static let control: Int64 = 0x3B
    static let rightShift: Int64 = 0x3C
    static let rightOption: Int64 = 0x3D
    static let rightControl: Int64 = 0x3E

    // MARK: - Function Keys

    static let f1: Int64 = 0x7A
    static let f2: Int64 = 0x78
    static let f3: Int64 = 0x63
    static let f4: Int64 = 0x76
    static let f5: Int64 = 0x60
    static let f6: Int64 = 0x61
    static let f7: Int64 = 0x62
    static let f8: Int64 = 0x64
    static let f9: Int64 = 0x65
    static let f10: Int64 = 0x6D
    static let f11: Int64 = 0x67
    static let f12: Int64 = 0x6F

    // MARK: - Helper Methods

    static func isHangulJamoKey(_ keyCode: Int64) -> Bool {
        // TODO: Korean keyboard jamo keys
        // These correspond to the QWERTY keys used for typing Hangul
        let jamoKeys: Set<Int64> = [
            q, w, e, r, t, y, u, i, o, p,
            a, s, d, f, g, h, j, k, l,
            z, x, c, v, b, n, m
        ]
        return jamoKeys.contains(keyCode)
    }

    static func isModifierKey(_ keyCode: Int64) -> Bool {
        let modifiers: Set<Int64> = [
            command, shift, capsLock, option, control,
            rightShift, rightOption, rightControl
        ]
        return modifiers.contains(keyCode)
    }

    static func isArrowKey(_ keyCode: Int64) -> Bool {
        let arrows: Set<Int64> = [
            leftArrow, rightArrow, upArrow, downArrow
        ]
        return arrows.contains(keyCode)
    }

    static func keyName(for keyCode: Int64) -> String {
        // TODO: Add more key names for debugging
        switch keyCode {
        case space: return "Space"
        case enter: return "Enter"
        case tab: return "Tab"
        case delete: return "Delete"
        case escape: return "Escape"
        case leftArrow: return "Left Arrow"
        case rightArrow: return "Right Arrow"
        case upArrow: return "Up Arrow"
        case downArrow: return "Down Arrow"
        default: return "Key \(keyCode)"
        }
    }
}
