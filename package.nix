{
  coreutils,
  glibcLocales,
  lib,
  ninja,
  pkgs,
  stdenv,
  tex,
  zsh,
}:
let
  pname = "dnd-cards";
  version = "2.0";

in
stdenv.mkDerivation rec {
  inherit pname version;

  src = ./.;

  phases = [ "buildPhase" ];
  buildPhase = ''
    runHook preBuild
    export LC_ALL="en_US.UTF-8"
    mkdir -p $out
    ${zsh}/bin/zsh ${src}/configure.zsh  \
      --builddir "$PWD"                  \
      --dst "$out"                       \
      --src ${src}                       \
      --output build.ninja               \
      ${src}/*.tex
    ninja
    runHook postBuild
  '';
  nativeBuildInputs = [
    coreutils
    glibcLocales
    ninja
    tex
    zsh
  ];

  meta = with lib; {
    description = "Index cards for D&D";
    platforms = platforms.all;
  };
}
