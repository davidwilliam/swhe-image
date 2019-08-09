require './x'

x = X::SWHE.new 2, 64

image_filename = "einstein_200x200.jpg"

`open images/#{image_filename}`

image1 = X::Image.new(image_filename,'gray')

puts "Loaded image 1"

image1.encrypt_pixels(x)

puts "Encrypted pixels of image 1"

puts "Operation: CONTRAST STRETCHING"

a = 255 * 256
b = 0
c = 180 * 256
d = 80 * 256

ca = x.encrypt(a)
cc = x.encrypt(c)

s = (a.to_r - b.to_r) / (c.to_r - d.to_r)

s_h = X::SWHE.hensel_encoding(s,x.p1)

image1.contrast_stretching(x,ca,cc,s_h)

puts "Operation done: Contrast Stretching ===> each pixel"

image1.decrypt_pixels(x)

puts "Decrypted results on encrypted pixels"

image1.save_result_image

puts "Resulting image saved to disk"

exec "open images/result.jpg"
