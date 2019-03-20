require_relative 'utility_spec'

RSpec.describe 'RubyIAR' do
  describe 'IAR Driver' do
    include_examples('Utility Spec', 'C:\Program Files (x86)\IAR Systems\Embedded Workbench 8.0\common\bin')
  end
end
