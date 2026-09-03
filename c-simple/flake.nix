{
  description = "A simple GCC and Make development shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              bear
              clang-tools
              gcc
              gdb
              gnumake
              pkg-config
            ];

            shellHook = ''
              if [ -f Makefile ] && [ ! -f compile_commands.json ]; then
                make compile-db
              fi
            '';
          };
        }
      );
    };
}
