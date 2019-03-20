# The following specs are testing the compatibility of the IAR version in question
# against known test cases.
# The purpose of this is to watch for changes and inconsistencies in the behavior
# of IAR's utilities and flag any failures.

# These are not the class' behavioral regressions. Please see ... for those.
# invalid IAR install

# The below matcher is a very long-winded one to check that the result is
# exactly as expected. Various changes between IAR versions can potentially
# mess this up, so we want an exhaustive (overly so) matcher to pinpoint what
# is different and where it occurred.
# Failure to catch these differences can lead to incorrect build results and
# usually Ruby stack trace errors for the end user.
RSpec.shared_examples('match_build_result') do |failured_at:, output_text:, output_location: |
  failure_messages = []

  expect(cleaned?).to be(true)
  unless result.completed?
    failure_messages << 'iarbuild failed to complete'
  end

  if failed_at == :none
    # No failure is expected
    unless  result.success? == true
      failure_message << "Expected result.success? to be true. Received: #{result.success?}"
    end

    unless result.preprocessed?
      failure_message << "Expected result.preprocessesd? to be true. Received: #{result.preprocessed?}"
    end
    unless result.assembled?
      failure_message << "Expected result.assembed? to be true. Received: #{result.assembled?}"
    end
    unless result.compiled?
      failure_message << "Expected result.compiled? to be true. Received: #{result.compiled?}"
    end
    unless result.linked?
      failure_message << "Expected result.linked? to be true. Received: #{result.linked?}"
    end

  elsif failed_at == :preprocesor
  elsif failed_at == :assembler
  elsif failed_at == :compiler
  elsif failed_at == :linker
  else
    fail "Unknown :failed_at option: #{failed_at}"
  end

  # Check the error contents
  if failed_at == :none
    # No fail expected, so error logs should all be empty
    unless result.errors?
    end

    unless result.errors.empty?
    end

    unless result.errors_from[:preprocessor]
    end
    unless result.errors_from[:assembler]
    end
    unless result.errors_from[:compiler]
    end
    unless result.errors_from[:linker]
    end

  else
  end

  if warnings.emtpy?
    # No warnings were expected
  else
  end

  if messages.empty?
    # No messages were expected
  else
  end

  if deprecation_warnings.empty?
    # No deprecation warnings were expected
    if result.deprecation_warnings?
    end

    unless result.deprecation_warnings.empty?
    end
  else
  end

  # Check the output. No matter the result, the directory should be built

  # Now, depending on the result, the output may or may not be there
  if failed_at?(:none)
    # Build should have passed. Check for the output directory and the
    # output itself
    unless Dir.exist?(result.output_dir)
    end

    unless File.exist?(result.output)
    end
  else
    # Build failed. Check that the result was not built.
  end

  # Check that the output text is as expected
  # Regardless of build result, we should see this

  # Check that the list of files is as expected
  # Regardless of build result, we should see this

  expect(result.output_text).to eql()

  expect(result.files).to eql([])
end

# A custom matcher to check the build result of iarbuild.
# Provides more details on where the fails occurred and possible related
# errors (e.g., if a linker fail wasn't expected but occurred, the linker's
# output would be nice to have).
# This still allows a single test to cover a lot of ground and reduce the
# overall test count and output to something more reasonable (especially when
# several drivers are run at once).

