require './x'

x = X::SWHE.new 2, 64

image_filename_1 = "einstein_200x200.jpg"
image_filename_2 = "einstein_eye_bar.jpeg"

`open images/#{image_filename_1}`

image1 = X::Image.new(image_filename_1,'gray')

puts "Loaded image 1"

image1.encrypt_pixels(x)

puts "Encrypted pixels of image 1"

`open images/#{image_filename_2}`

image2 = X::Image.new(image_filename_2,'gray')

puts "Loaded image 2"

image2.encrypt_pixels(x)

puts "Encrypted pixels of image 2"

puts "Operation: MERGE IMAGES"

factor = X::SWHE.hensel_encoding(-1,x.p1)

image1.stamp_image(x,image2,factor)

puts "Operation done: Stamp ===> each pixel"

image1.decrypt_pixels(x)

puts "Decrypted results on encrypted pixels"

image1.save_result_image

puts "Resulting image saved to disk"

exec "open images/result.jpg"
