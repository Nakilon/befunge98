require_relative '../model/model_attribute_update_string_io'
require 'glimmer/data_binding/observer'

class Befunge98GuiGlimmerDslLibui
  module View
    class AppView
      include Glimmer
      
      COLUMN_COUNT = 30
      ROW_COUNT = 12
      CELL_SIZE = 30
      LAST_PROGRAM = File.expand_path(File.join(Dir.home, '.befunge98'), __dir__)
      SHIFTED_KEYCODE_CHARACTERS = {
        '`' => '~',
        '1' => '!',
        '2' => '@',
        '3' => '#',
        '4' => '$',
        '5' => '%',
        '6' => '^',
        '7' => '&',
        '8' => '*',
        '9' => '(',
        '10' => ')',
        '-' => '_',
        '=' => '+',
        ',' => '<',
        '.' => '>',
        '/' => '?',
        ';' => ':',
        "'" => '"',
        '[' => '{',
        ']' => '}',
        "\\" => '|',
      }
      
      attr_accessor :output_string, :input_string
    
      def initialize
        create_gui
        register_observers
        # load last program
        self.input_string = File.read(LAST_PROGRAM).to_s
      end
  
      def register_observers
        Glimmer::DataBinding::Observer.proc do |new_input_string|
          # save last program
          File.write(LAST_PROGRAM, new_input_string)
          @input_string_entry&.text = new_input_string
          new_input_chars = new_input_string.split("\n").map {|cell_row| cell_row.chars}
          ROW_COUNT.times do |row|
            COLUMN_COUNT.times do |column|
              new_value = (new_input_chars[row] && new_input_chars[row][column]) || ''
              @input_cell_strings[row][column].string = new_value if @input_cell_strings[row][column].string != new_value
            end
          end
        end.observe(self, :input_string)
        Glimmer::DataBinding::Observer.proc do |new_output_string|
          Glimmer::LibUI.queue_main do
            @output_string_entry.text = new_output_string.gsub("\u0000", '')
          end
        end.observe(self, :output_string)
      end
      
      def create_gui
        menu('File') {
          about_menu_item { # Mac default about menu item
            on_clicked do
              display_about_dialog
            end
          }
          quit_menu_item # Mac default quit menu item
          menu_item('Exit') {
            on_clicked do
              exit(0)
            end
          }
        }
        @window = window('Befunge98 GUI (Glimmer DSL for LibUI)', COLUMN_COUNT * CELL_SIZE, ROW_COUNT * CELL_SIZE + 500) {
          margined true
          
          vertical_box {
            input_fields
            
            befunge_grid
            
            output_fields
          }
        }
      end
      
      def input_fields
        vertical_box {
          label('Input') {
            stretchy false
          }
          
          @input_string_entry = non_wrapping_multiline_entry {
            text input_string.to_s

            on_changed do
              self.input_string = @input_string_entry.text
            end
          }
          
          horizontal_box {
            stretchy false
            
            @run_button = button('Run') {
              stretchy false
  
              on_clicked do
                @run_button.enabled = false
                @input_string_entry.read_only = true
                self.output_string = ''
                io = ModelAttributeUpdateStringIO.new(self, :output_string)
                @thread&.kill
                @thread = Thread.new { Befunge98(input_string, io) }
                @stop_button.enabled = true
              end
            }
            
            @stop_button = button('Stop') {
              stretchy false
              enabled false
  
              on_clicked do
                @thread&.kill
                @thread = nil
                @stop_button.enabled = false
                @run_button.enabled = true
                @input_string_entry.read_only = false
              end
            }
          }
        }
      end
      
      def befunge_grid
        vertical_box {
          @input_cell_strings = []
          @input_cell_background_paths = []
          ROW_COUNT.times.map do |row|
            @input_cell_strings << []
            @input_cell_background_paths << []
            horizontal_box {
              COLUMN_COUNT.times.map do |column|
                horizontal_box {
                  area {
                    @input_cell_background_paths[row] << path {
                      rectangle(0, 0, CELL_SIZE, CELL_SIZE)
                      
                      fill :white
                    }
                    text(0, 0) {
                      align :center
                      
                      @input_cell_strings[row] << string('') # empty string attribute on string object
                    }
                    
                    on_mouse_down do |area_mouse_event|
                      select_cell(row, column)
                    end
  
                    on_key_down do |area_key_event|
                      mark_key(area_key_event)
                    end
                  }
                }
              end
            }
          end
        }
      end
      
      def output_fields
        vertical_box {
          label('Output') {
            stretchy false
          }
          
          @output_string_entry = multiline_entry {
            read_only true
          }
        }
      end
      
      def display_about_dialog
        msg_box('About', "Befunge98 GUI (Glimmer DSL for LibUI) #{VERSION}\n\n#{LICENSE}")
      end
      
      def select_cell(row, column)
        return unless @thread.nil?
        @selected_row = row
        @selected_column = column
        @selected_cell_background_path&.fill = :white
        @selected_cell_background_path = @input_cell_background_paths[@selected_row][@selected_column]
        @selected_cell_background_path.fill = :lightgray
      end
      
      def mark_key(area_key_event)
        return unless @thread.nil? && @selected_row && @selected_column
        row = @selected_row
        column = @selected_column
        if area_key_event[:key] == "\n"
          next_column = row != (ROW_COUNT - 1) ? 0 : column
          next_row = row != (ROW_COUNT - 1) ? row + 1 : row
        elsif area_key_event[:key] == "\b"
          @input_cell_strings[row][column].string = ''
          self.input_string = convert_input_cell_strings_to_input_string
          next_column = column != 0 ? column - 1 : (row != 0 ? COLUMN_COUNT - 1 : 0)
          next_row = column != 0 ? row : (row != 0 ? row : 0)
        elsif area_key_event[:ext_key] == :up
          next_column = column
          next_row = row != 0 ? row - 1 : 0
        elsif area_key_event[:ext_key] == :down
          next_column = column
          next_row = row != (ROW_COUNT - 1) ? row + 1 : (ROW_COUNT - 1)
        elsif area_key_event[:ext_key] == :left
          next_column = column != 0 ? column - 1 : 0
          next_row = row
        elsif area_key_event[:ext_key] == :right
          next_column = column != (COLUMN_COUNT - 1) ? column + 1 : (COLUMN_COUNT - 1)
          next_row = row
        elsif area_key_event[:ext_key] == :home
          next_column = 0
          next_row = row
        elsif area_key_event[:ext_key] == :end
          next_column = COLUMN_COUNT - 1
          next_row = row
        elsif area_key_event[:ext_key] == :page_up
          next_column = column
          next_row = 0
        elsif area_key_event[:ext_key] == :page_down
          next_column = column
          next_row = ROW_COUNT - 1
        elsif area_key_event[:key].is_a?(String)
          character = area_key_event[:key]
          character = SHIFTED_KEYCODE_CHARACTERS[character] if area_key_event[:modifiers].include?(:shift)
          @input_cell_strings[row][column].string = character
          @input_cell_strings[row].each_with_index do |cell, row_column|
            @input_cell_strings[row][row_column].string = ' ' if row_column < column && cell.string == ''
          end
          self.input_string = convert_input_cell_strings_to_input_string
          next_column = column == (COLUMN_COUNT - 1) ? (row == (ROW_COUNT - 1) ? column : 0) : column + 1
          next_row = column == (COLUMN_COUNT - 1) && row != (ROW_COUNT - 1) ? row + 1 : row
        else
          next_column = column
          next_row = row
        end
        select_cell(next_row, next_column)
      end
      
      def convert_input_cell_strings_to_input_string
        @input_cell_strings.to_a.map {|cell_row| cell_row.map(&:string).join}.join("\n")
      end
      
      def launch
        @window.show
      end
    end
  end
end
