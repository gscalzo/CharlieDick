require 'gosu'
require './menu.rb'
require './menuitem.rb'

class GameWindow < Gosu::Window
  def initialize
   super(768, 1024, false)

   @beep = Gosu::Sample.new(self, "Images/wav/000.wav")

   self.caption = 'Charlie Dick'
   @cursor = Gosu::Image.new(self, "Images/components/cursor.png", false)
   @background_image = Gosu::Image.new(self, "Images/charliedick~ipad.png", true)

   

   button_img = Gosu::Image.new(self, "Images/components/gioca.png", false)
   x = (self.width - button_img.width)/ 2 
   y = 800

   @menu = Menu.new(self)
   @menu.add_item(Gosu::Image.new(self, button_img, false), 
   					x, y, 1, lambda{@beep.play}, 
   					Gosu::Image.new(self, button_img, false))

  end

  def update
  	@menu.update
  end
  
  def draw
  	@cursor.draw(self.mouse_x, self.mouse_y, 2)
    @background_image.draw(0, 0, 0)
    @menu.draw
  end

  def button_down (id)
	if id == Gosu::MsLeft then
		@menu.clicked
	end
  end
end





window = GameWindow.new
window.show