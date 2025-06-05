module sizekit::random;

use std::string::String;
use sui::random::{Self, Random};

entry fun random_bytes(r: &Random, len: u64, ctx: &mut TxContext): vector<u8> {
    let mut gen = random::new_generator(r, ctx);
    let mut v = vector::empty<u8>();
    let mut i = 0;
    while (i < len) {
        let b = sui::random::generate_u8_in_range(&mut gen, 0, 255);
        vector::push_back<u8>(&mut v, b);
        i = i + 1;
    };
    v
}

entry fun random_ascii(r: &Random, len: u64, ctx: &mut TxContext): String {
    let mut bytes = random_bytes(r, len, ctx);
    let mut i = 0;
    while (i < len) {
        let idx = i as u64;
        let b_ref = &mut bytes[idx];
        *b_ref = (*b_ref % 26) + 97; // 97 = 'a'
        i = i + 1;
    };
    bytes.to_string()
}

#[test]
fun verify_ascii_conversion_logic() {
    // Test the ASCII conversion logic without random components
    let test_bytes = vector[0, 25, 50, 100, 200, 255];
    let mut i = 0;
    while (i < vector::length(&test_bytes)) {
        let original = test_bytes[i];
        let converted = (original % 26) + 97;
        assert!(converted >= 97 && converted <= 122); // 'a' to 'z'
        i = i + 1;
    };
}

#[test]
fun verify_byte_range_calculations() {
    // Test the modulo operation for ASCII conversion
    let extremes = vector[0, 25, 26, 51, 255];
    let expected = vector[97, 122, 97, 122, 118]; // 'a', 'z', 'a', 'z', 'v'

    let mut i = 0;
    while (i < vector::length(&extremes)) {
        let input = extremes[i];
        let result = (input % 26) + 97;
        // Debug print to see actual values
        std::debug::print(&input);
        std::debug::print(&result);
        std::debug::print(&expected[i]);
        assert!(result == expected[i]);
        i = i + 1;
    };
}
