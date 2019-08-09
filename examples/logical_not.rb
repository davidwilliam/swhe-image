require './x'

x = X::SWHE.new 2, 64

image_filename = "einstein_200x200.jpg"

`open images/#{image_filename}`

image1 = X::Image.new(image_filename,'gray')

puts "Loaded image 1"

image1.encrypt_pixels(x)

puts "Encrypted pixels of image 1"

puts "Operation: LOGICAL NOT"

max = 255 * 256

cmax = x.encrypt(max)

image1.logical_not(x,cmax)

puts "Operation done: Logical Not ===> each pixel"

image1.decrypt_pixels(x)

puts "Decrypted results on encrypted pixels"

image1.save_result_image

puts "Resulting image saved to disk"

exec "open images/result.jpg"
