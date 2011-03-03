module ArJdbc
  module Version
    VERSION = "1.1.1.info3"   # based on v1.1.0, plus some patches.  1.1.1 will supercede this version.
  end
end
# Compatibility with older versions of ar-jdbc for other extensions out there
JdbcAdapter = ArJdbc
JdbcSpec = ArJdbc
