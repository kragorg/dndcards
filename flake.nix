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
            scheme-small
            collection-fontsextra
            etbb
            latexmk
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
            inherit (dnd-cards) texfiles;
            name = "dnd-cards-shell";
            shellHook = ''
              export src="$PWD"
              export PATH=$PWD:$PATH
              mkdir -p obj
              cd obj
            '';
            packages = dnd-cards.nativeBuildInputs ++ [
              pkgs.nixfmt-rfc-style
            ];
          };
        };
      }
    );
}
