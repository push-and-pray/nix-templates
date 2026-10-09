{
  description = "A simple Rust package";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    naersk,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
      naersk' = pkgs.callPackage naersk {};
    in {
      default = naersk'.buildPackage {
        src = pkgs.lib.cleanSource ./.;
        doCheck = true;
      };
    });

    checks = forAllSystems (system: {
      default = self.packages.${system}.default;
    });

    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [rustc cargo rustfmt clippy rust-analyzer];
        };
      }
    );
  };
}
