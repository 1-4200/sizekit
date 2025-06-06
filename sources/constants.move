module sizekit::constants;

use std::string::String;

const KB: u64 = 1024;

// Convert KB to bytes
public fun kb_to_bytes(kb: u64): u64 {
    kb * KB
}

public fun fmt_size(size: u64): String {
    let res = if (size % KB == 0) {
        let n = size / KB;
        let mut n_str = u64_to_string(n);
        n_str.append(b"KB".to_string());
        n_str
    } else {
        let mut n_str = u64_to_string(size);
        n_str.append(b" bytes".to_string());
        n_str
    };
    res
}

// Helper function to convert u64 to string
fun u64_to_string(n: u64): String {
    if (n == 0) {
        return b"0".to_string()
    };

    let mut result = vector::empty<u8>();
    let mut num = n;

    while (num > 0) {
        let digit = ((num % 10) as u8) + 48; // Convert to ASCII
        result.push_back(digit);
        num = num / 10;
    };

    vector::reverse(&mut result);
    result.to_string()
}

// Parse size with unit string ("KB", "bytes")
public fun parse_size(size: u64, unit: String): u64 {
    if (unit == b"KB".to_string()) {
        kb_to_bytes(size)
    } else {
        // Default to bytes
        size
    }
}

#[test_only]
use sui::test_utils::assert_eq;

#[test]
fun test_fmt_size() {
    let res = fmt_size(KB);
    assert_eq(res, b"1KB".to_string());
}

#[test]
fun test_kb_to_bytes() {
    assert_eq(kb_to_bytes(1), 1024);
    assert_eq(kb_to_bytes(256), 256 * 1024);
    assert_eq(kb_to_bytes(0), 0);
}

#[test]
fun test_parse_size() {
    assert_eq(parse_size(256, b"KB".to_string()), 256 * 1024);
    assert_eq(parse_size(100, b"bytes".to_string()), 100);
}

#[test]
fun test_roundtrip_conversion() {
    // Test that conversion works both ways
    let kb_size = 256;
    let bytes = kb_to_bytes(kb_size);
    let formatted = fmt_size(bytes);
    assert_eq(formatted, b"256KB".to_string());
}
