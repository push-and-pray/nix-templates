{
  description = "A python devshell";
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
      in {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            (python3.withPackages (python-pkgs: [
              python-pkgs.ipykernel
              python-pkgs.jupyter
              python-pkgs.notebook
              python-pkgs.jupyterlab-lsp
              python-pkgs.jedi-language-server
            ]))
          ];
        };
      }
    );
  };
}
