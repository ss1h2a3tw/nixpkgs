{ stdenv, fetchurl, autoreconfHook, pkgconfig, openssl, botan, log4cplus
, boost, python3, postgresql, mysql, gmp, bzip2 }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "kea";
  version = "1.1.0";

  src = fetchurl {
    url = "https://ftp.isc.org/isc/${pname}/${version}/${name}.tar.gz";
    sha256 = "0b9w71d7pfgr0asqpffh9h935xpvwabyfdvdzqzna6da9zp7mnf3";
  };

  patches = [ ./dont-create-var.patch ];

  postPatch = ''
    substituteInPlace ./src/bin/keactrl/Makefile.am '@sysconfdir@' "$out/etc"
    substituteInPlace ./src/bin/keactrl/Makefile.am '@(sysconfdir)@' "$out/etc"
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--with-botan-config=${botan}/bin/botan-config-1.10"
    "--with-dhcp-pgsql=${postgresql}/bin/pg_config"
    "--with-dhcp-mysql=${mysql.client.dev}/bin/mysql_config"
  ];

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [
    openssl log4cplus boost python3 mysql.client
    botan gmp bzip2
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = https://kea.isc.org/;
    description = "High-performance, extensible DHCP server by ISC";
    longDescription = ''
      KEA is a new open source DHCPv4/DHCPv6 server being developed by
      Internet Systems Consortium. The objective of this project is to
      provide a very high-performance, extensible DHCP server engine for
      use by enterprises and service providers, either as is or with
      extensions and modifications.
    '';
    license = licenses.mpl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ fpletz ];
  };
}
