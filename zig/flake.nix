{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    systems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = function:
      nixpkgs.lib.genAttrs systems (system:
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
