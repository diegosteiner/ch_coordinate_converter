require "ch_coordinate_converter/version"

module ChCoordinateConverter
  class LV03Coordinate
    FORMAT = /\A(?<y_major> \d{3})([\/|\.]?)(?<y_minor> \d{3})([\/|\.]? \/)(?<x_major> \d{3})([\/|\.]?)(?<x_minor> \d{3})(\s(?<altitude> \d*)m?)?\z/ix

    attr_accessor :x_major, :x_minor, :y_major, :y_minor, :altitude

    def initialize(*args)
      case args.count
        when 2, 3
          self.y_major = (args[0] / 1000).to_i
          self.y_minor = args[0] - (y_major * 1000).to_i
          self.x_major = (args[1] / 1000).to_i
          self.x_minor = args[1] - (x_major * 1000).to_i
          self.altitude = args[2] || 0
        when 4, 5
          self.x_major, self.x_minor, self.y_major, self.y_minor, self.altitude = args
        when 1
          m = args[0].to_s.match FORMAT
          raise ArgumentError unless m.present?

          self.x_major, self.x_minor, self.y_major, self.y_minor = m[:x_major].to_i, m[:x_minor].to_i, m[:y_major].to_i, m[:y_minor].to_i
          self.altitude = m[:altitude].to_i || 0
        else
          raise ArgumentError
      end

      # swap axis if necessary
      if self.x_major > self.y_major
        self.x_major, self.y_major = self.y_major, self.x_major
        self.x_minor, self.y_minor = self.y_minor, self.x_minor
      end
    end

    def to_s
      "%03d/%03d//%03d/%03d %dm" % [y_major, y_minor, x_major, x_minor, altitude]
    end

    def x
      x_major * 1000 + x_minor
    end

    def y
      y_major * 1000 + y_minor
    end

    def round!(m)
      rx = (x.to_f / m).round * m
      ry = (y.to_f / m).round * m

      self.x_major = (rx / 1000).floor
      self.x_minor = (rx - x_major * 1000).floor
      self.y_major = (ry / 1000).floor
      self.y_minor = (ry - y_major * 1000).floor
    end

    def round(m)
      r = self.dup
      r.round!(m)
      r
    end

    def to_wgs84
      # Converts militar to civil and to unit = 1000km
      # Axiliary values (% Bern)
      y_aux = (y - 600000).to_f / 1000000
      x_aux = (x - 200000).to_f / 1000000

      lat = ((16.9023892 + (3.238272 * x_aux))-(0.270978 * (y_aux**2))-(0.002528 * (x_aux**2))-(0.0447 * (y_aux**2) * x_aux)-(0.0140 * (x_aux ** 3)))
      lng = ((2.6779094 + (4.728982 * y_aux)+(0.791484 * y_aux * x_aux)+(0.1306 * y_aux * (x_aux**2)))-(0.0436 * (y_aux**3)))

      # Unit 10000" to 1 " and converts seconds to degrees (dec)
      lat = (lat * 100) / 36
      lng = (lng * 100) / 36

      return ChCoordinateConverter::WGS84Coordinate.new(lat, lng, altitude)
    end
  end

  class WGS84Coordinate
    attr_accessor :latitude, :longitude, :altitude

    def initialize(latitude, longitude, altitude=0)
      self.latitude, self.longitude, self.altitude = latitude, longitude, altitude
    end

    def to_s
      "#{longitude}, #{latitude}"
    end

    def to_lv03
      lat = dec_to_seconds(latitude)
      lng = dec_to_seconds(longitude)

      # Axiliary values (% Bern)
      lat_aux = (lat - 169028.66).to_f / 10000
      lng_aux = (lng - 26782.5).to_f / 10000

      # Process X
      x = (((200147.07 + (308807.95 * lat_aux)+(3745.25 * (lng_aux**2)) +(76.63 * (lat_aux**2))) - (194.56 * (lng_aux**2) * lat_aux)) +(119.79 * (lat_aux**3)))
      y = ((600072.37 + (211455.93 * lng_aux))-(10938.51 * lng_aux * lat_aux)-(0.36 * lng_aux * (lat_aux**2))-(44.54 * (lng_aux**3)))

      ChCoordinateConverter::LV03Coordinate.new(y, x, altitude).round(50)
    end

    def self.dec_to_seconds(dec)
      deg = dec.floor.to_i
      min = ((dec - deg) * 60).floor.to_i
      sec = (((dec - deg) * 60) - min) * 60

      # Output: dd.mmss(,)ss
      return sec + (min * 60) + (deg * 3600)
    end
  end
end
