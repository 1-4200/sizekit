module sizekit::object;

use std::address;
use sui::bcs;

const ERR_TARGET_SIZE_TOO_SMALL: u64 = 1;
const ERR_CANNOT_MATCH_TARGET_SIZE: u64 = 2;

public struct S has key, store {
    id: UID,
    contents: vector<u8>,
}

// Inspired by:
// https://github.com/MystenLabs/sui/blob/main/crates/sui-adapter-transactional-tests/tests/size_limits/move_object_size_limit.move
public fun new_with_target_size(target_size: u64, ctx: &mut TxContext): S {
    // UID is typically 32 bytes (address::length()).
    // An empty vector<u8> serializes to 1 byte for its length (0).
    let min_possible_size = address::length() + 1;
    assert!(target_size >= min_possible_size, ERR_TARGET_SIZE_TOO_SMALL);

    let id = object::new(ctx);
    let mut s = S { id, contents: vector::empty<u8>() };
    let mut current_bcs_size = bcs::to_bytes(&s).length();

    // Grow phase: add bytes until current_bcs_size >= target_size
    while (current_bcs_size < target_size) {
        vector::push_back(&mut s.contents, 0u8); // Add a filler byte
        current_bcs_size = bcs::to_bytes(&s).length();
    };
    while (current_bcs_size > target_size) {
        // This assertion helps catch impossible target sizes if not caught by
        // min_possible_size
        // or if shrinking empties contents before reaching target_size.
        assert!(!vector::is_empty(&s.contents), ERR_CANNOT_MATCH_TARGET_SIZE);
        let _ = vector::pop_back(&mut s.contents);
        current_bcs_size = bcs::to_bytes(&s).length();
    };
    assert!(current_bcs_size == target_size, ERR_CANNOT_MATCH_TARGET_SIZE);
    s
}

public fun delete(s: S) {
    let S { id, contents: _ } = s;
    id.delete();
}

#[test_only]
use sui::test_scenario;

#[test]
fun verify_minimum_size() {
    let mut scenario = test_scenario::begin(@0x1);
    let min_size = address::length() + 1;
    let s = new_with_target_size(min_size, scenario.ctx());
    let actual_size = bcs::to_bytes(&s).length();
    assert!(actual_size == min_size);
    delete(s);
    scenario.end();
}

#[test]
fun verify_exact_size_matching() {
    let mut scenario = test_scenario::begin(@0x1);
    let target_sizes = vector[33, 50, 100, 127, 128, 129, 255, 256, 1000];
    let mut i = 0;
    while (i < vector::length(&target_sizes)) {
        let target_size = target_sizes[i];
        let s = new_with_target_size(target_size, scenario.ctx());
        let actual_size = bcs::to_bytes(&s).length();
        assert!(actual_size == target_size);
        delete(s);
        i = i + 1;
    };
    scenario.end();
}

#[test]
#[expected_failure(abort_code = ERR_TARGET_SIZE_TOO_SMALL)]
fun verify_size_too_small_failure() {
    let mut scenario = test_scenario::begin(@0x1);
    let min_size = address::length() + 1;
    let s = new_with_target_size(min_size - 1, scenario.ctx());
    delete(s);
    scenario.end();
}

#[test]
fun verify_uleb128_boundary_handling() {
    let mut scenario = test_scenario::begin(@0x1);
    // Test around ULEB128 encoding boundaries for vector length
    let boundary_sizes = vector[127, 128, 129, 255, 256, 257];
    let mut i = 0;
    while (i < vector::length(&boundary_sizes)) {
        let target_size = boundary_sizes[i];
        if (target_size >= address::length() + 1) {
            let s = new_with_target_size(target_size, scenario.ctx());
            let actual_size = bcs::to_bytes(&s).length();
            assert!(actual_size == target_size);
            delete(s);
        };
        i = i + 1;
    };
    scenario.end();
}
