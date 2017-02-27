#! /Users/nbouliol/.brew/bin/ruby
require 'csv'
require 'csv'

km = []
price = []

$t0 = 0.0
$t1 = 0.0

csv = CSV.read('data.csv', headers: true)

csv.each { |row|
	km.push(row["km"].to_f)
	price.push(row["price"].to_f)
 }

def normalize(kms)
 	max = kms.max
	normeX = []
 	for i in 0..kms.count-1
 		normeX << (Float(kms[i]) / Float(max))
	end
	return normeX
end

if ARGV.index("-i")
	puts "Enter the number of iteration you want :"
	$iter = STDIN.gets.to_i
else
	$iter = 10000
end

km = normalize(km)

arr = km.zip(price)

def estimatePrice(km)
	r = $t0 + ($t1 * km)
	return r
end

def d0(arr)
	tmp = 0
	for i in 0..arr.count - 1
		tmp += estimatePrice(arr[i][0]) - arr[i][1]
	end
	return tmp
end

def d1(arr)
	tmp = 0
	for i in 0..arr.count - 1
		tmp += (estimatePrice(arr[i][0]) - arr[i][1]) * arr[i][0]
	end
	return tmp
end

def caca(arr, l)
	len = arr.count
	i = 0
	$iter.times do
		t_0 = $t0 - l * d0(arr).fdiv(len)
		t_1 = $t1 - l * d1(arr).fdiv(len)
		if t_0 == $t0 && $t1 == t_1
			break
		end
		i += 1
		$t0 = t_0
		$t1 = t_1
	end
	puts "Total amount of iterations : #{i}"
end

def error(theta0, theta1, kms, prices)
	totalError = 0
	len = kms.count
	for i in 0..len-1
		totalError += ((prices[i] - ((theta1 * kms[i]) + theta0))/prices.max) ** 2
	end
	puts "Error rate : " + (totalError / len.to_f).to_s
	return totalError / len.to_f
end

caca(arr, 0.1)
error($t0, $t1, km, price)

file_name = "getPrice.rb"
text = File.read(file_name)
new_contents = text.gsub(/t0 = -?\d*\.?\d*\nt1 = -?\d*\.?\d*/, "t0 = #{$t0}\nt1 = #{$t1}")

File.open(file_name, "w") {|file| file.puts new_contents }
