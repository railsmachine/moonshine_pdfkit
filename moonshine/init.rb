# **init.rb** is automatically loaded by recent versions of Moonshine


# We require our plugin.
require "#{File.dirname(__FILE__)}/../lib/moonshine/pdfkit.rb"

# Then, we include it.
include Moonshine::PDFKit
