require 'date'

Gem::Specification.new do |s|
  s.name        = 'denormalize_field'
  s.version     = '0.0.1'
  s.date        = Date.today.to_s
  s.summary     = "Denormalize fields easily in ActiveRecord"
  s.description = "Helpers to denormalize fields easily on ActiveRecord models"
  s.authors     = [
    "Scott Taylor",
    "Andrew Pariser"
  ]
  s.email       = 'scott@railsnewbie.com'
  s.files       = Dir.glob("lib/**/**.rb")
  s.homepage    = 'http://github.com/smtlaissezfaire/denormalize_field'
  s.license     = 'MIT'
end
