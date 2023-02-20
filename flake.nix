{
  inputs = {
    opam-nix.url = "github:tweag/opam-nix";
    flake-utils.url = "github:numtide/flake-utils";
    opam-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, flake-utils, opam-nix, nixpkgs }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        devPackagesQuery = {
          ocaml-lsp-server = "*";
          ocamlformat = "*";
          alcotest = "*";
          utop = "*";
          ocaml-base-compiler = "*";
        };
        scope = on.buildOpamProject' { } ./. devPackagesQuery;
        devPackages = builtins.attrValues
          (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope);
      in {
        legacyPackages = scope;

        packages = scope;

        devShells.default = pkgs.mkShell {
          inputsFrom = [
            scope.dns-client
            scope.dns-cli
            scope.dns-mirage
            scope.dns
            scope.dns-resolver
            scope.dnssec
            scope.dns-server
            scope.dns-stub
            scope.dns-tsig
          ];
          buildInputs = devPackages;
        };
      });
}
