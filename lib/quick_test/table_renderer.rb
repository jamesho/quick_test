module QuickTest
  class TableRenderer
    ALIGN_RIGHT = :rjust
    ALIGN_LEFT = :ljust

    attr_accessor :title
    attr_accessor :left_padding
    attr_accessor :columns
    attr_accessor :column_spacing
    attr_accessor :no_data_output

    def initialize options={}
      self.columns = options[:columns]
      self.no_data_output = options[:no_data_output]
      self.column_spacing = options[:column_spacing] || 3
      self.left_padding = options[:left_padding] || 3
      self.title = options[:title]
    end

    def render_with_data data
      left_padding_string = (' ' * self.left_padding)
      column_spacing_string = (' ' * self.column_spacing)

      puts "\n" + left_padding_string + self.title.to_s.color(:yellow).bright + "\n\n"

      headers = ""
      self.columns.each do |header|
        value = header[0]
        width = header[1] || 100
        alignment = header[2] || ALIGN_LEFT
        headers << value.to_s.send(alignment, width) << column_spacing_string
      end
      puts left_padding_string + headers.color(:blue).bright

      if data.empty?
        puts left_padding_string + self.no_data_output.color(:green)
      end

      data.each do |row|
        line_buffer = ""
        row.each_with_index do |cell, i|
          width = self.columns[i][1] || 100
          alignment = self.columns[i][2] || ALIGN_LEFT

          line_buffer << cell.to_s.send(alignment, width) << column_spacing_string
        end
        puts left_padding_string + line_buffer.color(:green)
      end

      puts "\n"
    end
  end
end
