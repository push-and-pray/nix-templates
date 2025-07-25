{
  description = "A collection of flake templates";

  outputs = {self}: {
    templates = {
      zig = {
        path = ./zig;
        description = "Zig template";
      };
      go = {
        path = ./go;
        description = "Go template";
      };
    };
  };
}
