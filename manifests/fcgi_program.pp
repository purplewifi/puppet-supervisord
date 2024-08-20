# Define: supervisord::fcgi_program
#
# This define creates an eventlistener configuration file
#
# Documentation on parameters available at:
# http://supervisord.org/configuration.html#fcgi-program-x-section-settings
#
define supervisord::fcgi_program (
  $command,
  $socket,
  $ensure                  = present,
  $ensure_process          = 'running',
  $cfgreload               = undef,
  $socket_owner            = undef,
  $socket_mode             = undef,
  $env_var                 = undef,
  $process_name            = undef,
  $numprocs                = undef,
  $numprocs_start          = undef,
  $priority                = undef,
  $autostart               = undef,
  $autorestart             = undef,
  $startsecs               = undef,
  $startretries            = undef,
  $exitcodes               = undef,
  $stopsignal              = undef,
  $stopwaitsecs            = undef,
  $stopasgroup             = undef,
  $killasgroup             = undef,
  $user                    = undef,
  $redirect_stderr         = undef,
  $stdout_logfile          = "fcgi-program_${name}.log",
  $stdout_logfile_maxbytes = undef,
  $stdout_logfile_backups  = undef,
  $stdout_capture_maxbytes = undef,
  $stdout_events_enabled   = undef,
  $stderr_logfile          = "fcgi-program_${name}.error",
  $stderr_logfile_maxbytes = undef,
  $stderr_logfile_backups  = undef,
  $stderr_capture_maxbytes = undef,
  $stderr_events_enabled   = undef,
  $environment             = undef,
  $program_environment     = undef,
  $directory               = undef,
  $umask                   = undef,
  $serverurl               = undef,
  $config_file_mode        = '0644'
) {
  include supervisord

  # parameter validation
  assert_type(String, $command)
  if $cfgreload { assert_type(Boolean, $cfgreload) }
  if $process_name { assert_type(String, $process_name) }
  if $exitcodes { assert_type(String, $exitcodes) }
  if $stopasgroup { assert_type(Boolean, $stopasgroup) }
  if $killasgroup { assert_type(Boolean, $killasgroup) }
  if $user { assert_type(String, $user) }
  if $redirect_stderr { assert_type(Boolean, $redirect_stderr) }
  assert_type(String, $stdout_logfile)
  if $stdout_logfile_maxbytes { assert_type(String, $stdout_logfile_maxbytes) }
  if $stdout_capture_maxbytes { assert_type(String, $stdout_capture_maxbytes) }
  if $stdout_events_enabled { assert_type(Boolean, $stdout_events_enabled) }
  assert_type(String, $stderr_logfile)
  if $stderr_logfile_maxbytes { assert_type(String, $stderr_logfile_maxbytes) }
  if $stderr_capture_maxbytes { assert_type(String, $stderr_capture_maxbytes) }
  if $stderr_events_enabled { assert_type(Boolean, $stderr_events_enabled) }
  if $directory { assert_type(String, $directory) }

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
  if $environment { notify { '[supervisord] *** DEPRECATED WARNING ***: $program_environment has replaced $environment': } }
  $_program_environment = $program_environment ? {
    undef   => $environment,
    default => $program_environment
  }

  # convert environment data into a csv
  if $env_var {
    $env_hash = hiera_hash($env_var)
    assert_type(Hash, $env_hash)
    $env_string = hash2csv($env_hash)
  }
  elsif $_program_environment {
    assert_type(Hash, $_program_environment)
    $env_string = hash2csv($_program_environment)
  }

  # Reload default with override
  $_cfgreload = $cfgreload ? {
    undef   => $supervisord::cfgreload_fcgi_program,
    default => $cfgreload
  }

  $conf = "${supervisord::config_include}/fcgi-program_${name}.conf"

  file { $conf:
    ensure  => $ensure,
    owner   => 'root',
    mode    => $config_file_mode,
    content => template('supervisord/conf/fcgi_program.erb'),
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
