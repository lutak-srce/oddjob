#
# = Class: oddjob
#
# This class manages OddJob daemon
#
#
# == Parameters
#
# [*ensure*]
#   Type: string, default: 'present'
#   Manages package installation and class resources. Possible values:
#   * 'present' - Install package, ensure files are present (default)
#   * 'absent'  - Stop service and remove package and managed files
#
# [*package*]
#   Type: string, default on $::osfamily basis
#   Manages the name of the package.
#
# [*version*]
#   Type: string, default: undef
#   If this value is set, the defined version of package is installed.
#   Possible values are:
#   * 'x.y.z' - Specific version
#   * latest  - Latest available
#
# [*dependency_class*]
#   Type: string, default: undef
#   Name of a custom class to autoload to manage module's dependencies
#
# [*my_class*]
#   Type: string, default: undef
#   Name of a custom class to autoload to manage module's customizations
#
# [*noops*]
#   Type: boolean, default: undef
#   Set noop metaparameter to true for all the resources managed by the module.
#   If true no real change is done is done by the module on the system.
#
class oddjob (
  $ensure            = $::oddjob::params::ensure,
  $package           = $::oddjob::params::package,
  $package_mkhomedir = $::oddjob::params::package_mkhomedir,
  $service           = $::oddjob::params::service,
  $service_ensure    = 'running',
  $service_enable    = true,
  $version           = $::oddjob::params::version,
  $dependency_class  = $::oddjob::params::dependency_class,
  $my_class          = $::oddjob::params::my_class,
  $noops             = undef,
) inherits oddjob::params {

  ### Input parameters validation
  validate_re($ensure, ['present','absent'], 'Valid values are: present, absent')
  validate_string($package)
  validate_string($version)

  ### Internal variables (that map class parameters)
  if $ensure == 'present' {
    $package_ensure = $version ? {
      ''      => 'present',
      default => $version,
    }
    $file_ensure = present
  } else {
    $package_ensure = 'absent'
    $file_ensure    = absent
  }

  ### Extra classes
  if $dependency_class { include $dependency_class }
  if $my_class         { include $my_class         }

  package { 'oddjob':
    ensure => $package_ensure,
    name   => $package,
    noop   => $noops,
  }

  package { 'oddjob-mkhomedir':
    ensure => $package_ensure,
    name   => $package_mkhomedir,
    noop   => $noops,
  }

  service { 'oddjob':
    ensure  => $service_ensure,
    enable  => $service_enable,
    name    => $service,
    require => [
      Package['oddjob', 'oddjob-mkhomedir'],
      Service['messagebus'],
    ],
  }

}
# vi:syntax=puppet:filetype=puppet:ts=4:et:nowrap:
