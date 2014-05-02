# Moonshine PDFKit

### A plugin for [Moonshine](http://github.com/railsmachine/moonshine)

Moonshine PDFKit provides simple installation and configuration management
for [PDFKit](https://github.com/jdpace/PDFKit).

For a more in-depth look at how the plugin works, please take a look at
[the documentation](http://railsmachine.github.com/moonshine_pdfkit/).

### Instructions

* <tt>script/plugin install git://github.com/railsmachine/moonshine_pdfkit.git</tt>
* Configure settings in the manifest if desired:

    configure(
      :pdfkit => {
        :version => '0.5.0'
      },
      :wkhtmltopdf => {
        :version => '0.9.6'
      }
    )

* Include the plugin and recipe(s) you want to use in your Moonshine manifest.
    recipe :pdfkit
    
***

Unless otherwise specified, all content copyright &copy; 2014, [Rails Machine, LLC](http://railsmachine.com)
