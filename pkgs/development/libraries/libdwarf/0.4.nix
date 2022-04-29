{ lib, stdenv, fetchurl, libelf, zlib }:

stdenv.mkDerivation rec {
  pname = "libdwarf";
  version = "0.4.0";

  src = fetchurl {
    url = "https://www.prevanders.net/libdwarf-${version}.tar.xz";
    # Upstream displays this hash broken into four parts:
    sha512 = "30e5c6c1fc95aa28a014007a45199160"
          + "e1d9ba870b196d6f98e6dd21a349e9bb"
          + "31bba1bd6817f8ef9a89303bed056218"
          + "2a7d46fcbb36aedded76c2f1e0052e1e";
  };

  configureFlags = [ "--enable-shared" "--disable-nonshared" ];

  buildInputs = [ libelf zlib ];

  meta = {
    homepage = "https://www.prevanders.net/dwarf.html";
    platforms = lib.platforms.unix;
    license = lib.licenses.lgpl21Plus;
  };
}
