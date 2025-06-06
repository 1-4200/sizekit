module sizekit::utils;

use sui::bcs;

// Create a vector of specific length filled with a specific byte value
public fun bytes(len: u64, filler: u8): vector<u8> {
    vector::tabulate!(len, |_| filler)
}

// Measure BCS serialized size of any item
public fun measure_bcs_size<T>(item: &T): u64 {
    bcs::to_bytes(item).length()
}

// Create vector filled with incrementing values
public fun incremental_bytes(len: u64, start: u8): vector<u8> {
    vector::tabulate!(len, |i| {
        ((start as u64 + i) % 256) as u8
    })
}

// Create vector with pattern (deterministic)
public fun pattern_bytes(len: u64, seed: u64): vector<u8> {
    vector::tabulate!(len, |i| {
        ((seed * 7 + i * 13) % 256) as u8
    })
}

// Compare sizes of two items (0: equal, 1: item1 > item2, 2: item1 < item2)
public fun compare_sizes<T1, T2>(item1: &T1, item2: &T2): u8 {
    let size1 = measure_bcs_size(item1);
    let size2 = measure_bcs_size(item2);

    if (size1 == size2) {
        0
    } else if (size1 > size2) {
        1
    } else {
        2
    }
}

#[random_test]
fun fuzz_bytes(size: u16) {
    let res = bytes(size as u64, 0);
    assert!(size as u64 == res.length());
}

#[test]
fun empty_vector() {
    let res = bytes(0, 42);
    assert!(res.length() == 0);
}

#[test]
fun single_byte() {
    let res = bytes(1, 123);
    assert!(res.length() == 1);
    assert!(res[0] == 123);
}

#[test]
fun multiple_bytes() {
    let res = bytes(5, 255);
    assert!(res.length() == 5);
    assert!(res.all!(|byte| *byte == 255));
}

#[test]
fun different_fillers() {
    let fillers = vector[0, 1, 42, 127, 255];
    fillers.do_ref!(|filler| {
        let res = bytes(3, *filler);
        assert!(res.length() == 3);
        assert!(res.all!(|byte| *byte == *filler));
    });
}

#[test]
fun test_incremental_bytes() {
    let res = incremental_bytes(5, 10);
    assert!(res.length() == 5);
    assert!(res[0] == 10);
    assert!(res[1] == 11);
    assert!(res[4] == 14);
}

#[test]
fun test_pattern_bytes() {
    let res1 = pattern_bytes(3, 42);
    let res2 = pattern_bytes(3, 42);
    let res3 = pattern_bytes(3, 43);

    // Same seed should produce same result
    assert!(res1 == res2);
    // Different seed should produce different result
    assert!(res1 != res3);
}

#[test]
fun test_compare_sizes() {
    let v1 = vector[1u8, 2u8, 3u8];
    let v2 = vector[1u8, 2u8];
    let v3 = vector[1u8, 2u8, 3u8];

    assert!(compare_sizes(&v1, &v2) == 1); // v1 > v2
    assert!(compare_sizes(&v2, &v1) == 2); // v2 < v1
    assert!(compare_sizes(&v1, &v3) == 0); // v1 == v3
}
