# flake.nix
#
# This file packages pythoneda-realm-unveilingpartner/infrastructure as a Nix flake.
#
# Copyright (C) 2023-today rydnr's pythoneda-realm-unveilingpartner-def/infrastructure
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
{
  description =
    "Infrastructure layer for pythoneda-realm-unveilingpartner/realm";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    nixos.url = "github:NixOS/nixpkgs/23.11";
    pythoneda-shared-artifact-code-events = {
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-shared-banner.follows =
        "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows =
        "pythoneda-shared-domain";
      url = "github:pythoneda-shared-artifact-def/code-events/0.0.22";
    };
    pythoneda-shared-artifact-code-events-infrastructure = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-artifact-code-events.follows =
        "pythoneda-shared-artifact-code-events";
      inputs.pythoneda-shared-domain.follows =
        "pythoneda-shared-domain";
      inputs.pythoneda-shared-infrastructure.follows =
        "pythoneda-shared-infrastructure";
      url =
        "github:pythoneda-shared-artifact-def/code-events-infrastructure/0.0.24";
    };
    pythoneda-shared-artifact-events = {
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-shared-banner.follows =
        "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows =
        "pythoneda-shared-domain";
      url = "github:pythoneda-shared-artifact-def/events/0.0.31";
    };
    pythoneda-shared-banner = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      url = "github:pythoneda-shared-def/banner/0.0.47";
    };
    pythoneda-shared-domain = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows =
        "pythoneda-shared-banner";
      url = "github:pythoneda-shared-def/domain/0.0.26";
    };
    pythoneda-shared-infrastructure = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows =
        "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows =
        "pythoneda-shared-domain";
      url = "github:pythoneda-shared-def/infrastructure/0.0.23";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        org = "pythoneda-realm-unveilingpartner";
        repo = "infrastructure";
        version = "0.0.8";
        sha256 = "166gp9r298pr8y279394wkpyzgh792xqa9gi3m595fgspj0vy0nh";
        pname = "${org}-${repo}";
        pythonpackage = builtins.replaceStrings [ "-" ] [ "." ] pname;
        package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
        description =
          "Infrastructure layer for pythoneda-realm-unveilingpartner/realm";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/${org}/${repo}";
        maintainers = with pkgs.lib.maintainers;
          [ "unveilingpartner <github@acm-sl.org>" ];
        archRole = "R";
        space = "D";
        layer = "I";
        nixosVersion = builtins.readFile "${nixos}/.version";
        nixpkgsRelease = "nixos-${nixosVersion}";
        shared = import "${pythoneda-shared-banner}/nix/shared.nix";
        pkgs = import nixos { inherit system; };
        pythoneda-realm-unveilingpartner-infrastructure-for = { python
          , pythoneda-shared-artifact-events
          , pythoneda-shared-artifact-code-events
          , pythoneda-shared-artifact-code-events-infrastructure
          , pythoneda-shared-domain
          , pythoneda-shared-infrastructure }:
          let
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            pyprojectTemplateFile = ./pyprojecttoml.template;
            pyprojectTemplate = pkgs.substituteAll {
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage package pname pythonpackage version;
              dbusNext = python.pkgs.dbus-next.version;
              pythonMajorMinor = pythonMajorMinorVersion;
              pythonedaSharedArtifactCodeEvents =
                pythoneda-shared-artifact-code-events.version;
              pythonedaSharedArtifactCodeEventsInfrastructure =
                pythoneda-shared-artifact-code-events-infrastructure.version;
              pythonedaSharedArtifactEvents =
                pythoneda-shared-artifact-events.version;
              pythonedaSharedDomain =
                pythoneda-shared-domain.version;
              pythonedaSharedInfrastructure =
                pythoneda-shared-infrastructure.version;
              src = pyprojectTemplateFile;
            };
            src = pkgs.fetchFromGitHub {
              owner = org;
              rev = version;
              inherit repo sha256;
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              dbus-next
              pythoneda-shared-artifact-events
              pythoneda-shared-artifact-code-events
              pythoneda-shared-artifact-code-events-infrastructure
              pythoneda-shared-domain
              pythoneda-shared-infrastructure
            ];

            pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              cp -r ${src} .
              sourceRoot=$(ls | grep -v env-vars)
              chmod +w $sourceRoot
              cp ${pyprojectTemplate} $sourceRoot/pyproject.toml
            '';

            postInstall = ''
              pushd /build/$sourceRoot
              for f in $(find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              popd
              mkdir $out/dist
              cp dist/${wheelName} $out/dist
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        defaultPackage = packages.default;
        devShells = rec {
          default = pythoneda-realm-unveilingpartner-infrastructure-default;
          pythoneda-realm-unveilingpartner-infrastructure-default =
            pythoneda-realm-unveilingpartner-infrastructure-python311;
          pythoneda-realm-unveilingpartner-infrastructure-python38 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-realm-unveilingpartner-infrastructure-python38;
              python = pkgs.python38;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python38;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-realm-unveilingpartner-infrastructure-python39 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-realm-unveilingpartner-infrastructure-python39;
              python = pkgs.python39;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python39;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python39;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-realm-unveilingpartner-infrastructure-python310 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-realm-unveilingpartner-infrastructure-python310;
              python = pkgs.python310;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python310;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python310;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-realm-unveilingpartner-infrastructure-python311 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-realm-unveilingpartner-infrastructure-python311;
              python = pkgs.python311;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python311;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python311;
              inherit archRole layer org pkgs repo space;
            };
        };
        packages = rec {
          default = pythoneda-realm-unveilingpartner-infrastructure-default;
          pythoneda-realm-unveilingpartner-infrastructure-default =
            pythoneda-realm-unveilingpartner-infrastructure-python311;
          pythoneda-realm-unveilingpartner-infrastructure-python38 =
            pythoneda-realm-unveilingpartner-infrastructure-for {
              python = pkgs.python38;
              pythoneda-shared-artifact-events =
                pythoneda-shared-artifact-events.packages.${system}.pythoneda-shared-artifact-events-python38;
              pythoneda-shared-artifact-code-events =
                pythoneda-shared-artifact-code-events.packages.${system}.pythoneda-shared-artifact-code-events-python38;
              pythoneda-shared-artifact-code-events-infrastructure =
                pythoneda-shared-artifact-code-events-infrastructure.packages.${system}.pythoneda-shared-artifact-code-events-infrastructure-python38;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python38;
              pythoneda-shared-infrastructure =
                pythoneda-shared-infrastructure.packages.${system}.pythoneda-shared-infrastructure-python38;
            };
          pythoneda-realm-unveilingpartner-infrastructure-python39 =
            pythoneda-realm-unveilingpartner-infrastructure-for {
              python = pkgs.python39;
              pythoneda-shared-artifact-events =
                pythoneda-shared-artifact-events.packages.${system}.pythoneda-shared-artifact-events-python39;
              pythoneda-shared-artifact-code-events =
                pythoneda-shared-artifact-code-events.packages.${system}.pythoneda-shared-artifact-code-events-python39;
              pythoneda-shared-artifact-code-events-infrastructure =
                pythoneda-shared-artifact-code-events-infrastructure.packages.${system}.pythoneda-shared-artifact-code-events-infrastructure-python39;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python39;
              pythoneda-shared-infrastructure =
                pythoneda-shared-infrastructure.packages.${system}.pythoneda-shared-infrastructure-python39;
            };
          pythoneda-realm-unveilingpartner-infrastructure-python310 =
            pythoneda-realm-unveilingpartner-infrastructure-for {
              python = pkgs.python310;
              pythoneda-shared-artifact-events =
                pythoneda-shared-artifact-events.packages.${system}.pythoneda-shared-artifact-events-python310;
              pythoneda-shared-artifact-code-events =
                pythoneda-shared-artifact-code-events.packages.${system}.pythoneda-shared-artifact-code-events-python310;
              pythoneda-shared-artifact-code-events-infrastructure =
                pythoneda-shared-artifact-code-events-infrastructure.packages.${system}.pythoneda-shared-artifact-code-events-infrastructure-python310;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python310;
              pythoneda-shared-infrastructure =
                pythoneda-shared-infrastructure.packages.${system}.pythoneda-shared-infrastructure-python310;
            };
          pythoneda-realm-unveilingpartner-infrastructure-python311 =
            pythoneda-realm-unveilingpartner-infrastructure-for {
              python = pkgs.python311;
              pythoneda-shared-artifact-events =
                pythoneda-shared-artifact-events.packages.${system}.pythoneda-shared-artifact-events-python311;
              pythoneda-shared-artifact-code-events =
                pythoneda-shared-artifact-code-events.packages.${system}.pythoneda-shared-artifact-code-events-python311;
              pythoneda-shared-artifact-code-events-infrastructure =
                pythoneda-shared-artifact-code-events-infrastructure.packages.${system}.pythoneda-shared-artifact-code-events-infrastructure-python311;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python311;
              pythoneda-shared-infrastructure =
                pythoneda-shared-infrastructure.packages.${system}.pythoneda-shared-infrastructure-python311;
            };
        };
      });
}
