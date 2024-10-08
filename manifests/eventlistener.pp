# Define: supervisord::eventlistener
#
# This define creates an eventlistener configuration file
#
# Documentation on parameters available at:
# http://supervisord.org/configuration.html#eventlistener-x-section-settings
#
define supervisord::eventlistener (
  String $command,
  $ensure                  = present,
  Enum['running', 'stopped', 'removed', 'unmanaged'] $ensure_process          = 'running',
  Optional[Boolean] $cfgreload               = undef,
  Numeric $buffer_size             = 10,
  Optional[Array] $events                  = undef,
  Optional[String] $result_handler          = undef,
  Optional[String] $env_var                 = undef,
  Optional[String] $process_name            = undef,
  Optional[Numeric] $numprocs                = undef,
  Optional[Numeric] $numprocs_start          = undef,
  Optional[Numeric] $priority                = undef,
  Optional[Boolean] $autostart               = undef,
  Optional[Boolean] $autorestart             = undef,
  Optional[Numeric] $startsecs               = undef,
  Optional[Numeric] $startretries            = undef,
  Optional[String] $exitcodes               = undef,
  Optional[Enum['TERM', 'HUP', 'INT', 'QUIT', 'KILL', 'USR1', 'USR2']] $stopsignal              = undef,
  Optional[Numeric] $stopwaitsecs            = undef,
  Optional[Boolean] $stopasgroup             = undef,
  Optional[Boolean] $killasgroup             = undef,
  Optional[String] $user                    = undef,
  Optional[Boolean] $redirect_stderr         = undef,
  String $stdout_logfile          = "eventlistener_${name}.log",
  Optional[String] $stdout_logfile_maxbytes = undef,
  Optional[Numeric] $stdout_logfile_backups  = undef,
  Optional[Boolean] $stdout_events_enabled   = undef,
  String $stderr_logfile          = "eventlistener_${name}.error",
  Optional[String] $stderr_logfile_maxbytes = undef,
  Optional[Numeric] $stderr_logfile_backups  = undef,
  Optional[Boolean] $stderr_events_enabled   = undef,
  Optional[Hash] $event_environment       = undef,
  Optional[String] $directory               = undef,
  Optional[String] $umask                   = undef,
  Optional[String] $serverurl               = undef,
  Optional[String] $config_file_mode        = '0644'
) {
  include supervisord

  # create the correct log variables
  $stdout_logfile_path = $stdout_logfile ? {
    /(NONE|AUTO|syslog)/ => $stdout_logfile,
    /^\//                => $stdout_logfile,
    default              => "${supervisord::log_path}/${stdout_logfile}",
  }

  $stderr_logfile_path = $stderr_logfile ? {
    /(NONE|AUTO|syslog)/ => $stderr_logfile,
    /^\//                => $stderr_logfile,
    default              => "${supervisord::log_path}/${stderr_logfile}",
  }

  # Handle deprecated $environment variable
  $_event_environment = $event_environment ? {
    undef   => $environment,
    default => $event_environment
  }

  # convert environment data into a csv
  if $env_var {
    $env_hash = lookup($env_var)
    assert_type(Hash, $env_hash)
    $env_string = hash2csv($env_hash)
  }
  elsif $_event_environment {
    $env_string = hash2csv($_event_environment)
  }

  # Reload default with override
  $_cfgreload = $cfgreload ? {
    undef   => $supervisord::cfgreload_eventlistener,
    default => $cfgreload
  }

  if $events {
    $events_string = array2csv($events)
  }

  $conf = "${supervisord::config_include}/eventlistener_${name}.conf"

  file { $conf:
    ensure  => $ensure,
    owner   => 'root',
    mode    => $config_file_mode,
    content => template('supervisord/conf/eventlistener.erb'),
  }

  if $_cfgreload {
    File[$conf] {
      notify => Class['supervisord::reload'],
    }
  }

  case $ensure_process {
    'stopped': {
      supervisord::supervisorctl { "stop_${name}":
        command => 'stop',
        process => $name,
      }
    }
    'removed': {
      supervisord::supervisorctl { "remove_${name}":
        command => 'remove',
        process => $name,
      }
    }
    'running': {
      supervisord::supervisorctl { "start_${name}":
        command => 'start',
        process => $name,
        unless  => 'running',
      }
    }
    default: {}
  }
}
