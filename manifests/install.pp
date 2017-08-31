class pe_metrics_dashboard::install {

  yumrepo {'influxdb':
    ensure   => present,
    enabled  => 1,
    gpgcheck => 1,
    baseurl  => 'https://repos.influxdata.com/rhel/$releasever/$basearch/stable',
    gpgkey   => 'https://repos.influxdata.com/influxdb.key',
  }

  package {'influxdb':
    ensure  => present,
    require => Yumrepo['influxdb'],
  }

  service {'influxdb':
    ensure  => running,
    require => Package['influxdb'],
  }

  yumrepo { 'grafana-repo':
    ensure        => 'present',
    baseurl       => 'https://packagecloud.io/grafana/stable/el/6/$basearch',
    descr         => 'grafana-repository',
    enabled       => '1',
    repo_gpgcheck => '1',
    gpgcheck      => '1',
    gpgkey        => 'https://packagecloud.io/gpg.key https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana',
    sslverify     => '1',
    sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
  }->

  class { 'grafana':
    install_method => 'repo',
    manage_package_repo => false,
    version => '4.4.3',
  }

  # Configure grafana to use InfluxDB
  grafana_datasource { 'influxdb':
    grafana_url      => 'http://localhost:3000',
    type             => 'influxdb',
    url              => 'http://localhost:8086',
    access_mode      => 'proxy',
    is_default       => true,
    grafana_user     => 'admin',
    grafana_password => 'admin',
    require          => Service['grafana-server'],
  }

}
