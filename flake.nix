{
  description = "A collection of flake templates";

  outputs = _: {
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
    };
  };
}
