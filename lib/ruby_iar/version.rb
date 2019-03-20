module RubyIAR
  class Version
    MAJOR = 0 unless defined? Gems::Version::MAJOR
    MINOR = 1 unless defined? Gems::Version::MINOR
    PATCH = 0 unless defined? Gems::Version::PATCH
    PRE = 0 unless defined? Gems::Version::PRE

    class << self
      # @return [String]
      def to_s
        [MAJOR, MINOR, PATCH, PRE].compact.join('.')
      end
    end
  end

  VERSION = Version.to_s
end