{ lib
, stdenv
, fetchFromGitHub
, cmake
, openssl
, perl
, pkg-config
, rustPlatform
, sqlcipher
, sqlite
, fixDarwinDylibNames
, CoreFoundation
, Security
, libiconv
}:

stdenv.mkDerivation rec {
  pname = "libdeltachat";
  version = "1.77.0";

  src = fetchFromGitHub {
    owner = "deltachat";
    repo = "deltachat-core-rust";
    rev = version;
    hash = "sha256-SEsa83PQ2r3PBJuJhTMeje1n2mZUt/f61DvoVPwyxvs=";
  };

  patches = [
    # https://github.com/deltachat/deltachat-core-rust/pull/2589
    ./darwin-dylib.patch
    ./no-static-lib.patch
  ];

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-6srybgs1DGaE6iMrnRUWRnoQM00VCsZwMNdKQ2eqqxg=";
  };

  nativeBuildInputs = [
    cmake
    perl
    pkg-config
  ] ++ (with rustPlatform; [
    cargoSetupHook
    rust.cargo
  ]) ++ lib.optionals stdenv.isDarwin [
    fixDarwinDylibNames
  ];

  buildInputs = [
    openssl
    sqlcipher
    sqlite
  ] ++ lib.optionals stdenv.isDarwin [
    CoreFoundation
    Security
    libiconv
  ];

  checkInputs = with rustPlatform; [
    cargoCheckHook
  ];

  meta = with lib; {
    description = "Delta Chat Rust Core library";
    homepage = "https://github.com/deltachat/deltachat-core-rust/";
    changelog = "https://github.com/deltachat/deltachat-core-rust/blob/${version}/CHANGELOG.md";
    license = licenses.mpl20;
    maintainers = with maintainers; [ dotlambda ];
    platforms = platforms.unix;
  };
}
