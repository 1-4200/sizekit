module sizekit::unit;

use std::string::String;

const KB: u64 = 1024;
const MB: u64 = 1024 * 1024;

// Convert KB to bytes
public fun kb_to_bytes(kb: u64): u64 {
    kb * KB
}

// Convert MB to bytes
public fun mb_to_bytes(mb: u64): u64 {
    mb * MB
}

// Convert bytes to KB (rounded down)
public fun bytes_to_kb(bytes: u64): u64 {
    bytes / KB
}

// Convert bytes to MB (rounded down)
public fun bytes_to_mb(bytes: u64): u64 {
    bytes / MB
}

public fun fmt_size(size: u64): String {
    let res = if (size >= MB && size % MB == 0) {
        let n = size / MB;
        let mut n_str = u64_to_string(n);
        n_str.append(b"MB".to_string());
        n_str
    } else if (size >= KB && size % KB == 0) {
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

// Format size with more precision
public fun fmt_size_precise(size: u64): String {
    if (size >= MB) {
        let mb = size / MB;
        let remainder = size % MB;
        if (remainder == 0) {
            let mut result = u64_to_string(mb);
            result.append(b"MB".to_string());
            result
        } else {
            let kb = size / KB;
            let mut result = u64_to_string(kb);
            result.append(b"KB".to_string());
            result
        }
    } else if (size >= KB) {
        let kb = size / KB;
        let remainder = size % KB;
        if (remainder == 0) {
            let mut result = u64_to_string(kb);
            result.append(b"KB".to_string());
            result
        } else {
            let mut result = u64_to_string(size);
            result.append(b" bytes".to_string());
            result
        }
    } else {
        let mut result = u64_to_string(size);
        result.append(b" bytes".to_string());
        result
    }
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

// Parse size with unit string ("KB", "MB", "bytes")
public fun parse_size(size: u64, unit: String): u64 {
    if (unit == b"MB".to_string()) {
        mb_to_bytes(size)
    } else if (unit == b"KB".to_string()) {
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
    assert_eq(fmt_size(KB), b"1KB".to_string());
    assert_eq(fmt_size(MB), b"1MB".to_string());
}

#[test]
fun test_mb_conversion() {
    assert_eq(mb_to_bytes(1), MB);
    assert_eq(mb_to_bytes(2), 2 * MB);
    assert_eq(bytes_to_mb(MB), 1);
    assert_eq(bytes_to_mb(2 * MB), 2);
}

#[test]
fun test_kb_to_bytes() {
    assert_eq(kb_to_bytes(1), 1024);
    assert_eq(kb_to_bytes(256), 256 * 1024);
    assert_eq(kb_to_bytes(0), 0);
}

#[test]
fun test_parse_size() {
    assert_eq(parse_size(1, b"MB".to_string()), MB);
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

    let mb_size = 5;
    let mb_bytes = mb_to_bytes(mb_size);
    let mb_formatted = fmt_size(mb_bytes);
    assert_eq(mb_formatted, b"5MB".to_string());
}

#[test]
fun test_fmt_size_precise() {
    assert_eq(fmt_size_precise(KB), b"1KB".to_string());
    assert_eq(fmt_size_precise(MB), b"1MB".to_string());
    assert_eq(fmt_size_precise(MB + KB), b"1025KB".to_string());
    assert_eq(fmt_size_precise(500), b"500 bytes".to_string());
}
