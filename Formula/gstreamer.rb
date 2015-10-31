class Gstreamer < Formula
  desc "GStreamer is a development framework for multimedia applications"
  homepage "http://gstreamer.freedesktop.org/"
  url "https://download.gnome.org/sources/gstreamer/1.6/gstreamer-1.6.1.tar.xz"
  sha256 "973a3f213c8d41d6dd0e4e7e38fd6cccacd5ae1ac09e1179a8d5d869ef0a5c9c"

  bottle do
    sha256 "6b75e4ba010fd85957d99abf356da19e4bb991031a5938bcd0c84e0e8ed25b8b" => :el_capitan
    sha256 "370ba64ff63f4d80c445b317a0380afb91c92fd60b45dde385f9ff888975df87" => :yosemite
    sha256 "32f9f7ee8a26494bac8ee4805b8a23569bbb2ab4cfd9779703d0be3ff772e0ae" => :mavericks
  end

  head do
    url "git://anongit.freedesktop.org/gstreamer/gstreamer"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "gobject-introspection"
  depends_on "gettext"
  depends_on "glib"
  depends_on "bison"

  # Fix header file issue (exact OS versions affected unknown; first noticed on
  # Snow Leopard)
  # https://bugzilla.gnome.org/show_bug.cgi?id=756136
  patch :DATA if MacOS.version <= :mountain_lion

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
      --disable-gtk-doc
      --enable-introspection=yes
    ]

    if build.head?
      ENV["NOCONFIGURE"] = "yes"
      system "./autogen.sh"

      # Ban trying to chown to root.
      # https://bugzilla.gnome.org/show_bug.cgi?id=750367
      args << "--with-ptp-helper-permissions=none"
    end

    # Look for plugins in HOMEBREW_PREFIX/lib/gstreamer-1.0 instead of
    # HOMEBREW_PREFIX/Cellar/gstreamer/1.0/lib/gstreamer-1.0, so we'll find
    # plugins installed by other packages without setting GST_PLUGIN_PATH in
    # the environment.
    inreplace "configure", 'PLUGINDIR="$full_var"',
      "PLUGINDIR=\"#{HOMEBREW_PREFIX}/lib/gstreamer-1.0\""

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    system bin/"gst-inspect-1.0"
  end
end
__END__
diff --git a/libs/gst/helpers/gst-ptp-helper.c b/libs/gst/helpers/gst-ptp-helper.c
index 6c753df..5642741 100644
--- a/libs/gst/helpers/gst-ptp-helper.c
+++ b/libs/gst/helpers/gst-ptp-helper.c
@@ -37,6 +37,7 @@
 #include <sys/types.h>
 #include <errno.h>
 #include <sys/ioctl.h>
+#include <sys/socket.h>
 #include <net/if.h>
 #include <netinet/in.h>
 #include <string.h>
