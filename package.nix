{
  coreutils,
  glibcLocales,
  lib,
  ninja,
  pkgs,
  stdenv,
  tex,
}:
let
  pname = "dnd-cards";
  version = "2.0";

  texfiles = [
    "conditions.tex"
    "moonforms.tex"
    "elara-al-deck.tex"
    "elara-deck.tex"
    "kragor-al-deck.tex"
    "kragor-deck.tex"
    "rezina-deck.tex"
    "toge-deck.tex"
    "zek-deck.tex"
  ];

  styfiles = [
    "character.sty"
    "dnd-deck.cls"
    "dndcards.sty"
    "monster.sty"
    "spells.sty"
  ];

  buildNinjaBase = pkgs.writeText "build.ninja" (
    ''
      rule fontcache
        command = mkdir -p $builddir && HOME=$builddir luaotfload-tool --formats=otf --update && touch $out
        description = Generating font cache

      rule latexmk
        command = HOME=$builddir TEXINPUTS=$src//: latexmk --pdflua --interaction=nonstopmode --halt-on-error --outdir=$builddir $in && install -D -m 0644 $builddir/$stem.pdf $out
        description = Building $stem.pdf

      build $builddir/.fontcache: fontcache

    ''
    + lib.concatMapStrings (
      texfile:
      let
        stem = lib.removeSuffix ".tex" texfile;
        implicitDeps = lib.concatMapStringsSep " " (s: "$src/${s}") styfiles;
      in
      ''
        build $out/${stem}.pdf: latexmk $src/${texfile} | ${implicitDeps} || $builddir/.fontcache
          stem = ${stem}

      ''
    ) texfiles
    + ''
      default ${lib.concatMapStringsSep " " (texfile: "$out/${lib.removeSuffix ".tex" texfile}.pdf") texfiles}
    ''
  );

  env = pkgs.linkFarm "dndenv" [
    {
      name = "build.ninja";
      path = buildNinjaBase;
    }
  ];

  mkBuildNinja =
    {
      env,
      src,
      builddir,
      out,
    }:
    ''
      {
        printf 'src = %s\nbuilddir = %s\nout = %s\n\n' ${src} ${builddir} ${out}
        cat ${env}/build.ninja
      } > build.ninja
    '';
in
stdenv.mkDerivation rec {
  inherit pname version;

  src = ./.;

  phases = [ "buildPhase" ];
  buildPhase = ''
    runHook preBuild
    export LC_ALL="en_US.UTF-8"
    mkdir -p $out
    ${mkBuildNinja {
      inherit env;
      src = ''"${src}"'';
      builddir = ''"$PWD"'';
      out = ''"$out"'';
    }}
    ninja
    runHook postBuild
  '';
  nativeBuildInputs = [
    coreutils
    glibcLocales
    ninja
    tex
  ];

  passthru = {
    inherit env mkBuildNinja;
  };

  meta = with lib; {
    description = "Index cards for D&D";
    platforms = platforms.all;
  };
}
