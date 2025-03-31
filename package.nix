{
  coreutils,
  glibcLocales,
  lib,
  pkgs,
  stdenv,
  tex,
  zsh,
}:
let
  pname = "dnd-cards";
  version = "2.0";
  build.zsh = ./build.zsh;
in
stdenv.mkDerivation rec {
  inherit pname version;
  inherit coreutils tex;

  src = ./.;
  texfiles = lib.escapeShellArgs [
    "elara-spells.tex"
    "kragor-spells.tex"
    "scarlet-spells.tex"
    "elara-reminders.tex"
    "kragor-reminders.tex"
    "more-spells.tex"
  ];

  phases = [ "buildPhase" ];
  buildPhase = ''
    runHook preBuild
    ${zsh}/bin/zsh -df ${build.zsh}
    runHook postBuild
  '';
  nativeBuildInputs = [
    coreutils
    glibcLocales
    tex
    zsh
  ];

  meta = with lib; {
    description = "Index cards for D&D";
    platforms = platforms.all;
  };
}
