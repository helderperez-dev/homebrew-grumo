class Grumo < Formula
  desc "Programmable runtime for adaptive applications and operational systems"
  homepage "https://github.com/helderperez-dev/grumo"
  url "https://files.pythonhosted.org/packages/source/g/grumo/grumo-2.0.1.tar.gz"
  sha256 "5ab6142aaff7b597c51617418446acdd24c05774952f41423fad470bbf7e31ad"
  license "MIT"

  depends_on "uv"
  depends_on "python@3.12"

  def install
    ENV["UV_TOOL_DIR"] = libexec.to_s
    system "uv", "tool", "install", "grumo==#{version}", "--python", "3.12"

    tool_bin = libexec/"grumo/bin"
    brew_python = Formula["python@3.12"].bin/"python3.12"

    %w[python python3 python3.12].each do |name|
      link = tool_bin/name
      next unless File.symlink?(link.to_s)
      FileUtils.rm_f(link)
      File.symlink(brew_python, link)
    end

    grumo_script = tool_bin/"grumo"
    if grumo_script.exist?
      content = File.read(grumo_script)
      content.sub!(%r{^#!.*$}, "#!#{tool_bin}/python3.12")
      File.write(grumo_script, content)
      chmod("+x", grumo_script)
    end

    # Homebrew rewrites every Mach-O it finds in the keg. Grumo
    # Store's prebuilt @rpath extension is already relocatable but has
    # no spare Mach-O header room for Homebrew's longer install name.
    # Hide it as gzip data during keg relocation and restore it in
    # post_install after Homebrew's relocation pass has completed.
    native = Dir[libexec/"**/site-packages/grumo_store/_native.abi3.so"].first
    odie "grumo_store native extension not found" if native.nil?
    system "gzip", "-f", native

    rm_rf Dir.glob(libexec/"**/site-packages/jiter/*.so")

    bin.install_symlink tool_bin/"grumo"
  end

  def post_install
    native_gz = Dir[libexec/"**/site-packages/grumo_store/_native.abi3.so.gz"].first
    return if native_gz.nil?

    system "gzip", "-d", native_gz
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/grumo --help")
    system libexec/"grumo/bin/python3.12", "-c", "import grumo, grumo_store"
    system bin/"grumo", "new", "smoke-app", "--no-install"
    cd testpath/"smoke-app" do
      system libexec/"grumo/bin/python3.12", "-c", <<~PY
        from pathlib import Path
        from starlette.testclient import TestClient
        from grumo import App
        app = App()
        with TestClient(app) as client:
            assert client.get('/').status_code == 200
            assert client.get('/readyz').status_code == 200
            assert client.get('/about').status_code == 200
            assert client.get('/users/42').status_code == 200
        assert Path('.grumo/application.grumo').exists()
        assert list(Path('.').rglob('*.db')) == []
      PY
    end
  end
end
