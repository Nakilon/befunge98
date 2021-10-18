require_relative '../model/model_attribute_update_string_io'

class Befunge98GuiGlimmerDslSwt
  module View
    class AppView
      include Glimmer::UI::CustomShell
      
      COLUMN_COUNT = 30
      ROW_COUNT = 12
      LAST_PROGRAM = File.expand_path(File.join(Dir.home, '.befunge98'), __dir__)
      
      attr_accessor :input_cells, :output_string, :input_string
    
      ## Use before_body block to pre-initialize variables to use in body
      #
      #
      before_body do
        Display.app_name = 'Befunge98 GUI (Glimmer DSL for SWT)'
        Display.app_version = VERSION
        @display = display {
          on_about {
            display_about_dialog
          }
          on_preferences {
            display_about_dialog
          }
        }
        self.input_cells = ROW_COUNT.times.map {COLUMN_COUNT.times.map {''}}
      end
  
      ## Use after_body block to setup observers for widgets in body
      #
      after_body do
        observe(self, :input_string) do |new_input_string|
          # save last program
          File.write(LAST_PROGRAM, new_input_string)
          new_input_cells = new_input_string.split("\n").map {|cell_row| cell_row.chars}
          ROW_COUNT.times do |row|
            COLUMN_COUNT.times do |column|
              new_value = (new_input_cells[row] && new_input_cells[row][column]) || ''
              self.input_cells[row][column] = new_value if self.input_cells[row][column] != new_value
            end
          end
        end
        # load last program
        self.input_string = File.read(LAST_PROGRAM).to_s
      end
  
      ## Add widget content inside custom shell body
      ## Top-most widget must be a shell or another custom shell
      #
      body {
        shell {
          # Replace example content below with custom shell content
          image File.join(APP_ROOT, 'icons', 'windows', "Befunge98 Gui Glimmer Dsl Swt.ico") if OS.windows?
          image File.join(APP_ROOT, 'icons', 'linux', "Befunge98 Gui Glimmer Dsl Swt.png") unless OS.windows?
          text "Befunge98 GUI (Glimmer DSL for SWT)"
        
          grid_layout(COLUMN_COUNT, true) {
            horizontal_spacing 0
            vertical_spacing 0
          }
          
          composite {
            layout_data(:fill, :center, true, false) {
              horizontal_span COLUMN_COUNT
            }
            
            text(:multi, :wrap, :border) {
              layout_data(:fill, :center, true, false) {
                height_hint 200
              }
              text <=> [self, :input_string]
            }
            
            button {
              text 'Run'
              
              on_widget_selected do
                self.output_string = ''
                shell(body_root) {
                  minimum_size 420, 240
                  text 'Output'
                  
                  styled_text {
                    editable false
                    word_wrap true
                    text <= [self, :output_string]
                  }
                  
                  on_swt_show do
                    io = ModelAttributeUpdateStringIO.new(self, :output_string)
                    @thread = Thread.new { Befunge98(input_string, io) }
                  end
                  
                  on_shell_closed do
                    @thread.kill
                  end
                }.open
              end
            }
          }
          
          ROW_COUNT.times do |row|
            COLUMN_COUNT.times do |column|
              button { |btn|
                layout_data :fill, :fill, true, true
                text <= [self, "input_cells[#{row}][#{column}]"]
                
                on_widget_selected do
                  btn.set_focus
                end
                
                on_key_pressed do |event|
                  self.input_cells[row][column] = event.character.chr
                  self.input_cells[row].each_with_index do |cell, column|
                    self.input_cells[row][column] = ' ' if cell == ''
                  end
                  self.input_string = self.input_cells.map {|cell_row| cell_row.join}.join("\n")
                end
              }
            end
          end
          
          menu_bar {
            menu {
              text '&File'
              menu_item {
                text '&About...'
                on_widget_selected {
                  display_about_dialog
                }
              }
              menu_item {
                text '&Preferences...'
                on_widget_selected {
                  display_about_dialog
                }
              }
            }
          }
        }
      }
      
      def display_about_dialog
        message_box(body_root) {
          text 'About'
          message "Befunge98 GUI (Glimmer DSL for SWT) #{VERSION}\n\n#{LICENSE}"
        }.open
      end
    end
  end
end
