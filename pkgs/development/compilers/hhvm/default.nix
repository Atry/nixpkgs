{ lib, stdenv, fetchgit, cmake, pkg-config, boost, libunwind, libmemcached
, pcre, libevent, gd, curl, libxml2, icu, flex, bison, openssl, zlib, php
, expat, libcap, oniguruma, libdwarf, libmcrypt, tbb, gperftools, glog, libkrb5
, bzip2, openldap, readline, libelf, uwimap, binutils, cyrus_sasl, pam, libpng
, libxslt, freetype, gdb, git, perl, libmysqlclient, gmp, libyaml, libedit
, libvpx, imagemagick6, fribidi, gperf, which, ocamlPackages, re2c, sqlite
, libgccjit, re2, tzdata, lz4, double-conversion, brotli, libzip, zstd
, jemalloc, fmt, libsodium, unzip
}:

stdenv.mkDerivation rec {
  pname = "hhvm";
  version = "4.158.0";

  # use git version since we need submodules
  src = fetchgit {
    url    = "https://github.com/facebook/hhvm.git";
    rev    = "HHVM-${version}";
    sha256 = "JV4xoDgKWPJXwWHHRGrMoZA81AxkNj/IDUZk+yeBiAw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config flex bison ];
  buildInputs =
    [ boost libunwind libmysqlclient libmemcached pcre gdb git perl
      libevent gd curl libxml2 icu openssl zlib php expat libcap
      oniguruma libdwarf libmcrypt tbb gperftools bzip2 openldap readline
      libelf uwimap binutils cyrus_sasl pam glog libpng libxslt libkrb5
      gmp libyaml libedit libvpx imagemagick6 fribidi gperf which
      ocamlPackages.ocaml ocamlPackages.ocamlbuild re2c sqlite libgccjit re2
      tzdata lz4 double-conversion brotli libzip zstd jemalloc fmt libsodium
      unzip
    ];

  patches = [
    ./system-tzdata.patch
  ];

  dontUseCmakeBuildDir = true;
  NIX_LDFLAGS = "-lpam -L${pam}/lib";

  # work around broken build system
  NIX_CFLAGS_COMPILE = "-I${freetype.dev}/include/freetype2";

  cmakeFlags = [
    "-DHAVE_SYSTEM_TZDATA:BOOL=true" 
    # the cmake package does not handle absolute CMAKE_INSTALL_INCLUDEDIR correctly
    # (setting it to an absolute path causes include files to go to $out/$out/include,
    #  because the absolute path is interpreted with root at $out).
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ];

  # prePatch = ''
  #   substituteInPlace ./configure \
  #     --replace "/usr/bin/env bash" ${stdenv.shell}
  #   perl -pi -e 's/([ \t(])(isnan|isinf)\(/$1std::$2(/g' \
  #     hphp/runtime/base/*.cpp \
  #     hphp/runtime/ext/std/*.cpp \
  #     hphp/runtime/ext_zend_compat/php-src/main/*.cpp \
  #     hphp/runtime/ext_zend_compat/php-src/main/*.h
  #   patchShebangs .
  # '';

  meta = {
    description = "High-performance JIT compiler for PHP/Hack";
    homepage    = "https://hhvm.com";
    license     = "PHP/Zend";
    platforms   = [ "x86_64-linux" ];
    maintainers = [ lib.maintainers.thoughtpolice ];
  };
}
