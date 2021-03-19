CPPFLAGS=-std=c++17 -Wno-attributes -Wno-ignored-attributes -Wno-c99-designator
CFLAGS=-I core/fastboot \
       -I mocks \
       -I mkbootimg/include/bootimg/ \
       -I avb/ \
       -I libbase/include/ \
       -I libbase \
       -I core/diagnose_usb/include/ \
       -I core/fs_mgr/liblp/include/ \
       -I core/libsparse/include/ \
       -I libziparchive/include/ \
       -I core/libcutils/include \
       -I logging/liblog/include \
       -I logging/liblog/ \
       -I extras/ext4_utils/include/ \
       -I core/fs_mgr/libstorage_literals/ \
       -I fmtlib/include/ \
       -DCORE_GIT_REV='"$(shell git -C core rev-parse --short HEAD)"'


ifeq ($(CXX),g++)
  CFLAGS+=-D '__builtin_available(X,Y)=false'
endif

LDFLAGS = -lssl -lcrypto -lz

all: fastboot

fastboot = main.o fastboot.o fastboot_driver.o util.o tcp.o udp.o usb_linux.o bootimg_utils.o vendor_boot_img_utils.o fs.o socket.o
base = file.o strings.o parsenetaddress.o stringprintf.o mapped_file.o logging.o errors_unix.o threads.o
diagnose_usb = diagnose_usb.o
libziparchive_cc = zip_archive.o zip_cd_entry_map.o
libziparchive = zip_error.o
libsparse = sparse.o sparse_read.o backed_block.o output_file.o sparse_crc32.o sparse_err.o
liblp = images.o reader.o writer.o utility.o partition_opener.o
libcutils = sockets.o sockets_unix.o socket_network_client_unix.o socket_inaddr_any_server_unix.o
liblog = logger_write.o properties.o
ext4_utils = ext4_utils.o ext4_sb.o
fmtlib = format.o

all_objs = $(fastboot) \
           $(base) \
           $(diagnose_usb) \
           $(libziparchive_cc) \
           $(libziparchive) \
           $(libsparse) \
           $(liblp) \
           $(libcutils) \
           $(liblog) \
           $(ext4_utils) \
           $(fmtlib)

# https://www.gnu.org/software/make/manual/html_node/Static-Usage.html#Static-Usage
$(fastboot): %.o: core/fastboot/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(base): %.o: libbase/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(base): %.o: libbase/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(diagnose_usb): %.o: core/diagnose_usb/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(liblp): %.o: core/fs_mgr/liblp/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(libsparse): %.o: core/libsparse/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(libziparchive_cc): %.o: libziparchive/%.cc
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(libziparchive): %.o: libziparchive/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(libcutils): %.o: core/libcutils/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(liblog): %.o: logging/liblog/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(ext4_utils): %.o: extras/ext4_utils/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(fmtlib): %.o: fmtlib/src/%.cc
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

fastboot: $(all_objs)
	$(CXX) $^ $(LDFLAGS) -o $@

clean:
	rm -f $(all_objs) fastboot
