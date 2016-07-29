class Htseq < Formula
  desc "Analysing high-throughput sequencing data"
  homepage "http://www-huber.embl.de/HTSeq"
  url "https://pypi.python.org/packages/3c/6e/f8dc3500933e036993645c3f854c4351c9028b180c6dcececde944022992/HTSeq-0.6.1p1.tar.gz#md5=c44d7b256281a8a53b6fe5beaeddd31c"
  version "0.6.1p1"
  sha256 "9d6464e5a1776e5a2db2660d2d4bc5cba1880b5d17df3a6e9053cc0f9e6743ac"
  #tag: bioinformatics
  #doi: 10.1093/bioinformatics/btu638

  option "without-python", "Build without python2 support"

  depends_on :python => :recommended if MacOS.version <= :snow_leopard
  depends_on :python3 => :optional

  depends_on "homebrew/python/numpy"
  depends_on "homebrew/python/matplotlib"

  def install
    ENV.append "LDFLAGS", "-shared" if OS.linux?

    Language::Python.each_python(build) do |python, version|
      dest_path = lib/"python#{version}/site-packages"
      dest_path.mkpath
      system python, "setup.py",
        "build",
        "install", "--prefix=#{prefix}",
        "--single-version-externally-managed", "--record=installed.txt"

      if build.with? "check"
        cd HOMEBREW_TEMP do
          with_environment({
            "PYTHONPATH" => "#{dest_path}:#{nose_path}",
            "PATH" => "#{bin}:#{ENV["PATH"]}"}) do
              system python, "-c", "import HTSeq"
            end # do
         end # do
      end # if
    end # do
  end # def

  def with_environment(h)
    old = Hash[h.keys.map { |k| [k, ENV[k]] }]
    ENV.update h
    begin
      yield
    ensure
      ENV.update old
    end
  end

  def caveats
    if build.with?("python") && !Formula["python"].installed?
      homebrew_site_packages = Language::Python.homebrew_site_packages
      user_site_packages = Language::Python.user_site_packages "python"
      <<-EOS.undent
        If you use system python (that comes - depending on the OS X version -
        with older versions of numpy, scipy and matplotlib), you may need to
        ensure that the brewed packages come earlier in Python's sys.path with:
          mkdir -p #{user_site_packages}
          echo 'import sys; sys.path.insert(1, "#{homebrew_site_packages}")' >> #{user_site_packages}/homebrew.pth
      EOS
    end
  end

  test do
    system "python", "-c", <<-EOS.undent
      import HTSeq as hts
      system "htseq-count","-h"
    EOS
  end

end
