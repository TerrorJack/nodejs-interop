{ sources ? import ./nix/sources.nix { }
, haskellNix ? import sources.haskell-nix { }
, nixpkgsSrc ? haskellNix.sources.nixpkgs-2009
, nixpkgsArgs ? haskellNix.nixpkgsArgs
, pkgs ? import nixpkgsSrc nixpkgsArgs
, ghc ? "ghc8103"
, node ? "nodejs-14_x"
, hsPkgs ? import ./default.nix { inherit pkgs ghc node; }
}: hsPkgs.shellFor {
  packages = ps: with ps; [
    inline-js
    inline-js-core
    inline-js-examples
    inline-js-tests
  ];

  withHoogle = true;

  tools = {
    brittany = "latest";
    cabal-install = "latest";
    ghcid = "latest";
    haskell-language-server = "latest";
    hlint = "latest";
    ormolu = "latest";
  };

  buildInputs = [
    (pkgs.haskell-nix.cabalProject {
      src = sources.hindent;
      compiler-nix-name = ghc;
    }).hindent.components.exes.hindent

    pkgs."${node}"
  ];

  exactDeps = true;
}
