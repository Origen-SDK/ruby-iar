## RubyIAR Specs

### The Utility Driver

#### Testing A New IAR Version

The IAR versions available and their paths are dependent on your system setup.
A git-ignored file, <code>iar_version_config.yml</code> can be placed in the
root directory to specify which version of IAR is at what path. A sample
file is available at <code>...</code>. You can also set the environment
variable <code>RUBY_IAR_VERSION_CONFIG</code> to point directly to the
<code>.yml</code> source

If this is a previously seen version of IAR, ruby-iar should be able to find
the corresponding metadata located in <code>...</code>. If so, this will be
looked up and used. If this is a new version not seen before, this will need
to be created and given to ruby-iar.
