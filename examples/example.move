/// Usage examples for sizekit library
module sizekit::example;

use sizekit::object::{Self, S};
use sizekit::unit;
use sizekit::utils;

/// Simple data container using sizekit
public struct DataContainer has key {
    id: UID,
    data: S,
    size: u64,
}

/// Create a data container with specific size
public fun create_container(target_size: u64, ctx: &mut TxContext): DataContainer {
    let data = object::new_with_size(target_size, ctx);
    let actual_size = utils::measure_bcs_size(&data);

    DataContainer {
        id: sui::object::new(ctx),
        data,
        size: actual_size,
    }
}

/// Get container size in different formats
public fun get_size_info(container: &DataContainer): (u64, std::string::String) {
    let size = container.size;
    let formatted = unit::fmt_size(size);
    (size, formatted)
}

/// Create 1KB data container
public fun create_1kb_container(ctx: &mut TxContext): DataContainer {
    let kb_size = unit::kb_to_bytes(1);
    create_container(kb_size, ctx)
}

/// Compare two containers
public fun compare_containers(a: &DataContainer, b: &DataContainer): u8 {
    utils::compare_sizes(&a.data, &b.data)
}

/// Clean up container
public fun delete_container(container: DataContainer) {
    let DataContainer { id, data, size: _ } = container;
    object::delete(data);
    id.delete();
}
