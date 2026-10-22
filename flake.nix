{
  description = "kunai is a command line bloom filter calculator that outputs colors to an RGB matrix";
  inputs = {
    # The nixpkgs channels we want to consume
    nixpkgs-25_11.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Some links to the above channels for consistent naming in outputs
    nixpkgs.follows = "nixpkgs-25_11";

    # Extra inputs for software living outside nixpkgs
    flake-compat = {
      url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
    };
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
            libraries = with pkgs; [
              libpthread-stubs
            ];
            packages = with pkgs; [
              bpf-linker
              cargo
              clang
              libbpf
              libc
              libclang
              libpthread-stubs
              libudev-zero
              lld
              pkg-config
              (rust-bin.nightly.latest.default.override {
                extensions = [ "rust-analyzer" "rust-src" "clippy" ];
              })
            ];
            shellHook = ''
              export PKG_CONFIG_PATH=${pkgs.lib.concatStrings [
                   "${pkgs.libpthread-stubs}"
                   "/lib/pkgconfig"
                 ]}
            '';
          };
    };
}
