{
  description = "A collection of flake templates";

  outputs = {self}: {
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
    };
  };
}
