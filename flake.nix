{
  description = "kunai is a command line bloom filter calculator that outputs colors to an RGB matrix";
  inputs = {
    # The nixpkgs channels we want to consume
    # nixpkgs-26_05.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Some links to the above channels for consistent naming in outputs
    # nixpkgs.follows = "nixpkgs-26_05";
    nixpkgs.follows = "nixpkgs-unstable";

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
          cargoLock = {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "aya-build-0.2.0" = "sha256-m85cu0x9dkMwcqM5/O4YxqrmtGTAt1LrMDZNk+QL5RI=";
              # "aya-build-0.2.0" = "sha256-YJtBTKpQjwTS27yUga1oafQ6uasdyavSN/yifAgY9mM=";
            };
          };

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
