{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ] (system:
        function (import nixpkgs {
          inherit system;
        }));
  in {
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {packages = with pkgs; [zig];};
    });

    packages = forAllSystems (pkgs: {
      default = pkgs.stdenv.mkDerivation {
        name = "zig";
        version = "0.0.0";
        src = ./.;

        nativeBuildInputs = with pkgs; [
          zig.hook
          zig
        ];
      };
    });
  };
}
