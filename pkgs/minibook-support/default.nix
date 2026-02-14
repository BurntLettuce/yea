{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, systemd
, libevdev
}:

stdenv.mkDerivation rec {
  pname = "minibook-support";
  version = "1.4.0";  # check for newer releases

  src = fetchFromGitHub {
    owner = "petitstrawberry";
    repo = "minibook-support";
    rev = version;
    hash = "";  # will be filled after first build attempt
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ systemd libevdev ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Software for CHUWI MiniBook / MiniBook X / FreeBook N100";
    homepage = "https://github.com/petitstrawberry/minibook-support";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
