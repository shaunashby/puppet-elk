require 'spec_helper'

describe 'elk' do
  on_supported_os.each do |os,facts|
    context "on OS #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

    end # each OS
  end # supported OS
end
