{
  description = "A riscv devshell";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    systems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgsFor.${system};
        cross = pkgs.pkgsCross.riscv64.buildPackages;
      in {
        default = pkgs.mkShell {
          buildInputs = [pkgs.ripes cross.gcc cross.binutils];
        };
      }
    );
  };
}
