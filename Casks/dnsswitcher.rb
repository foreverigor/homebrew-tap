cask "dnsswitcher" do
    version :latest
    sha256 :no_check
  
    url "https://github.com/mattmcneeney/DNSSwitcher/raw/master/DNSSwitcher.zip"
    name "DNSSwitcher"
    desc "DNS Switcher is a simple menu-bar utility that allows you to quickly switch between pre-configured DNS settings."
    homepage "https://mattmcneeney.github.io/DNSSwitcher/"
  
    app "DNSSwitcher.app"
  end