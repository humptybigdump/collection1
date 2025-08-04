static IPASIR_SOLVER_PATH: &str = "/home/arch/candy-kingdom";
static IPASIR_SOLVER_NAME: &str = "candylib";

fn main() {
    println!("cargo:rustc-link-lib=static=stdc++");
    println!("cargo:rustc-link-lib=static=z");

    println!("cargo:rustc-link-search={}", IPASIR_SOLVER_PATH);
    println!("cargo:rustc-link-lib=static={}", IPASIR_SOLVER_NAME);
}
