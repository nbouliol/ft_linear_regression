#! /Users/nbouliol/.brew/bin/ruby
require "nyaplot"
require "csv"

t0 = 0
t1 = 0

csv = CSV.read('data.csv', headers: true)
$kmArray = []
csv.each { |row|
	$kmArray.push(row["km"].to_f)
 }

def price(t0, t1, km)
	return  t0 + t1 * km / $kmArray.max
end

if i = ARGV.index("-r")
	# puts $0
	text = File.read($0)
	new_contents = text.gsub(/t0 = -?\d*\.?\d*\nt1 = -?\d*\.?\d*/, "t0 = 0\nt1 = 0")

	File.open($0, "w") {|file| file.puts new_contents }
	exit
end

puts "\033[0;32mt0 = #{t0} and t1 = #{t1}\033[0m"

puts "Enter a mileage to get a price :"
km = STDIN.gets.chomp.to_i
puts "Trying to find the price of a car at \033[0;35m#{km}\033[0m km ..."
prix = price(t0,t1,km)
if prix < 0
	puts "\033[0;32mSorry mileage entered is to important, can't calculate price.\033[0m"
	exit
else
	puts "Estimated price is : \033[0;36m#{prix.round(2)} €\033[0m"
end

if i = ARGV.index("-g")
	csv = CSV.read('data.csv', headers: true)

	kms = []
	prices = []
	csv.each { |row|
		kms.push(row["km"].to_i)
		prices.push(row["price"].to_i)
	}

	plot = Nyaplot::Plot.new
	s = plot.add(:scatter, kms, prices)
	# s.color(Nyaplot::Colors.seq)

	if km > kms.max
		new_prices = [price(t0,t1,kms.min), price(t0,t1,km)]
		df = Nyaplot::DataFrame.new({x:[kms.min, km], y:new_prices})
	elsif km < kms.min
		new_prices = [price(t0,t1,km), price(t0,t1,kms.max)]
		df = Nyaplot::DataFrame.new({x:[km, kms.max], y:new_prices})
	else
		new_prices = [price(t0,t1,kms.min), price(t0,t1,kms.max)]
		df = Nyaplot::DataFrame.new({x:[kms.min, kms.max], y:new_prices})
	end


	l = plot.add_with_df(df, :line, :x, :y, legend: true)
	l.color(Nyaplot::Color.new(["#00FF00"]))
	po = plot.add(:scatter, [km], [price(t0,t1,km)])
	color = Nyaplot::Color.new(["#e51400"])
	po.color(color)
	plot.x_label("km")
	plot.y_label("price")
	plot.export_html("beau.html")
	`open beau.html`
	exit
end
