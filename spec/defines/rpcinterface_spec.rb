require 'spec_helper'

describe 'supervisord::rpcinterface', type: :define do
  let(:title) { 'foo' }
  let(:facts) { { concat_basedir: '/var/lib/puppet/concat' } }
  let(:default_params) do
    { rpcinterface_factory: 'bar:baz' }
  end

  context 'default' do
    let(:params) { default_params }

    it { is_expected.to contain_supervisord__rpcinterface('foo') }
    it { is_expected.to contain_file('/etc/supervisor.d/rpcinterface_foo.conf').with_content(%r{\[rpcinterface:foo\]}) }
    it { is_expected.to contain_file('/etc/supervisor.d/rpcinterface_foo.conf').with_content(%r{supervisor\.rpcinterface_factory = bar:baz}) }
    it { is_expected.to contain_file('/etc/supervisor.d/rpcinterface_foo.conf').without_content(%r{retries}) }
  end

  context 'retries' do
    let(:params) { { retries: 2 }.merge(default_params) }

    it { is_expected.to contain_supervisord__rpcinterface('foo') }
    it { is_expected.to contain_file('/etc/supervisor.d/rpcinterface_foo.conf').with_content(%r{\[rpcinterface:foo\]}) }
    it { is_expected.to contain_file('/etc/supervisor.d/rpcinterface_foo.conf').with_content(%r{supervisor\.rpcinterface_factory = bar:baz}) }
    it { is_expected.to contain_file('/etc/supervisor.d/rpcinterface_foo.conf').with_content(%r{retries = 2}) }
  end
end
