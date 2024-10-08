require 'spec_helper'

describe 'supervisord::ctlplugin', type: :define do
  let(:title) { 'foo' }
  let(:facts) { { concat_basedir: '/var/lib/puppet/concat' } }

  context 'default' do
    let(:params) { { ctl_factory: 'bar.baz:make_bat' } }

    it { is_expected.to contain_supervisord__ctlplugin('foo') }
    it {
      is_expected.to contain_concat__fragment('ctlplugin:foo') \
        .with_content(%r{supervisor\.ctl_factory = bar\.baz:make_bat})
    }
  end
end
