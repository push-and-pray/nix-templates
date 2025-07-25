{
  description = "A simple Rust package";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    naersk.url = "github:nix-community/naersk";
  };

  outputs = {
    self,
    nixpkgs,
    naersk,
    ...
  }: let
    systems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
      naersk' = pkgs.callPackage naersk {};
    in {
      default = naersk'.buildPackage {
        src = ./.;
      };
    });

    devShells = forAllSystems (
      system: let
        pkgs = nixpkgsFor.${system};
      in {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [rustc cargo];
        };
      }
    );
  };
}
