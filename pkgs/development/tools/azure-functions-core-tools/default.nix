{ lib,
  stdenv,
  callPackage,
  fetchFromGitHub,
  buildDotnetModule,
  buildGoModule,
  dotnetCorePackages,
}:
let
  version = "4.0.5441";
  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-functions-core-tools";
    rev = version;
    sha256 = "sha256-S5NHAirnv6cXIRoDu3DTOqoSnt6blHVXxSLOoO9COBM=";
  };
  gozip = buildGoModule {
    pname = "gozip";
    inherit version;
    src = src + "/tools/go/gozip";
    vendorHash = null;
  };
in
buildDotnetModule rec {
  pname = "azure-functions-core-tools";
  inherit src version;

  dotnet-runtime = dotnetCorePackages.sdk_6_0;
  nugetDeps = ./deps.nix;
  useDotnetFromEnv = true;
  executables = [ "func" ];

  postPatch = ''
    substituteInPlace src/Azure.Functions.Cli/Common/CommandChecker.cs \
      --replace "CheckExitCode(\"/bin/bash" "CheckExitCode(\"${stdenv.shell}"
  '';

  postInstall = ''
    mkdir -p $out/bin
    ln -s ${gozip}/bin/gozip $out/bin/gozip
  '';

  meta = with lib; {
    homepage = "https://github.com/Azure/azure-functions-core-tools";
    description = "Command line tools for Azure Functions";
    license = licenses.mit;
    maintainers = with maintainers; [ mdarocha detegr ];
    platforms = ["x86_64-linux" "aarch64-darwin" "x86_64-darwin"];
  };
}
