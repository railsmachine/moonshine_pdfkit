# **Moonshine::PDFKit** is a Moonshine plugin for installing and configuring
# [PDFKit][pk] and [WKHTMLToPDF][wk].

#### Prerequisites

# We need to include any class level methods we need.
# We'll also need to configure some sane defaults for versions of the libraries.
#
# [wk]: http://code.google.com/p/wkhtmltopdf/
# [pk]: https://github.com/jdpace/PDFKit

module Moonshine
  module PDFKit

    def self.included(manifest)
      manifest.class_eval do
        extend ClassMethods
        configure :pdfkit => { :version => '0.5.0' }
        configure :wkhtmltopdf => { :version => '0.9.9' }
      end
    end

    module ClassMethods
    end

#### Recipe

# We define the `:pdfkit` recipe which can take inline options.

    def pdfkit(options = {})

      # We ensure that the [PDFKit][pk] gem is installed, and is either the version
      # the user specified, or the default version
      gem 'pdfkit',
        :ensure => (options[:version] || configuration[:pdfkit][:version]),
        :require => exec('install_wkhtmltopdf')

      recipe :wkhtmltopdf
    end

    def wkhtmltopdf(options = {})

      # [WKHTMLToPDF][wk] is required for [PDFKit][pk] to work.
      # In order to install [WKHTMLToPDFKit][wk], we ensure we have met
      # its dependencies.
      wkhtmltopdf_dependencies = %w(openssl build-essential xorg libssl-dev)
      wkhtmltopdf_dependencies.each do |pkg|
        package pkg, :ensure => :installed
      end

      # [WKHTMLToPDF][wk] provides different binaries depending on the arch, so
      # we use Facter to determine what arch the server is.
      arch = case Facter.value(:architecture)
             when 'x86_64', 'amd64'
               'amd64'
             else
               'i386'
             end

      # [WKHTMLToPDF][wk] is provided in a precompiled tarball.
      #
      # Before attempting to install it, we first check:
      #
      # * If it is currently installed
      # * If it is currently executable
      # * If the installed version is the version we want installed
      #
      # If neither of those conditions are met, then it wasn't installed
      # or configured by this plugin, or the version is not the right one,
      # so we want to install it.
      #
      # The installation process:
      #
      # * Navigates to the /tmp directory
      # * Cleans up any old tarballs
      # * Downloads [WKHTMLToPDF][wk]
      # * Copies the pre-compiled binaries into place
      # * Ensures the binaries are executable

      configured_version = (options[:version] || configuration[:wkhtmltopdf][:version])

      # Some versions / architecture combinations return the incorrect version from `wkhtmltopdf --version`,
      # so we have to work around that. This has happened a few times in the release history, so this may need
      # to be updated in the future if it happens again
      wkhtmltopdf_version_returns = if arch == 'amd64' && configured_version == '0.9.9'
                                       '0.9.6'
                                     else
                                       configured_version
                                     end

      exec 'install_wkhtmltopdf',
        :command => [
          'rm -f wkhtmltopdf*',
          "wget http://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-#{configured_version}-static-#{arch}.tar.bz2",
          "tar xvjf wkhtmltopdf-#{configured_version}-static-#{arch}.tar.bz2",
          "mv wkhtmltopdf-#{arch} /usr/local/bin/wkhtmltopdf",
          'chmod +x /usr/local/bin/wkhtmltopdf'
          ].join(' && '),
        :onlyif => [
          'test ! -x /usr/local/bin/wkhtmltopdf',
          'test "$(which wkhtmltopdf)" != "/usr/local/bin/wkhtmltopdf"',
          %Q{test "$(/usr/local/bin/wkhtmltopdf --version 2>/dev/null | grep wkhtmltopdf | cut -d ' ' -f 4)" != '#{wkhtmltopdf_version_returns}'}
        ].join(' && '),
        :cwd => '/tmp',
        :require => wkhtmltopdf_dependencies.map { |pkg| package(pkg) }
    end

  end
end
