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
  scripts =
    pkgs.runCommand "dnd-cards-scripts"
      {
        nativeBuildInputs = [ zsh ];
      }
      ''
        mkdir -p $out/bin
        for file in dndbuild run; do
          install -m 0755 ${./.}/$file $out/bin/
        done
        patchShebangs $out/bin/$file
      '';
in
stdenv.mkDerivation rec {
  inherit pname version;
  inherit scripts tex;

  src = ./.;
  texfiles = lib.escapeShellArgs [
    "conditions.tex"
    "elara-al-deck.tex"
    "elara-deck.tex"
    "kragor-al-deck.tex"
    "kragor-deck.tex"
    "rezina-deck.tex"
    "toge-deck.tex"
    "zek-deck.tex"
  ];

  phases = [ "buildPhase" ];
  buildPhase = ''
    runHook preBuild
    export LC_ALL="en_US.UTF-8"
    dndbuild
    runHook postBuild
  '';
  nativeBuildInputs = [
    coreutils
    glibcLocales
    scripts
    tex
    zsh
  ];

  meta = with lib; {
    description = "Index cards for D&D";
    platforms = platforms.all;
  };
}
