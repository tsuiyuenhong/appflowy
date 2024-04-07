use std::{env, path::PathBuf};

use bindgen::{Builder, CargoCallbacks};
use cc::Build;

fn main() {
  let target = env::var("CARGO_CFG_TARGET_VENDOR");
  if let Ok(target) = target {
    if target != "apple" {
      println!("Not an Apple target, skip os_log bindings generation.");
      return;
    }

    let target_os = env::var("CARGO_CFG_TARGET_OS");
    if let Ok(target_os) = target_os {
      if target_os != "ios" {
        println!("Not an iOS target, skip os_log bindings generation.");
        return;
      }

      // only supports for iOS now
      let bindings = Builder::default()
        .header("os_log_wrapper.h")
        .parse_callbacks(Box::new(CargoCallbacks))
        .allowlist_function("os_log_t")
        .allowlist_function("os_log_type_t")
        .clang_arg("-miphoneos-version-min=11.0")
        .generate()
        .expect("Generate os_log bindings failed!");

      let output = PathBuf::from(env::var("OUT_DIR").unwrap()).join("os_log_bindings.rs");
      bindings
        .write_to_file(output)
        .expect("Write os_log bindings failed!");
      Build::new()
        .file("os_log_wrapper.c")
        .compile("os_log_wrapper");
    }
  }
}
