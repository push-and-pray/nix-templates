{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs (import systems);
  in {
    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
        stdenv = pkgs.clangStdenv;
        base = stdenv.mkDerivation {
          name = "my-exe";
          src = pkgs.lib.cleanSource ./.;
          nativeBuildInputs = with pkgs; [cmake];
          buildInputs = [];
        };
      in rec {
        default = base.overrideAttrs {
          cmakeBuildType = "Release";
        };

        debug = base.overrideAttrs {
          cmakeBuildType = "Debug";
        };

        test = debug.overrideAttrs {
          doCheck = true;
          cmakeFlags = (base.cmakeFlags or []) ++ ["-DENABLE_ASAN=ON"];
          hardeningDisable = ["fortify"];
        };
      }
    );

    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
        stdenv = pkgs.clangStdenv;
        pkg = self.packages.${system}.debug;
      in {
        default = pkgs.mkShell.override {inherit stdenv;} {
          inputsFrom = [pkg];
          packages = with pkgs; [
            clang-tools
            lldb
            valgrind
            just
          ];
        };
      }
    );

    checks = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
        pkg = self.packages.${system};
      in {
        inherit (pkg) test;

        lint = pkg.debug.overrideAttrs (old: {
          name = "my-exe-lint";
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.clang-tools];
          cmakeFlags =
            (old.cmakeFlags or [])
            ++ [
              "-DCMAKE_C_CLANG_TIDY=clang-tidy;-warnings-as-errors=*"
            ];
        });

        format =
          pkgs.runCommand "check-format" {
            nativeBuildInputs = [pkgs.clang-tools];
          } ''
            find ${pkgs.lib.cleanSource ./.} -name '*.[ch]' -print0 | xargs -0 clang-format --dry-run --Werror

            touch $out
          '';
      }
    );
  };
}
