// module sizekit::constants;

// use std::string::String;
// use sui::bcs;

// const KB: u64 = 1024;
// const MB: u64 = 1024 * KB;

// public fun fmt_size(size: u64): String {
//     let res = if (size % MB == 0) {
//         let n = size / MB;
//         let mut n = bcs::to_bytes(&n).to_string();
//         n.append(b"MB".to_string());
//         n
//     } else if (size % KB == 0) {
//         let n = size / KB;
//         let mut n = bcs::to_bytes(&n).to_string();
//         n.append(b"KB".to_string());
//         n
//     } else {
//         let mut n = bcs::to_bytes(&size).to_string();
//         n.append(b" bytes".to_string());
//         n
//     };
//     res
// }

// #[test_only]
// use sui::test_utils::assert_eq;
// #[test]
// // name the test function without using "test" pre/suffix
// fun fuzz_fmt_size() {
//     let res = fmt_size(KB);
//     assert_eq(res, b"1KB".to_string());
// }
