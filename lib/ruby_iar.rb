require 'colored'
require 'nokogiri/xml/element'
require 'ruby_iar/driver'

# The top namespace.
# @note To avoid common typos, <code>RubyIAR</code> has an <code>RubyIar</code> alias.
module RubyIAR
  def log(message, type:)
  end

  # RubyIAR can store a 'global', or 'general', driver to be used by various plugins.
  # That is, somewthing upstream can call RubyIAR.install(...) with the necessary options to setup the
  # toolchain, or a default one can be given.
  # This just allows the entire process to share the same installation on the RubyIAR module (that is, 
  # in a known location)
  # If this setup is not desired, use #_install_ instead (or the full namespaced RubyIAR::IarInstallation.new(...))
  # to get a standalone instance.
  # @raise If an installation was already defined, passing in the name: or dir: options is not allowed. Use #install! to re-initialize.
  def install(name:, dir: nil)
  end

  # Forces a reinitialization of the installation object.
  def install!(name:, dir: nil)
  end

  def self.driver(name: nil, dir: nil, **options)
    if @driver && (name || dir)
      self.fail("RubyIAR already has a driver initialized. Using the :name and :dir options is not allowed! Please use #RubyIAR.driver! if a reinitialization is desired.")
    elsif driver.nil?
      @driver = driver!(name, dir)
    end
    @driver
  end

  def self.driver!(name: nil, dir: nil)
    self.new(name, dir)
  end

  # Shortcut method to create a new RubyIAR::Driver object.
  def self.new(**options)
    RubyIAR::Driver.new(options)
  end

  def self.create_workspace(ws, options = {})
    RubyIAR::Driver::Workspace.create_workspace(ws, options)
  end
end
RubyIar = RubyIAR
