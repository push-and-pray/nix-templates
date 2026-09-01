{
  lib,
  stdenv,
  cmake,
  ninja,
  buildType ? "Release",
  withSanitizers ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hello";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./.clang-tidy
      ./CMakeLists.txt
      ./include
      ./src
      ./tests
    ];
  };

  strictDeps = true;
  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeBuildType = buildType;
  cmakeFlags = [
    (lib.cmakeBool "ENABLE_SANITIZERS" withSanitizers)
    (lib.cmakeBool "BUILD_TESTING" finalAttrs.doCheck)
  ];

  hardeningDisable = lib.optionals (withSanitizers || buildType == "Debug") [ "fortify" ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    ctest --output-on-failure
    runHook postCheck
  '';

  meta = {
    description = "A small C project";
    mainProgram = "hello";
    platforms = lib.platforms.unix;
  };
})
