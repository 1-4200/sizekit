module sizekit::object;

use std::address;
use sui::bcs;

const ERR_TARGET_SIZE_TOO_SMALL: u64 = 1;
const ERR_UNSAFE_SIZE: u64 = 2;

public struct S has key, store {
    id: UID,
    contents: vector<u8>,
}

// Check if a target size has ULEB128 encoding issues that cause fast creation to fail
public fun is_uleb128_boundary(target_size: u64): bool {
    if (target_size <= address::length() + 1) {
        return true // Too small
    };

    // Check problematic ULEB128 boundaries for vector length encoding
    let content_size = target_size - address::length() - 1; // Subtract UID and initial vector length byte

    // ULEB128 encoding boundaries:
    // 0-127: 1 byte
    // 128-16383: 2 bytes
    // 16384-2097151: 3 bytes

    // Check if we're near boundaries where encoding might change
    (content_size >= 127 && content_size <= 130) ||
    (content_size >= 16383 && content_size <= 16386) ||
    (content_size >= 2097151 && content_size <= 2097154)
}

// Create object with specific target size
// Inspired by https://github.com/MystenLabs/sui/blob/main/crates/sui-adapter-transactional-tests/tests/size_limits/move_object_size_limit.move
public fun new_with_size(target_size: u64, ctx: &mut TxContext): S {
    // Validate minimum size
    assert!(target_size > address::length() + 1, ERR_TARGET_SIZE_TOO_SMALL);

    // Reject sizes that cause fast creation to fail
    assert!(!is_uleb128_boundary(target_size), ERR_UNSAFE_SIZE);

    let bytes_to_add = target_size - (address::length() + 1);
    let contents = vector::tabulate!(bytes_to_add, |_| 0u8);

    let mut s = S { id: object::new(ctx), contents };
    let mut size = bcs::to_bytes(&s).length();

    // Shrink by 1 byte until we match size
    while (size > target_size) {
        let _ = vector::pop_back(&mut s.contents);
        size = size - 1;
    };

    s
}

public fun delete(s: S) {
    let S { id, .. } = s;
    id.delete();
}

#[test_only]
use sui::test_scenario;

#[test]
fun test_unsafe_size_detection() {
    // Test boundary cases that are unsafe for fast creation
    assert!(is_uleb128_boundary(32), ERR_UNSAFE_SIZE); // Too small
    assert!(is_uleb128_boundary(128 + 32), ERR_UNSAFE_SIZE); // ULEB128 boundary
    assert!(is_uleb128_boundary(129 + 32), ERR_UNSAFE_SIZE); // Near boundary

    // These should be safe
    assert!(!is_uleb128_boundary(50), ERR_UNSAFE_SIZE);
    assert!(!is_uleb128_boundary(100), ERR_UNSAFE_SIZE);
}

#[test]
fun test_safe_sizes() {
    let mut scenario = test_scenario::begin(@0x1);
    // Test only safe sizes
    let safe_sizes = vector[
        33,
        34,
        35, // Basic sizes
        50,
        100,
        150,
        200,
        255,
        256, // Safe mid-range sizes
    ];

    safe_sizes.do_ref!(|size| {
        if (!is_uleb128_boundary(*size)) {
            let s = new_with_size(*size, scenario.ctx());
            let actual_size = bcs::to_bytes(&s).length();
            assert!(actual_size == *size);
            delete(s);
        }
    });

    scenario.end();
}

#[test]
fun minimum_size() {
    let mut scenario = test_scenario::begin(@0x1);
    let min_size = address::length() + 2; // Use safe minimum size
    let s = new_with_size(min_size, scenario.ctx());
    let actual_size = bcs::to_bytes(&s).length();
    assert!(actual_size == min_size);
    delete(s);
    scenario.end();
}

#[test]
fun exact_size_matching() {
    let mut scenario = test_scenario::begin(@0x1);
    // Test only safe sizes
    let target_sizes = vector[33, 50, 100, 200, 256, 1000];

    target_sizes.do_ref!(|target_size| {
        if (!is_uleb128_boundary(*target_size)) {
            let s = new_with_size(*target_size, scenario.ctx());
            let actual_size = bcs::to_bytes(&s).length();
            assert!(actual_size == *target_size);
            delete(s);
        }
    });

    scenario.end();
}

#[test, expected_failure(abort_code = ERR_TARGET_SIZE_TOO_SMALL)]
fun size_too_small_failure() {
    let mut scenario = test_scenario::begin(@0x1);
    let min_size = address::length() + 1;
    let s = new_with_size(min_size, scenario.ctx());
    delete(s);
    scenario.end();
}

#[test, expected_failure(abort_code = ERR_UNSAFE_SIZE)]
fun unsafe_size_failure() {
    let mut scenario = test_scenario::begin(@0x1);
    // Test known unsafe size
    let unsafe_size = 128 + address::length() + 1; // ULEB128 boundary
    let s = new_with_size(unsafe_size, scenario.ctx());
    delete(s);
    scenario.end();
}
