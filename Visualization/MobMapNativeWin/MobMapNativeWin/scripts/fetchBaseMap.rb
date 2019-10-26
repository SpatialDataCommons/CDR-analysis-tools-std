#!/var/ruby19/bin/ruby

API_BASE = "http://maps.google.co.jp/maps/api/staticmap?"
API_KEY  = "Please put google map key here"	# updated at 2018.10.11
TILE_SIZE = 640
OVERLAP   = 48
DL_DIR   = "./temp"
OUT_DIR   = "./temp"
OUT_BASENAME = "basemap"

def gmap_bround(v, min, max)
	return max if (v>max)
	return min if (v<min)
	return v
end

def convertXYtoLL(x, y)
	pi = Math::PI;
	dpi = pi * 2.0;
	hpi = pi / 2.0;

	lng = gmap_bround((x-0.5) * dpi, -pi, pi)
	
	g = (y-0.5) * -dpi
	lat = 2.0 * Math.atan( Math.exp(g) ) - hpi

	return [lat, lng]
end

def convertLLtoXY(lat, lng)
	lat *= Math::PI / 180.0
	lng *= Math::PI / 180.0

	dpi = Math::PI * 2.0;

	x = lng / dpi + 0.5;
	s = Math.sin(lat)
	c = Math.cos(lat)
	y = Math.log((1+c+s)/(1+c-s)) / -dpi + 0.5
	
	return [x, y]
end

def make_map_style(pairs)
	params = pairs.keys.map{|n|
		"#{n}:#{pairs[n]}"
	}.join('|')
	"style=#{params.gsub('|','%7C')}"
end

def dlmap(lat, lng, z, outname)
	params = []
	
	params << "center=#{lat.to_f},#{lng.to_f}"
	params << "zoom=#{z.to_i}"
	params << "size=#{TILE_SIZE}x#{TILE_SIZE}"
	params << "sensor=false"
	params << "language=en"
	params << "key=#{API_KEY}"  # updated at 2018.10.11

	params << make_map_style({
		"feature" => "all",
		"element" => "geometry",
		"saturation" => "-100",
		"invert_lightness" => "true",
		"lightness" => "0",
		"gamma" => "1"
	})

	params << make_map_style({
		"feature" => "all",
		"element" => "labels",
		"visibility" => "off"
	})

	url = "#{API_BASE}#{params.join('&')}"

	require 'open-uri'
	open(url) {|f|
		File.open(outname, "wb") {|outf|
			outf.write(f.read)
		}
	}
end

def download_a_tile(x, y, z, index = 1, save_file = true)
	world_size = 2 ** (8 + z)
	x /= world_size.to_f
	y /= world_size.to_f

	r2d = 180.0 / Math::PI
	ll = convertXYtoLL(x, y)
	lat = ll[0] * r2d
	lng = ll[1] * r2d
	
	if save_file
		dlmap(lat, lng, z, "#{DL_DIR}/t#{index}.png")
	end
end

def bulk_dl(lat, lng, z)
	world_size = 2 ** (8 + z)
	xy = convertLLtoXY(lat, lng)
	xy[0] *= world_size.to_f
	xy[1] *= world_size.to_f

	x = xy[0]
	y = xy[1]
	hsize = TILE_SIZE >> 1
	download_a_tile(x - hsize, y - hsize, z, 1)
	download_a_tile(x + hsize, y - hsize, z, 2)
	download_a_tile(x - hsize, y + hsize - OVERLAP, z, 3)
	download_a_tile(x + hsize, y + hsize - OVERLAP, z, 4)
	
	require 'rubygems'
	require 'json'
	meta = Hash.new
	
	meta['center-lat'] = lat
	meta['center-lng'] = lng
	meta['zoom'] = z
	meta['overlap-height'] = OVERLAP
	
	return JSON.pretty_generate(meta)
end

def concat_image(filenames)
	require 'rubygems'
	require 'RMagick'
	
	outi = Magick::Image.new(TILE_SIZE*2, TILE_SIZE*2){
		self.background_color = 'white'
	}
	
	images = filenames.map{|fn|
		Magick::ImageList.new(fn)[0]
	}
	
	images.length.times{|i|
		x = i%2
		y = (i/2).floor
		
		outi.composite!(images[i], TILE_SIZE * x, (TILE_SIZE - OVERLAP) *y, Magick::OverCompositeOp)
	}
	
	outi.write("#{OUT_DIR}/#{OUT_BASENAME}.png")
end

def ensure_dir(dname)
	if not File.exists?(dname)
		Dir::mkdir(dname)
	end
end

def save_meta(s)
	File.open("#{OUT_DIR}/#{OUT_BASENAME}.json", "w") {|f|
		f.write(s)
	}
end


center_pos = ARGV
ensure_dir(DL_DIR)
meta_json = bulk_dl(center_pos[0].to_f, center_pos[1].to_f, center_pos[2].to_i)
save_meta(meta_json)
#concat_image([
#	"#{DL_DIR}/t1.png",
#	"#{DL_DIR}/t2.png",
#	"#{DL_DIR}/t3.png",
#	"#{DL_DIR}/t4.png"
#])
