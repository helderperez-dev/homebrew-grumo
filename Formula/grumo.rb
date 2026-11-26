class Grumo < Formula
  desc "Programmable runtime for adaptive applications and operational systems"
  homepage "https://github.com/helderperez-dev/grumo"
  url "https://files.pythonhosted.org/packages/source/g/grumo/grumo-1.0.0.tar.gz"
  sha256 "c6aa9bfdad2d5461cd18ebc0db111c377ee1e9efa5d8e40f6fdae599ef36445c"
  license "MIT"

  depends_on "uv"
  depends_on "python@3.12"

  def install
    python = Formula["python@3.12"].opt_bin/"python3.12"
    system "uv", "venv", "--python", python, "--no-managed-python", libexec
    system "uv", "pip", "install", "--python", libexec/"bin/python", "."

    # Preserve the upstream native wheel through Homebrew's Mach-O relocation.
    if OS.mac?
      native = Dir[libexec/"**/site-packages/grumo_store/_native*.so"].first
      odie "grumo_store native extension not found" if native.nil?
      system "gzip", "-f", native
    end

    bin.install_symlink libexec/"bin/grumo"
  end

  def post_install
    Dir[libexec/"**/site-packages/grumo_store/_native*.so.gz"].each do |native|
      system "gzip", "-d", native
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/grumo version")
    system bin/"grumo", "--help"
    system libexec/"bin/python", "-c", <<~PY
      import grumo, grumo_store
      from importlib.metadata import version
      assert grumo.__version__ == version("grumo") == "#{version}"
      assert grumo_store.__version__ == version("grumo-store")
      assert grumo_store.__version__.split(".")[0] == "1"
      from grumo import App
      from grumo_store import Store
    PY
    system bin/"grumo", "new", "smoke-app", "--no-install"
    assert_path_exists testpath/"smoke-app/pyproject.toml"
  end
end
