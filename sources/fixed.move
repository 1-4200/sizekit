module sizekit::fixed;

public fun bytes(len: u64, filler: u8): vector<u8> {
    vector::tabulate!(len, |_| filler)
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
