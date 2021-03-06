class Mesa < Formula
  desc "Graphics Library"
  homepage "https://www.mesa3d.org/"
  url "https://mesa.freedesktop.org/archive/mesa-20.1.8.tar.xz"
  sha256 "df21351494f7caaec5a3ccc16f14f15512e98d2ecde178bba1d134edc899b961"
  license "MIT"
  head "https://gitlab.freedesktop.org/mesa/mesa.git"

  livecheck do
    url :stable
  end

  bottle do
    cellar :any
    sha256 "5308eef12c7e1a13fedcce181c043564eba0a44960935eaf6b93de75cad86ecb" => :catalina
    sha256 "8f99474bc1abeb7f5dd0ba333454aa112fa70e5a70c185c9f99a48e367111a99" => :mojave
    sha256 "0a2e786d887053c1cf8d8a81d42b3402f3fb505a63393bf60c73f0a8406757c0" => :high_sierra
  end

  depends_on "meson-internal" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.8" => :build
  depends_on "freeglut" => :test
  depends_on "expat"
  depends_on "gettext"

  resource "Mako" do
    url "https://files.pythonhosted.org/packages/72/89/402d2b4589e120ca76a6aed8fee906a0f5ae204b50e455edd36eda6e778d/Mako-1.1.3.tar.gz"
    sha256 "8195c8c1400ceb53496064314c6736719c6f25e7479cd24c77be3d9361cddc27"
  end

  resource "gears.c" do
    url "https://www.opengl.org/archives/resources/code/samples/glut_examples/mesademos/gears.c"
    sha256 "7df9d8cda1af9d0a1f64cc028df7556705d98471fdf3d0830282d4dcfb7a78cc"
  end

  def install
    python3 = Formula["python@3.8"].opt_bin/"python3"
    xy = Language::Python.major_minor_version python3
    ENV.prepend_create_path "PYTHONPATH", buildpath/"vendor/lib/python#{xy}/site-packages"

    resource("Mako").stage do
      system python3, *Language::Python.setup_install_args(buildpath/"vendor")
    end

    resource("gears.c").stage(pkgshare.to_s)

    mkdir "build" do
      system "meson", *std_meson_args, "..", "-Db_ndebug=true",
                      "-Dplatforms=surfaceless", "-Dglx=disabled"
      system "ninja"
      system "ninja", "install"
    end
  end

  test do
    flags = %W[
      -framework OpenGL
      -I#{Formula["freeglut"].opt_include}
      -L#{Formula["freeglut"].opt_lib}
      -lglut
    ]
    system ENV.cc, "#{pkgshare}/gears.c", "-o", "gears", *flags
  end
end
