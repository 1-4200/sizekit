# Sizekit

A Sui Move library for creating objects with precise BCS-serialized sizes. 
Sizekit provides byte-level precision for object creation, size measurement, and unit conversion utilities.

## Features

- **Precise Size Control**: Create objects with exact BCS-serialized byte sizes
- **ULEB128 Safety**: Automatic detection and avoidance of problematic encoding boundaries
- **Unit Conversion**: Easy conversion between bytes, KB, and MB with formatting
- **Size Utilities**: Measurement, comparison, and pattern generation tools

## Modules

### `sizekit::object`
Core module for creating objects with specific sizes.

```move
use sizekit::object;

// Create object with exact size
let obj = object::new_with_size(256, ctx);

// Clean up
object::delete(obj);
```

### `sizekit::unit`
Unit conversion and size formatting utilities.

```move
use sizekit::unit;

// Unit conversions
let kb_bytes = unit::kb_to_bytes(1);        // 1024 bytes
let mb_bytes = unit::mb_to_bytes(1);        // 1048576 bytes

// Reverse conversions
let kb_from_bytes = unit::bytes_to_kb(2048); // 2
let mb_from_bytes = unit::bytes_to_mb(2097152); // 2

// Size formatting
let formatted = unit::fmt_size(1024);        // "1KB"
let precise = unit::fmt_size_precise(1536);  // "1536 bytes"
```

### `sizekit::utils`
Utilities for size measurement and vector operations.

```move
use sizekit::utils;

// Measure BCS size of any object
let size = utils::measure_bcs_size(&obj);

// Compare sizes of two objects
let comparison = utils::compare_sizes(&obj1, &obj2);
// Returns: 0 (equal), 1 (first > second), 2 (first < second)

// Create vectors with patterns
let zeros = utils::bytes(5, 0);                    // [0, 0, 0, 0, 0]
let sequential = utils::incremental_bytes(5, 10);  // [10, 11, 12, 13, 14]
let pattern = utils::pattern_bytes(5, 42);         // Deterministic pattern
```

## Basic Example

The `sizekit::basic` module demonstrates common usage patterns:

```move
use sizekit::basic;

// Create container with specific size
let container = basic::create_container(256, ctx);

// Create 1KB container
let kb_container = basic::create_1kb_container(ctx);

// Get size information
let (size_bytes, formatted) = basic::get_size_info(&container);
// Returns: (256, "256 bytes")

// Compare containers
let comparison = basic::compare_containers(&container, &kb_container);

// Clean up
basic::delete_container(container);
basic::delete_container(kb_container);
```

## Installation

Add to your `Move.toml`:

```toml
[dependencies]
sizekit = { git = "https://github.com/your-username/sizekit.git" }

[addresses]
sizekit = "0x0"
```

## Quick Start

1. **Basic Object Creation**
   ```move
   use sizekit::object;
   
   let obj = object::new_with_size(100, ctx);
   // obj is exactly 100 bytes when BCS-serialized
   object::delete(obj);
   ```

2. **Unit Conversion**
   ```move
   use sizekit::unit;
   
   let kb_size = unit::kb_to_bytes(5);  // 5120 bytes
   let formatted = unit::fmt_size(kb_size);  // "5KB"
   ```

3. **Size Measurement**
   ```move
   use sizekit::utils;
   
   let actual_size = utils::measure_bcs_size(&my_object);
   ```

## Safety Features

### ULEB128 Boundary Detection

Sizekit automatically detects and prevents creation of objects at problematic ULEB128 encoding boundaries:

```move
// Check if size is safe
if (!object::is_uleb128_boundary(target_size)) {
    let obj = object::new_with_size(target_size, ctx);
    // Safe to use
} else {
    // Handle boundary case or choose different size
}
```

### Size Requirements

- **Minimum size**: Must be larger than `address::length() + 1` (typically 33 bytes)
- **Boundary avoidance**: Automatically avoids ULEB128 encoding issues
- **Precision**: Guarantees exact BCS-serialized size matching

## License

This project is licensed under the MIT License - see the LICENSE file for details.
