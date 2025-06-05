module sizekit::fixed;

public fun bytes(len: u64, filler: u8): vector<u8> {
    let mut v = vector::empty<u8>();
    let mut i = 0;
    while (i < len) {
        vector::push_back<u8>(&mut v, filler);
        i = i + 1;
    };
    v
}

#[random_test]
fun fuzz_bytes(size: u16) {
    use sui::test_utils::assert_eq;
    std::debug::print(&size);

    let res = bytes(size as u64, 0);
    assert_eq(size as u64, vector::length(&res));
}

#[test]
fun verify_empty_vector() {
    let result = bytes(0, 42);
    assert!(vector::length(&result) == 0);
}

#[test]
fun verify_single_byte() {
    let result = bytes(1, 123);
    assert!(vector::length(&result) == 1);
    assert!(result[0] == 123);
}

#[test]
fun verify_multiple_bytes() {
    let result = bytes(5, 255);
    assert!(vector::length(&result) == 5);
    let mut i = 0;
    while (i < 5) {
        assert!(result[i] == 255);
        i = i + 1;
    };
}

#[test]
fun verify_different_fillers() {
    let fillers = vector[0, 1, 42, 127, 255];
    let mut i = 0;
    while (i < vector::length(&fillers)) {
        let filler = fillers[i];
        let result = bytes(3, filler);
        assert!(vector::length(&result) == 3);
        let mut j = 0;
        while (j < 3) {
            assert!(result[j] == filler);
            j = j + 1;
        };
        i = i + 1;
    };
}
