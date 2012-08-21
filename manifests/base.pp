package { ["vim", "mongodb-10gen", "opengeo-postgis", "gdal-bin"]:
  require => [Exec["apt-get update"]], 
  ensure => present,
}

exec { "apt-get update":
    command => "/usr/bin/apt-get update",
    onlyif => "/bin/sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null'",
    require => [File["10gen.list"], File["opengeo.list"]],
}

exec { "restart_postgres":
    command => "/usr/bin/touch /etc/postgresql/8.4/main/pg_hba.conf",
    require => Package["opengeo-postgis"],
}

service { "postgresql-8.4":
    subscribe => File["host_auth_file"],
    ensure  => "running",
    enable  => "true",
    require => Package["opengeo-postgis"],
}

file { "host_auth_file":
    path => "/etc/postgresql/8.4/main/pg_hba.conf",
}

file { "/etc/postgresql/8.4/main/pg_hba.conf.orig":
    ensure => "absent",
    require => Package["opengeo-postgis"],
}

file { "10gen.list":
    path    => "/etc/apt/sources.list.d/10gen.list", 
    ensure  => present,
    owner   => "root",
    group   => "root",
    mode    => 0644,
    replace => false,
    content => "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen",
    require => Exec["mongo_repokey"],
} 

file { "opengeo.list":
    path    => "/etc/apt/sources.list.d/opengeo.list", 
    ensure  => present,
    owner   => "root",
    group   => "root",
    mode    => 0644,
    replace => false,
    content => "deb http://apt.opengeo.org/ubuntu lucid main",
    require => Exec["opengeo_repokey"],
} 

exec { "opengeo_repokey":
    command => "wget -qO- http://apt.opengeo.org/gpg.key | apt-key add -",
    path    => "/usr/local/bin/:/bin/:/usr/bin/",
}

exec { "mongo_repokey":
    command => "/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10",
    path    => "/usr/local/bin/:/bin/:/usr/bin/",
}
