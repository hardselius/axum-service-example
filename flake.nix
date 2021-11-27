{
  description = "tfenv-rs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
          (import rust-overlay)
        ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      rec {
        # `nix develop`
        devShell = pkgs.mkShell
          {
            buildInputs = with pkgs; [
              cargo-edit
              cargo-generate

              (rust-bin.stable."1.56.1".default.override {
                extensions = [ "rust-src" ];
              })
              rust-analyzer

              openssl.dev
              pkg-config
              # rustEnv
              sccache
              zlib.dev
            ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
              libiconv
              CoreServices
              SystemConfiguration
            ]);

            RUST_BACKTRACE = 1;
          };
      }
    );
}

