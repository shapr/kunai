{
  description = "kunai is a command line bloom filter calculator that outputs colors to an RGB matrix";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    rust-overlay = { url = "github:oxalica/rust-overlay"; };
  };
  outputs = { nixpkgs, rust-overlay, ... }:
    let
      system = "x86_64-linux";
    in {
      packages.${system}.default =
        let pkgs = import nixpkgs { inherit system; };
        in pkgs.rustPlatform.buildRustPackage {
          pname = "kunai";
          nativeBuildInputs = [
            pkgs.pkg-config
            pkgs.rustPlatform.bindgenHook
          ];
          buildInputs = [
            pkgs.bpf-linker
            pkgs.libbpf
            pkgs.libudev-zero
          ];
          version = "0.1.0";
          cargoLock.lockFile = ./Cargo.lock;
          src = pkgs.lib.cleanSource ./.;
        };
      devShells.${system}.default =
        let pkgs = import nixpkgs {
              inherit system;
              overlays = [ (import rust-overlay) ];
              config.allowUnfree = true;
            };
        in
          pkgs.mkShell {
            libraries = with pkgs; [ libpthread-stubs ];
            packages = with pkgs; [ rust-bin.stable.latest.default rust-analyzer cargo libudev-zero pkg-config clang libclang libpthread-stubs libc  lld ];
            shellHook = ''
            export PKG_CONFIG_PATH=${pkgs.lib.concatStrings ["${pkgs.libpthread-stubs}" "/lib/pkgconfig"]}
            '';
          };
    };
}
