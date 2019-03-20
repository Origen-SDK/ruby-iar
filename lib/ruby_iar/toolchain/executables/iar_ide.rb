module RubyIAR
  module Toolchain
  module Executables
    require_relative './base'

    # Handles verifying and opening the IarIDE (IarIdePm.exe).
    class IarIDE < Base
      def initialize(install:, **options)
        @executable_name = 'iaridepm'
        @installation_offset = Pathname('common/bin')
        super
      end

      # The IarIDE iteslf has no version command, so just reference whatever
      # version the parent installation is
      #def verion!
      #  @version = install.version
      #end
    end
    IARIDE = IarIDE
    IARIde = IarIDE
    IarIde = IarIDE
  end
  end
end