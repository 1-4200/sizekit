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
