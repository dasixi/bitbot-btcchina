Gem::Specification.new do |s|
  s.name        = 'bitbot-btcchina'
  s.version     = '0.0.1'
  s.date        = '2013-12-30'
  s.summary     = "A bitbot adapter for btcchina"
  s.description = "A bitbot adapter for btcchina"
  s.authors     = ["dasixi", "tomlion"]
  s.email       = 'i@tomlion.com'
  s.license       = 'GPL V2'
  s.files       = `git ls-files`.split("\n")
  s.homepage    = 'https://github.com/dasixi/bitbot-btcchina'
  s.add_dependency 'kublai'
  s.add_dependency 'bitbot'
end
