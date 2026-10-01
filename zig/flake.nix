{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      zig-overlay,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      devShells = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              zig-overlay.overlays.default
            ];
          };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              zig
              zls
            ];
          };
          master = pkgs.mkShell {
            packages = with pkgs; [ zigpkgs.master ];
          };
        }
      );

      packages = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.stdenv.mkDerivation {
            name = "hello";
            version = "0.1.0";
            src = nixpkgs.lib.fileset.toSource {
              root = ./.;
              fileset = nixpkgs.lib.fileset.unions [
                ./src
                ./build.zig
                ./build.zig.zon
              ];
            };

            nativeBuildInputs = with pkgs; [
              zig.hook
            ];
          };
        }
      );
    };
}
