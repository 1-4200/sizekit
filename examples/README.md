# Sizekit Library Examples

This directory contains basic examples showing how to use the sizekit library for creating objects with precise BCS-serialized sizes.

## Module Overview

- **`sizekit::object`** - Create objects with specific BCS sizes
- **`sizekit::unit`** - Unit conversion and size formatting utilities
- **`sizekit::utils`** - BCS size measurement and comparison tools

## Basic Example (examples/basic.move)

The `examples::basic` module demonstrates fundamental sizekit usage patterns:

### 1. Creating Data Containers

```move
use examples::basic;

// Create a container with specific size
let container = basic::create_container(256, ctx);

// Create a 1KB container
let kb_container = basic::create_1kb_container(ctx);
```

### 2. Size Info and Formatting

```move
// Get size information
let (size_bytes, formatted) = basic::get_size_info(&container);
// size_bytes = 256, formatted = "256 bytes"

let (kb_size, kb_formatted) = basic::get_size_info(&kb_container); 
// kb_size = 1024, kb_formatted = "1KB"
```

### 3. Comparing Containers

```move
// Compare two containers by size
let comparison = basic::compare_containers(&container, &kb_container);
// Returns: 0 (equal), 1 (first > second), 2 (first < second)
```

### 4. Cleanup

```move
// Always clean up when done
basic::delete_container(container);
basic::delete_container(kb_container);
```

## Core Sizekit Functions Used

### Object Creation
```move
use sizekit::object;

let data = object::new_with_size(target_size, ctx);  // Create with exact size
object::delete(data);                                // Clean up
```

### Size Measurement
```move
use sizekit::utils;

let actual_size = utils::measure_bcs_size(&data);    // Get BCS size
let comparison = utils::compare_sizes(&data1, &data2); // Compare sizes
```

### Unit Conversion
```move
use sizekit::unit;

let kb_bytes = unit::kb_to_bytes(1);        // 1KB = 1024 bytes
let formatted = unit::fmt_size(1024);       // "1KB"
```

## Quick Start

1. Import the basic example module:
   ```move
   use examples::basic;
   ```

2. Create a data container:
   ```move
   let container = basic::create_container(100, ctx);
   ```

3. Check its size:
   ```move
   let (size, formatted) = basic::get_size_info(&container);
   ```

4. Clean up:
   ```move
   basic::delete_container(container);
   ```

## Running Tests

To test the example module:

```bash
sui move test
```

This will verify all functions work correctly with precise size control.
