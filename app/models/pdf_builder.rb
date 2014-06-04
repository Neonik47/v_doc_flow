# encoding: utf-8

class PdfBuilder
  require "prawn"

  attr_accessor :file, :filename, :file_path, :doc

  def initialize(doc = nil)
    self.doc = doc
    return false unless @doc
    self.filename = "#{@doc.name}.pdf"
    self.file_path = "/tmp/#{sanitize_filename @doc.name}.pdf"
    self.file = generate
  end

  private

  def sanitize_filename(filename)
    name = filename.to_s.strip
    name.gsub!(/(\\|\/)/, '|')
    name.gsub!(/[\.\-\s]/, '_')
    name
  end

# align: :left(default),:right,:center, :justify.
# valign: :top(default),:center, :bottom

  def generate
    # unless File.exist?(file_path)
      doc = self.doc
      Prawn::Document.generate(file_path) do
        font_families.update(
          "Verdana" => {
            :bold => "#{Rails.root}/vendor/fonts/verdanab.ttf",
            :italic => "#{Rails.root}/vendor/fonts/verdanai.ttf",
            :normal  => "#{Rails.root}/vendor/fonts/verdana.ttf" })
        font "Verdana", :size => 12


        text_box doc.name, align: :justify, width: 200, at: [300, cursor], size: 16; move_down 150
        text doc.doc_type.name, align: :center, size:18, style: :bold; move_down 20

        %w(in_num out_num department).each{|param| formatted_text [{ text: "#{I18n.t(param, scope: 'mongoid.attributes.doc')}: ", styles: [:bold] }, { text: doc.send(param) }] ; move_down 10}

        formatted_text [{ text: "#{I18n.t('state',scope: 'mongoid.attributes.doc')}: ", styles: [:bold] }, { text: I18n.t(doc.state) }]; move_down 10
        text "sender, responsible?"; move_down 10

        doc.doc_lines.each{|line| formatted_text [{ text: "#{line.name}: ", styles: [:bold] }, { text: line.value }]; move_down 10 }
      end
    # end
    File.open(file_path)
  end
end
