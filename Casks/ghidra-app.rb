class NoDownloadDownloadStrategy < AbstractDownloadStrategy
  def cached_location; Pathname(File.dirname(__FILE__) + "/ghidra-jar2app.sh") end
end

cask "ghidra-app" do
  version :latest
  sha256 :no_check

  url "https://www.ghidra-sre.org", using: NoDownloadDownloadStrategy
  name "Ghidra (App)"
  homepage "https://www.ghidra-sre.org/"
  desc "Creates an app from the default Ghidra installation (uses jpackage, depends on ghidra cask)."

  depends_on cask: "ghidra"

  container type: :nounzip # normally a script would be executed, just copy instead
  
  preflight do
    ghidraCask = CaskLoader.load("ghidra")
    ghidraVersion = version.class.new(ghidraCask.versions.last) # .versions refers to the installed versions
    ghidraCaskPath = "#{ghidraCask.caskroom_path}/#{ghidraVersion}/ghidra_#{ghidraVersion.before_comma}_PUBLIC"
    raise "Ghidra installation not found" unless Pathname(ghidraCaskPath).exist?
    ghidraJarPath = "#{staged_path}/ghidra.jar"
    
    oh1 "Creating Ghidra single jar from ghidra installation in: #{ghidraCaskPath}"
    system_command "#{ghidraCaskPath}/support/buildGhidraJar", args: ["-output", ghidraJarPath]
    
    oh1 "Creating Ghidra App Bundle"
    system_command "#{staged_path}/ghidra-jar2app.sh", args: [ghidraJarPath, staged_path.to_s]
  end

  app "Ghidra.app"

  caveats do
    depends_on_java "14+"
  end
end
