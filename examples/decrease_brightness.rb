require './x'

x = X::SWHE.new 2, 64

image_filename = "einstein_200x200.jpg"

`open images/#{image_filename}`

image1 = X::Image.new(image_filename,'gray')

puts "Loaded image 1"

image1.encrypt_pixels(x)

puts "Encrypted pixels of image 1"

puts "Operation: DECREASE BRIGHTNESS"

constant = x.encrypt(80 * 256)
image1.decrease_brightness(x,constant)

puts "Operation done: each_pixel + #{constant}"

image1.decrypt_pixels(x)

puts "Decrypted results on encrypted pixels"

image1.save_result_image

puts "Resulting image saved to disk"

exec "open images/result.jpg"
