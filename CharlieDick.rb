require 'gosu'
require './menu.rb'
require './menuitem.rb'

class CharlieDickWindow < Gosu::Window
  def initialize(background_image)
    super(768, 1024, false)
    self.caption = 'Charlie Dick'
    @background_image = Gosu::Image.new(self, background_image, false)

    @cursor = Gosu::Image.new(self, "Images/components/cursor.png", false)
    @menu = Menu.new(self)
    @quitButton = Menu.new(self)
    button_img = Gosu::Image.new(self, "Images/components/quitButton.png", false)
    @quitButton.add_item(button_img, 
            550, 20, 30, lambda{abort('')}, 
            button_img)
   end

   def draw
    @cursor.draw(self.mouse_x, self.mouse_y, 20)
    @background_image.draw(0, 0, 1)
    @menu.draw
    @quitButton.draw
  end

  def update
    @menu.update
    @quitButton.update
  end
  
  def button_down (id)
    if id == Gosu::MsLeft then
      @menu.clicked
      @quitButton.clicked
    end
  end
  
end

class StartWindow < CharlieDickWindow

  def initialize
   super "Images/charliedick~ipad.png"

   button_img = Gosu::Image.new(self, "Images/components/gioca.png", false)
   x = (self.width - button_img.width)/ 2 
   y = 800

   @menu = Menu.new(self)
   @menu.add_item(button_img, 
   					x, y, 1, lambda{start_game}, 
   					button_img)
  end

  def start_game
       close
       GameWindow.new.show
  end

end

class GameWindow < CharlieDickWindow
  CHARLIEDICK_DRAW_ARGS = [192, 495, 1, 0.5, 0.5]
  SECRET_CARD_ARGS = [139, 0, 1, 0.7, 0.7]
  CHECKS_ARGS = [
      [36, 609],
      [36, 773],
      [662, 609],
      [662, 773]
   ]
   MAX_NUM = 62


  class Check
    attr_accessor :enabled
    def initialize(pos, window)
      @x = pos[0]
      @y = pos[1]
      @enabled = false  
      @enabledImg = Gosu::Image.new(window, "Images/components/enabled.png", false)
      @disabledImg = Gosu::Image.new(window, "Images/components/disabled.png", false)
    end

    def draw
        @enabledImg.draw(@x, @y, 10) if enabled
        @disabledImg.draw(@x, @y, 10) unless enabled
    end  
  end

  def addImageToMenu(menu, imageName, pos, callback)
    button_img = Gosu::Image.new(self, "Images/components/#{imageName}.png", false)
    menu.add_item(button_img, 
            pos[0], pos[1], 10, callback, 
            button_img)
  end

  def reset_checks
    @checks.each do |check|
      check.enabled = false
    end
  end

  def reset_ok_button
    @ok_button = Menu.new(self)
  end

  def play(index)
    num = @selected_cards[index]
    sound = Gosu::Sample.new(self, "Images/wav/%03d.wav" % num)
    sound.play
  end

  def clicked(index)
    @ok_button = Menu.new(self)
    addImageToMenu(@ok_button,"ok", [280,920], lambda{ok_clicked})   

    reset_checks
    @checks[index].enabled = true
    play(index)
    @current_clicked = index
  end

  def playSong(songname)
    sound = Gosu::Sample.new(self, "Images/music/#{songname}.mp3")
    sound.play
  end

  def iWon
    reset_ok_button
    reset_checks
    playSong("applause")  
    @charliedick = Gosu::Image.new(self, "Images/right#{1+Random.rand(1024)%2}.png", false)
    @callback_to_do = lambda do
      new_game
    end
    @execute_time = Gosu::milliseconds() + 4000
  end

  def iLost
    reset_ok_button
    reset_checks
    playSong("sadtrombone")  
    @charliedick = Gosu::Image.new(self, "Images/wrong#{1+Random.rand(1024)%2}.png", false)
    @callback_to_do = lambda do
      reset_charliedick
    end
    @execute_time = Gosu::milliseconds() + 3000
  end

  def ok_clicked
    won = @selected_cards[@current_clicked] == @secret

    if won
      iWon
    else
      iLost
    end
  end
   
  def pick_secret
    cards = []
    (0..MAX_NUM).each do |num|
      cards << num
    end
    random_index = Random.rand(MAX_NUM)
    cards = cards.shuffle
    @secret = cards[random_index]
    cards = cards + cards
    @selected_cards = cards.slice(random_index, 4).shuffle  
    @secret_card = Gosu::Image.new(self, "Images/img/%03d.png" % @secret, false)
  end

  def reset_charliedick
    @charliedick = Gosu::Image.new(self, "Images/charliedick~ipad.png", false)
  end

  def new_game
    reset_charliedick
    reset_ok_button
    pick_secret    
    reset_checks
  end

  def initialize
   super "Images/legno.png"
   
   @execute_time = -1
    @menu = Menu.new(self)
    addImageToMenu(@menu,"firstButton", [114,599], lambda{clicked(0)})
    addImageToMenu(@menu,"secondButton", [114,763], lambda{clicked(1)})
    addImageToMenu(@menu,"thirdButton", [534,599], lambda{clicked(2)})
    addImageToMenu(@menu,"fourthButton", [534,763], lambda{clicked(3)})

    @checks = []
    CHECKS_ARGS.each do |check_args|
      @checks << Check.new(check_args, self)
    end
   
   new_game

  end

  def update
    super
    @ok_button.update
    return if @execute_time == -1

    if(Gosu::milliseconds() >= @execute_time)
      @execute_time = -1
      @callback_to_do.call
    end
  end
  
  def draw
    super
    @charliedick.draw(*CHARLIEDICK_DRAW_ARGS)
    @secret_card.draw(*SECRET_CARD_ARGS)
    @ok_button.draw
    @checks.each do |check|
      check.draw
    end
  end

 def button_down (id)
  super id
    if id == Gosu::MsLeft then
      @ok_button.clicked
    end
  end
end

StartWindow.new.show
