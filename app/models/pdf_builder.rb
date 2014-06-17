# encoding: utf-8

class PdfBuilder
  require "prawn"

  attr_accessor :file, :filename, :file_path, :doc, :doc_attrs

  def initialize(doc = nil)
    self.doc = doc
    return false unless @doc
    self.filename = "#{@doc.name}.pdf"
    self.file_path = "/tmp/#{sanitize_filename @doc.name}.pdf"
    self.doc_attrs = build_source_data
    self.file = generate
  end

  private

  def sanitize_filename(filename)
    name = filename.to_s.strip
    name.gsub!(/(\\|\/)/, '|')
    name.gsub!(/[\.\-\s]/, '_')
    name
  end

  def build_source_data
    result = {}
    attrs = doc.attributes
    doc.doc_lines.each{|l| result[l.name.to_sym] = l.value unless l.name.blank? or l.value.blank? }

    attrs.each do |key, value|
      alt_key = nil
      val = case key
      when "_id"
        value.to_s
      when "state"
        I18n.t(value)
      when "executor_id", "sender_id", "user_id"
        alt_key = key[0...-3]
        User.where(id: value).first.try(:name)
      when "name", "department", "in_num", "out_num"
        value
      end
      result[(alt_key || "d/#{key}").to_sym] = val unless val.nil?
    end

    return result
  end

# align: :left(default),:right,:center, :justify.
# valign: :top(default),:center, :bottom
  def stock_fields
    doc = self.doc
    Prawn::Document.generate(file_path) do
      font_families.update(
        "Verdana" => {
          :bold => "#{Rails.root}/vendor/fonts/verdanab.ttf",
          :italic => "#{Rails.root}/vendor/fonts/verdanai.ttf",
          :normal  => "#{Rails.root}/vendor/fonts/verdana.ttf"
        },
        "FreeMono" => {
          :normal  => "#{Rails.root}/vendor/fonts/FreeMono.ttf",
          :bold => "#{Rails.root}/vendor/fonts/FreeMonoBold.ttf",
          :italic => "#{Rails.root}/vendor/fonts/FreeMonoOblique.ttf",
          :bold_italic  => "#{Rails.root}/vendor/fonts/FreeMonoBoldOblique.ttf"
        })
      font "Verdana", :size => 12
      default_leading 10


      text_box doc.name, align: :justify, width: 200, at: [300, cursor], size: 16; move_down 150
      text doc.doc_type.name, align: :center, size:18, style: :bold; move_down 20

      %w(in_num out_num department).each{|param| formatted_text [{ text: "#{I18n.t(param, scope: 'mongoid.attributes.doc')}: ", styles: [:bold] }, { text: doc.send(param) }] ; move_down 10}

      formatted_text [{ text: "#{I18n.t('state',scope: 'mongoid.attributes.doc')}: ", styles: [:bold] }, { text: I18n.t(doc.state) }]; move_down 10
      text "sender, responsible?"; move_down 10

      doc.doc_lines.each{|line| formatted_text [{ text: "#{line.name}: ", styles: [:bold] }, { text: line.value }]; move_down 10 }
    end
  end

  def custom_fields
    doc = self.doc
    doc_attrs = self.doc_attrs
    settings = doc.doc_type.print_settings
    Prawn::Document.generate(file_path) do
      font_families.update(
        "Verdana" => {
          :normal  => "#{Rails.root}/vendor/fonts/verdana.ttf",
          :bold => "#{Rails.root}/vendor/fonts/verdanab.ttf",
          :italic => "#{Rails.root}/vendor/fonts/verdanai.ttf"
        },
        "FreeMono" => {
          :normal  => "#{Rails.root}/vendor/fonts/FreeMono.ttf",
          :bold => "#{Rails.root}/vendor/fonts/FreeMonoBold.ttf",
          :italic => "#{Rails.root}/vendor/fonts/FreeMonoOblique.ttf",
          :bold_italic  => "#{Rails.root}/vendor/fonts/FreeMonoBoldOblique.ttf"
        }
      )
      default_leading 10

=begin
{
  "head"=>{"head"=>"1", "position"=>"centered", "font_size"=>"11", "case"=>"up", "text"=>"Начальнику отдела 521\r\nВ. П. Жуковой"},
  "title"=>{"title"=>"1", "font_size"=>"12", "case"=>"up", "text"=>"<b>Служебная записка</b>. Вот"},
  "body"=>{"body"=>"1", "font_size"=>"9", "case"=>"original", "text"=>"Прошу ввести в эксплуатацию по причине: \"%{Основание}\""}
}
{
  head: {
    positions: {right: "Справа", centered: "По центру", centered_in_width: "По центру по ширине", left: "Слева"},
    cases: {original: "Оригинальный", up: "ВЕРХНИЙ", down: "нижний"}
  },
  title: {
    cases: {original: "Оригинальный", up: "ВЕРХНИЙ"}
  },
  body: {
    cases: {original: "Оригинальный", up: "ВЕРХНИЙ"}
  },
  footer: {

  }
}
=end


      # Шапка

      head_settings = settings["head"] || {}
      unless head_settings.blank? or !head_settings.is_a?(Hash)
        font "FreeMono", :size => head_settings["font_size"].to_i || 10
        head_text = case head_settings["case"]
        when "up"
          (head_settings["text"] % doc_attrs)#.upcase
        when "down"
          (head_settings["text"] % doc_attrs)#.downcase
        else
          head_settings["text"] % doc_attrs
        end

        case head_settings["position"]
        when "right"
          text_box head_text, align: :justify, width: 200, at: [300, cursor], inline_format: true
        when "left"
          text_box head_text, align: :justify, width: 200, at: [0, cursor], inline_format: true
        when "centered"
          text_box head_text, align: :center, width: 500, at: [0, cursor], inline_format: true
          # text_box head_text, align: :center, inline_format: true
        when "centered_in_width"
          text_box head_text, align: :justify, width: 500, at: [0, cursor], inline_format: true
        end
        move_down 50
      end

      # Заголовок

      title_settings = settings["title"] || {}
      unless title_settings.blank? or !title_settings.is_a?(Hash)
      # text title_settings.inspect; move_down 20;
        font "FreeMono", :size => title_settings["font_size"].to_i || 12
        title_text = case title_settings["case"]
        when "up"
          (title_settings["text"] % doc_attrs)#.upcase
        else
          title_settings["text"] % doc_attrs
        end
        text title_text, align: :center, inline_format: true; move_down 30
      end

      # Тело

      body_settings = settings["body"] || {}
      unless body_settings.blank? or !body_settings.is_a?(Hash)
        font "FreeMono", :size => body_settings["font_size"].to_i || 10
        body_text = case body_settings["case"]
        when "up"
          (body_settings["text"] % doc_attrs)#.upcase
        else
          body_settings["text"] % doc_attrs
        end
        text body_text, align: :left, inline_format: true; move_down 30
      end

        text "колонтитул временно отсутствует", inline_format: true
      # Н колонтитул
    end
  end

  def generate
    doc.doc_type.print_settings.blank? ? stock_fields() : custom_fields()
    # custom_fields
    File.open(file_path)
  end
end
