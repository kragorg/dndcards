{
  description = "for working on Dungeons & Gardens";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus/master";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      utils,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texliveSmall.withPackages (
          ps: with ps; [
            bigfoot
            collection-fontsextra
            enumitem
            etbb
            footmisc
            latexmk
            lua-visual-debug
            pdflscape
            scheme-small
            totcount
            xstring
          ]
        ) ;
        dnd-cards = pkgs.callPackage ./package.nix { inherit tex; };
      in
      rec {
        packages = {
          inherit dnd-cards tex;
          default = dnd-cards;
        };
        devShells = {
          default = pkgs.mkShell {
            name = "dnd-cards-shell";
            shellHook = ''
              mkdir -p outputs/out obj
              ${dnd-cards.passthru.mkBuildNinja {
                inherit (dnd-cards.passthru) env;
                src = ''"$PWD"'';
                out = "outputs/out";
                builddir = ''"$PWD/obj"'';
              }}
            '';
            packages = dnd-cards.nativeBuildInputs ++ [
              pkgs.nixfmt
            ];
          };
        };
      }
    );
}
