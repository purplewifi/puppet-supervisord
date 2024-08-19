require 'spec_helper'

describe 'supervisord::group', type: :define do
  let(:title) { 'foo' }
  let(:params) { { programs: ['bar', 'baz'] } }
  let(:facts) { { concat_basedir: '/var/lib/puppet/concat' } }

  it { is_expected.to contain_supervisord__group('foo').with_program }
  it { is_expected.to contain_file('/etc/supervisor.d/group_foo.conf').with_content(%r{programs=bar,baz}) }

  describe '#priority' do
    it 'defaults to undef' do
      is_expected.not_to contain_file('/etc/supervisor.d/group_foo.conf').with_content(%r{priority})
      is_expected.to contain_file('/etc/supervisor.d/group_foo.conf').with_content(%r{programs=bar,baz})
    end
    context '100' do
      let(:params) { { priority: '100', programs: ['bar', 'baz'] } }

      it { is_expected.to contain_file('/etc/supervisor.d/group_foo.conf').with_content(%r{priority=100}) }
      it { is_expected.to contain_file('/etc/supervisor.d/group_foo.conf').with_content(%r{programs=bar,baz}) }
    end
  end
end
