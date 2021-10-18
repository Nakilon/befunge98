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
      end
      
      def create_gui
        menu('File') {
          about_menu_item {
            on_clicked do
              display_about_dialog
            end
          }
          quit_menu_item
        }
        @window = window('Befunge98 GUI (Glimmer DSL for SWT)', COLUMN_COUNT * CELL_SIZE, ROW_COUNT * CELL_SIZE + 200) {
          margined true
          
          vertical_box {
            vertical_box {
              @input_string_entry = non_wrapping_multiline_entry {
                text input_string.to_s
  
                on_changed do
                  self.input_string = @input_string_entry.text
                end
              }
              
              button('Run') {
                stretchy false
  
                on_clicked do
                  Befunge98(input_string, $stdout)
                  # TODO fix the following code
  #                   self.output_string = ''
  #                   shell(body_root) {
  #                     minimum_size 420, 240
  #                     text 'Output'
  #
  #                     styled_text {
  #                       editable false
  #                       word_wrap true
  #                       text <= [self, :output_string]
  #                     }
  #
  #                     on_swt_show do
  #                       io = ModelAttributeUpdateStringIO.new(self, :output_string)
  #                       @thread = Thread.new { Befunge98(input_string, io) }
  #                     end
  #
  #                     on_shell_closed do
  #                       @thread.kill
  #                     end
  #                   }.open
                end
              }
            }
            
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
      
                        on_key_up do |area_key_event|
                          mark_key(area_key_event)
                        end
                      }
                    }
                  end
                }
              end
            }
          }
        }
      end
      
      def display_about_dialog
        msg_box('About', "Befunge98 GUI (Glimmer DSL for SWT) #{VERSION}\n\n#{LICENSE}")
      end
      
      def select_cell(row, column)
        pd @selected_row = row
        pd @selected_column = column
        @selected_cell_background_path&.fill = :white
        @selected_cell_background_path = @input_cell_background_paths[row][column]
        @selected_cell_background_path.fill = :gray
      end
      
      def mark_key(area_key_event)
        row = @selected_row
        column = @selected_column
        pd area_key_event[:key_value]
        case area_key_event[:key_value]
        when 10 # new line
          next_column = row != (ROW_COUNT - 1) ? 0 : column
          next_row = row != (ROW_COUNT - 1) ? row + 1 : row
        else
          @input_cell_strings[row][column].string = area_key_event[:key]
          @input_cell_strings[row].each_with_index do |cell, row_column|
            @input_cell_strings[row][row_column].string = ' ' if row_column < column && cell.string == ''
          end
          self.input_string = @input_cell_strings.map {|cell_row| cell_row.map(&:string).join}.join("\n")
          next_column = column == (COLUMN_COUNT - 1) ? (row == (ROW_COUNT - 1) ? column : 0) : column + 1
          next_row = column == (COLUMN_COUNT - 1) && row != (ROW_COUNT - 1) ? row + 1 : row
        end
        select_cell(next_row, next_column)
      end
      
      def launch
        @window.show
      end
    end
  end
end