RSpec.shared_examples('Utility Spec') do |dir, version_info|
  before :context do
    @iar = RubyIAR::Utilities::IARInstall.new(name: 'Test', dir: 'C:\Program Files (x86)\IAR Systems\Embedded Workbench 8.0')
    version_info = {
      version: '8.22.1',
      major_version: 8,
      minor_version: 22,
      tiny_version: 1,
      iarbuild_offset: 'fail',
      iaridepm_offset: 'fail',
      iarbuild_version: '8.0.14.5326',
      iarbuild_version_text: 'V8.0.14.5326',
      iarbuild_major_version: 8,
      iarbuild_minor_version: 0,
      iarbuild_tiny_version: 14,
      iarbuild_bugfix_version: 5326,
    }
  end

  context "IAR installation at #{dir}" do
    fdescribe 'IAR Install' do
      it 'can recongize an IAR installation' do
        expect(@iar.valid?).to be(true)
      end

      it 'can get the version of the installation directory' do
        expect(@iar.version).to eql(version_info[:version])
      end

      it 'can split the IAR version into major, minor, and tiny release' do
        expect(@iar.major_version).to eql(version_info[:major_version])
        expect(@iar.minor_version).to eql(version_info[:minor_version])
        expect(@iar.tiny_version).to eql(version_info[:tiny_version])
      end

      it 'can find the iarbuild utility' do
        expect(@iar.iarbuild).to eql(version_info[:iarbuild_offset])
        expect(@iar.iarbuild.valid?).to be(true)
      end

      it 'can find the iaridepm utility' do
        expect(@iar.iaridepm).to eql(version_info[:iaridepm_offset])
        expect(@iar.iaridepm.valid?).to be(true)
      end
    end

    describe 'iarbuid' do
      it 'can get the version' do
        expect(@iar.iarbuild.version).to eql(version_info[:iarbuild_version])
      end

      it 'can get the major, minor, tiny, and bugfix versions' do
        expect(@iar.iarbuild.major_version).to eql(version_info[:iarbuild_major_version])
        expect(@iar.iarbuild.minor_version).to eql(version_info[:iarbuild_minor_version])
        expect(@iar.iarbuild.tiny_version).to eql(version_info[:iarbuild_tiny_version])
        expect(@iar.iarbuild.bugfix_version).to eql(version_info[:iarbuild_bugfix_version])
      end

      # The below specs are purposely bypassing the iar toolchain API and using
      # the utlities directly. Having these specs pass opens up the toolchain API
      # to just assuming that these are passing and not needing to wait on IAR
      # for every test.

      context 'With a known working project' do
        it 'can compile a known good project and return a true/false result' do
          result = @iar.iarbuild.build(RubyIAR_Spec.working_project, config: 'Clean')
          expect(result).to match_build_result
        end

        it 'returns any info statements' do
          result = @iar.iarbuild.build(RubyIAR_Spec.working_project, config: 'Messages')
          expect(result).to match_build_result
        end

        it 'returns any warnings' do
          result = @iar.iarbuild.build(RubyIAR_Spec.working_project, config: 'Warnings')
          expect(result).to match_build_result
        end

        # Builds:::
        # deprecation
        # OneOfEach_DifferentComponent
        # TwoOfEach_EachComponent

        it 'can build a project'

        it 'can make a project'

        it 'can clean a project'

        it 'can build multiple configs, returning the output of each'

        it 'can build all the configs, returning the output of each'
      end

      context 'with a failing project' do
        it 'can attempt to build a failing project'

        it 'can log all info, warnings, and errors separatly'

        it 'can catch compilation errors'

        it 'can catch preprocessing errors'

        it 'can catch link errors'

        it 'can catch assembler errors'

        it 'can show the entire build log'

        it 'creates log files for failing projects'

        it 'can build both passing and failing configs simultaneously'

        it 'can return the locations of the various outputs'
      end

      context 'with no current project' do
        it 'can create a new .eww'

        it 'can create a new .ewp'

        it 'can build from this new .ewp'

        it 'can add another config'

        it 'can build this config'

        it 'can build both configs and return their outputs'

        describe 'General Options Configurations' do
          it 'can return the location of the output'

          it 'can change the location of the output'

          it 'can change the target core'

          it 'can change the target device'

          it 'can select between the target core and target device'

          it 'can select between compiling to a library and compiling to a executable'

          it 'can change the output library/executable directory'

          it 'can change the object file output directory'

          it 'can change the list files output directory'
        end

        describe 'C/C++ Compiler Configuration' do
          it 'can add a preprocesor define'

          it 'can add a preprocessor path'

          it 'can include a pre-include file'

          it 'can enable/disable ignoring standard include directories'
        end

        describe 'Linker Configuration' do
          it 'can add a linker define'

          it 'can change the linker file'

          it 'can define symbols'

          it 'can add additional libraries'

          it 'can override the default entry symbol'
        end

        describe 'Assmebler Configuration' do
          it 'can include additional directories'

          it 'can define symbols'
        end

        describe 'Output Converter' do
          it 'can override the default output name'

          it 'can change the output type to s-record'

          it 'can change the output type to exe'

          it 'can change the output type to extended-hex'

          it 'can change the output type to TI-TXT'

          it 'can change the output type to simple-code'
        end

        describe 'Project File Configuration' do
          it 'can add a new project file'

          it 'can add a new project group, with files'

          it 'can exclude a project file'

          it 'can exclude a project file inside of a group'

          it 'can exclude a entire project group'

          it 'can create nested groups'

          it 'can exclude nested groups'
        end

      end
    end
  end
end
