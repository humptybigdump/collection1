use std::path::PathBuf;

static SAT_SOLVER_PATH: &'static str = "/home/achim/Daten/uni/SAT_solving";
static SAT_SOLVER_NAME: &'static str = "candylib"; //Looking for libcandylib.a

fn lib_exists(path: &str, lib: &str) {
    let lib_path = PathBuf::from(path).join(format!("lib{}.a", lib));
    if !lib_path.exists() {
        panic!(
            "Cannot find library '{}' at '{}'. Note: File '{}' doesn't exist.",
            lib,
            path,
            lib_path.to_string_lossy(),
        );
    }
}

fn main() {
    lib_exists(SAT_SOLVER_PATH, SAT_SOLVER_NAME);

    println!("cargo:rustc-link-lib=static=stdc++");
    println!("cargo:rustc-link-lib=static=z");

    println!("cargo:rustc-link-search={}", SAT_SOLVER_PATH);
    println!("cargo:rustc-link-lib=static={}", SAT_SOLVER_NAME);
}
