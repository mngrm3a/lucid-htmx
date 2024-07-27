{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { self, nixpkgs, ... }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      pkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (system: {
        default = pkgsFor.${system}.pkgs.haskellPackages.callCabal2nix "lucid2-htmx" ./. { };
      });
      devShells = forAllSystems (system: {
        default =
          let
            pkgs = pkgsFor.${system};
            hsPkgs = pkgs.haskellPackages;
            hsTools = with hsPkgs; [
              haskell-language-server
              ghcid
              cabal-install
            ];
          in
          pkgs.mkShell {
            nativeBuildInputs = [ pkgs.zlib ] ++ hsTools;
            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath hsTools;
          };
      });
    };
}
