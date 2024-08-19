require 'spec_helper'

describe 'supervisord::supervisorctl', type: :define do
  let(:default_params) do
    {
      command: 'command'
    }
  end

  let(:facts) { { concat_basedir: '/var/lib/puppet/concat' } }

  context 'without process' do
    let(:title) { 'command' }
    let(:params) { default_params }

    it { is_expected.to contain_supervisord__supervisorctl('command') }
    it { is_expected.to contain_exec('supervisorctl_command_command').with_command(%r{supervisorctl command}) }
  end

  context 'with process' do
    let(:title) { 'command_foo' }
    let(:params) { default_params.merge({ process: 'foo' }) }

    it { is_expected.to contain_supervisord__supervisorctl('command_foo') }
    it { is_expected.to contain_exec('supervisorctl_command_command_foo').with_command(%r{supervisorctl command foo}) }
  end
end
