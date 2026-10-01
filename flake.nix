{
  description = "A collection of flake templates";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }: {
    templates = {
      default = {
        path = ./default;
        description = "A development shell";
      };
      zig = {
        path = ./zig;
        description = "Zig template";
      };
      go = {
        path = ./go;
        description = "Go template";
      };
      rust = {
        path = ./rust;
        description = "Rust template";
      };
      python = {
        path = ./python;
        description = "Python template";
      };
      risc = {
        path = ./risc;
        description = "Risc-V template";
      };
      chisel = {
        path = ./chisel;
        description = "Chisel template";
      };
      c = {
        path = ./c;
        description = "C template";
      };
      c-simple = {
        path = ./c-simple;
        description = "Simple C template using GCC and Make";
      };
    };
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ] (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt
            nixd
          ];
        };
      }
    );
  };
}
