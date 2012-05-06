require 'gosu'
require './menu.rb'
require './menuitem.rb'

class Main < Gosu::Window
	def initialize
		super(640, 480, false)
		@cursor = Gosu::Image.new(self, "images/cursor.png", false)
		x = self.width / 2 - 100
		y = self.height  / 2 - 100
		lineHeight = 50
		self.caption = "A menu with Gosu"
		items = Array["exit", "additem", "item"]
		actions = Array[lambda { self.close }, lambda {
			@menu.add_item(Gosu::Image.new(self, "images/item.png", false), x, y, 1, lambda { })
			y += lineHeight
		}, lambda {}]
		@menu = Menu.new(self)
		for i in (0..items.size - 1)
			@menu.add_item(Gosu::Image.new(self, "images/#{items[i]}.png", false), x, y, 1, actions[i], Gosu::Image.new(self, "images/#{items[i]}_hover.png", false))
			y += lineHeight
		end
		@back = Gosu::Image.new(self, "images/back.png", false)
	end

	def update
		@menu.update
	end

	def draw
		@cursor.draw(self.mouse_x, self.mouse_y, 2)
		@back.draw(0,0,0)
		@menu.draw
	end

	def button_down (id)
		if id == Gosu::MsLeft then
			@menu.clicked
		end
	end

end

Main.new.show
