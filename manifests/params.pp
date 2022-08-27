#
# = Class: oddjob::params
#
# This class provides defaults for oddjob
#
class oddjob::params {
  $ensure           = 'present'
  $version          = undef

  # install package depending on major version
  case $::osfamily {
    default: {}
    /(RedHat|redhat|amazon)/: {
      $package           = 'oddjob'
      $package_mkhomedir = 'oddjob-mkhomedir'
      $service           = 'oddjobd'
    }
    /(debian|ubuntu)/: {
      $package           = undef
      $package_mkhomedir = undef
      $service           = undef
    }
  }

}
