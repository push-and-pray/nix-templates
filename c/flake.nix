{
  description = "A C project built with CMake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.callPackage ./package.nix { stdenv = pkgs.clangStdenv; };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          package = self.packages.${system}.default;
        in
        {
          default = pkgs.mkShell.override { stdenv = pkgs.clangStdenv; } {
            inputsFrom = [ package ];

            packages =
              with pkgs;
              [
                clang-tools # clangd, clang-format, clang-tidy
                cmake-language-server
                gersemi # cmake formatter
                just
                lldb
                nixfmt # nix formatter
                nixd
                statix
                deadnix
              ]
              ++ lib.optionals stdenv.hostPlatform.isLinux [ valgrind ];

            # Local builds default to Debug (-O0), where the wrapper's
            # _FORTIFY_SOURCE hardening only produces warning noise.
            hardeningDisable = [ "fortify" ];
          };
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          package = self.packages.${system}.default;
        in
        {
          inherit package;

          sanitizers = package.override {
            buildType = "Debug";
            withSanitizers = true;
          };

          tidy = (package.override { buildType = "Debug"; }).overrideAttrs (old: {
            pname = "${old.pname}-tidy";
            nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.clang-tools ];
            cmakeFlags = old.cmakeFlags ++ [ "-DCMAKE_C_CLANG_TIDY=clang-tidy" ];
          });

          format =
            pkgs.runCommand "check-format"
              {
                nativeBuildInputs = with pkgs; [
                  clang-tools
                  gersemi
                  nixfmt
                ];
              }
              ''
                cd ${self}

                find src include tests -name '*.[ch]' -exec clang-format --dry-run --Werror {} +
                gersemi --check CMakeLists.txt
                find . -name '*.nix' -exec nixfmt --check {} +

                touch $out
              '';
        }
      );

    };
}
