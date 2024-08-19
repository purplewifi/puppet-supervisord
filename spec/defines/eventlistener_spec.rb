require 'spec_helper'

describe 'supervisord::eventlistener', type: :define do
  let(:title) { 'foo' }
  let(:facts) { { concat_basedir: '/var/lib/puppet/concat' } }
  let(:default_params) do
    {
      command: 'bar',
      process_name: '%(process_num)s',
      events: ['PROCESS_STATE', 'PROCESS_STATE_STARTING'],
      buffer_size: 10,
      numprocs: '1',
      numprocs_start: '0',
      priority: '999',
      autostart: true,
      autorestart: 'unexpected',
      startsecs: '1',
      startretries: '3',
      exitcodes: '0,2',
      stopsignal: 'TERM',
      stopwaitsecs: '10',
      stopasgroup: true,
      killasgroup: true,
      user: 'baz',
      redirect_stderr: true,
      stdout_logfile: 'eventlistener_foo.log',
      stdout_logfile_maxbytes: '50MB',
      stdout_logfile_backups: '10',
      stdout_events_enabled: true,
      stderr_logfile: 'eventlistener_foo.error',
      stderr_logfile_maxbytes: '50MB',
      stderr_logfile_backups: '10',
      stderr_events_enabled: true,
      event_environment: { 'env1' => 'value1', 'env2' => 'value2' },
      directory: '/opt/supervisord/chroot',
      umask: '022',
      serverurl: 'AUTO'
    }
  end

  context 'default' do
    let(:params) { default_params }

    it { is_expected.to contain_supervisord__eventlistener('foo') }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{\[eventlistener:foo\]}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{command=bar}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{process_name=\%\(process_num\)s}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{events=PROCESS_STATE,PROCESS_STATE_STARTING}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{buffer_size=10}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{numprocs=1}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{numprocs_start=0}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{priority=999}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{autostart=true}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{startsecs=1}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{startretries=3}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{exitcodes=0,2}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{stopsignal=TERM}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{stopwaitsecs=10}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{stopasgroup=true}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{killasgroup=true}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{user=baz}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{redirect_stderr=true}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{stdout_logfile=/var/log/supervisor/eventlistener_foo.log}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{stdout_logfile_maxbytes=50MB}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{stdout_logfile_backups=10}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{stdout_events_enabled=true}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{stderr_logfile=/var/log/supervisor/eventlistener_foo.error}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{stderr_logfile_maxbytes=50MB}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{stderr_logfile_backups=10}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{stderr_events_enabled=true}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{environment=env1='value1',env2='value2'}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{directory=/opt/supervisord/chroot}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{umask=022}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{serverurl=AUTO}) }
  end

  context 'ensure_process_stopped' do
    let(:params) { default_params.merge({ ensure_process: 'stopped' }) }

    it { is_expected.to contain_supervisord__supervisorctl('stop_foo') }
  end

  context 'ensure_process_removed' do
    let(:params) { default_params.merge({ ensure_process: 'removed' }) }

    it { is_expected.to contain_supervisord__supervisorctl('remove_foo') }
  end

  context 'change_process_name_on_numprocs_gt_1' do
    let(:params) do
      {
        command: 'bar',
        numprocs: '2',
      }
    end

    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{numprocs=2}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{process_name=\%\(program_name\)s_\%\(process_num\)02d}) }
  end

  context 'absolute_log_paths' do
    let(:params) do
      default_params.merge({
                             stdout_logfile: '/path/to/program_foo.log',
      stderr_logfile: '/path/to/program_foo.error',
                           })
    end

    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{stdout_logfile=/path/to/program_foo.log}) }
    it { is_expected.to contain_file('/etc/supervisor.d/eventlistener_foo.conf').with_content(%r{stderr_logfile=/path/to/program_foo.error}) }
  end
end
