{ lib, stdenv, fetchurl, pkg-config, fontconfig, autoreconfHook, DiskArbitration
, withJava ? false, jdk ? null, ant ? null
, withAACS ? false, libaacs ? null
, withBDplus ? false, libbdplus ? null
, withMetadata ? true, libxml2 ? null
, withFonts ? true, freetype ? null
}:

with lib;

assert withJava -> jdk != null && ant != null;
assert withAACS -> libaacs != null;
assert withBDplus -> libbdplus != null;
assert withMetadata -> libxml2 != null;
assert withFonts -> freetype != null;

# Info on how to use:
# https://wiki.archlinux.org/index.php/BluRay

stdenv.mkDerivation rec {
  pname = "libbluray";
  version  = "1.3.1";

  src = fetchurl {
    url = "http://get.videolan.org/libbluray/${version}/${pname}-${version}.tar.bz2";
    sha256 = "sha256-wksPQcW3N7u2XFRP5jSVY3p3HBClGd/IAudp8RK0O3U=";
  };

  patches = optional withJava ./BDJ-JARFILE-path.patch;

  nativeBuildInputs = [ pkg-config autoreconfHook ]
                      ++ optionals withJava [ ant ]
                      ;

  buildInputs = [ fontconfig ]
                ++ optional withJava jdk
                ++ optional withMetadata libxml2
                ++ optional withFonts freetype
                ++ optional stdenv.isDarwin DiskArbitration
                ;

  propagatedBuildInputs = optional withAACS libaacs;

  NIX_LDFLAGS = toString [
    (optionalString withAACS   "-L${libaacs}/lib -laacs")
    (optionalString withBDplus "-L${libbdplus}/lib -lbdplus")
  ];

  preConfigure = ''
    ${optionalString withJava ''export JDK_HOME="${jdk.home}"''}
  '';

  configureFlags =  with lib;
                    optional (! withJava) "--disable-bdjava-jar"
                 ++ optional (! withMetadata) "--without-libxml2"
                 ++ optional (! withFonts) "--without-freetype"
                 ;

  meta = with lib; {
    homepage = "http://www.videolan.org/developers/libbluray.html";
    description = "Library to access Blu-Ray disks for video playback";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ abbradar ];
    platforms = platforms.unix;
  };
}
