require 'spec_helper'

describe 'hash2csv' do
  it { is_expected.to run.with_params({ 'key1' => 'value1' }).and_return("key1='value1'") }
  it { is_expected.to run.with_params({ 'key1' => 'value1', 'key2' => 'value2' }).and_return("key1='value1',key2='value2'") }
  it { is_expected.to run.with_params('foo').and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError) }
end
