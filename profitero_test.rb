require 'open-uri'
require 'nokogiri'
require 'csv'

NAME = "//div[@class='product-name']/h1[contains(@itemprop,'name')]/text()"
PRICE = "//span[@class = 'attribute_price']/text()"
IMAGE = "//div[@id='image-block']//img[@itemprop='image']/@src"
SELECT = "//ul[@class='attribute_labels_lists']" 
PAGES = "//li[@class='pagination_next']/parent::*/li[6]//span/text()"
LINKS = "//div[@class='productlist']//a[@class='product_img_link']/@href"
GRAMM = "//ul[@class='attribute_labels_lists']/li/span[@class = 'attribute_name']/text()"

url = 'https://www.petsonic.com/es/perros/snacks-y-huesos-perro'

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
	name = page.xpath(NAME).to_s.gsub(" ", "").gsub("\n", "")
	prc = page.xpath(PRICE).to_s.gsub("	", "").gsub(" €", "")
	img = page.xpath(IMAGE).to_s
	gr = page.xpath(GRAMM).to_s
	massiv = Array.new
	page.xpath(SELECT).each do |selected|
		selection = Array.new
		selection.push("#{name} - #{gr}")
		selection.push(prc)
		selection.push(img)
		massiv.push(selection)
	end
	massiv
end

def csv_file(massiv)
	CSV.open("profitero_test.csv", "a+", {:col_sep => ";"}) do |csv|
		massiv.each do |selection|
			csv << selection
		end
	end
end

for page in 1..pages(html(url)).to_i
  html_page = html("https://www.petsonic.com/es/perros/snacks-y-huesos-perro?p=#{page}")
  links(html_page).each { |link|
       csv_file info(link)
  }
end
