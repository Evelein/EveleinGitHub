require 'open-uri'
require 'nokogiri'
require 'csv'
require 'thread'
require 'choice'

NAME = "//div[@class='product-name']/h1[contains(@itemprop,'name')]/text()"
PRICE = ".//span[@class = 'attribute_price']/text()"
IMAGE = "//div[@id='image-block']//img[@itemprop='image']/@src"
SELECT = "//ul[@class='attribute_labels_lists']" 
PAGES = "//li[@class='truncate']/following-sibling::li//span/text()"
LINKS = "//div[@class='productlist']//a[@class='product_img_link']/@href"
GRAMM = ".//span[@class = 'attribute_name']/text()"

Choice.options do
  option :url do
    short '-c'
    long '--category=CATEGORY'
    desc 'Link to category'
    default 'https://www.petsonic.com/snacks-huesos-para-perros/'
  end

  option :file do
    short '-f'
    long '--file=FILE'
    desc 'Output file name'
    default "petsonic_test.csv"
  end
end

def html(url)
	Nokogiri::HTML(open(url))
end

def pages(page)
 	page.xpath(PAGES).to_s
end

def links(page)
	page.xpath(LINKS).to_a
end

def info(link)
	page = html("#{link}")
	name = page.xpath(NAME).to_s.strip
	img = page.xpath(IMAGE).to_s
	massiv = Array.new
	page.xpath(SELECT).each do |selected|
		selection = Array.new
		selection.push("#{name} - #{selected.xpath(GRAMM).to_s.strip}")
		selection.push(selected.xpath(PRICE).to_s.strip.gsub(" €", ""))
		selection.push(img)
		massiv.push(selection)
	end
	massiv
end

def csv_file(massiv)
	CSV.open("#{Choice[:file]}", "a+", {:col_sep => ";"}) do |csv|
		massiv.each do |selection|
			csv << selection
		end
	end
end

threads = []

for page in 1..pages(html(Choice[:url])).to_i
	html_page = html("#{Choice[:url]}?p=#{page}")
	links(html_page).each { |link|
		threads << Thread.new do
		csv_file info(link)
	end
  }
  threads.each {|t| t.join } 
end
