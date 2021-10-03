CXXFLAGS=-std=c++17 -Wno-attributes -Wno-ignored-attributes

CXXFLAGS+=-I core/fastboot \
          -I mocks \
          -I avb/ \
          -I core/diagnose_usb/include/ \
          -I core/fs_mgr/liblp/include/ \
          -I core/fs_mgr/libstorage_literals/ \
          -I core/libcutils/include \
          -I core/libsparse/include/ \
          -I extras/ext4_utils/include/ \
          -I fmtlib/include/ \
          -I libbase \
          -I libbase/include/ \
          -I libziparchive/include/ \
          -I logging/liblog/ \
          -I logging/liblog/include \
          -I mkbootimg/include/bootimg/

CXXFLAGS+=-DCORE_GIT_REV='"$(shell git describe --tags)"'

LDFLAGS = -lssl -lcrypto -lz

all: fastboot

# Exit status is inverse-boolean (already applied is 0)
UNPATCHED := $(shell bash -c "git apply --reverse --check libbase.diff > /dev/null 2>&1"; echo $$?)

ifeq ($(CXX),g++)
  CXXFLAGS+=-D '__builtin_available(X,Y)=false'
	PATCH_NEEDED=$(UNPATCHED)
endif

ifeq ($(CXX),clang++)
  CXXFLAGS+=-Wno-c99-designator
endif

libbase_patch: libbase/logging_splitters.h
ifeq ($(PATCH_NEEDED),1)
	bash -c "git apply libbase.diff"
endif

fastboot = main.o fastboot.o fastboot_driver.o util.o tcp.o udp.o usb_linux.o \
           bootimg_utils.o vendor_boot_img_utils.o fs.o socket.o
base = file.o strings.o parsenetaddress.o stringprintf.o mapped_file.o logging.o errors_unix.o threads.o
diagnose_usb = diagnose_usb.o
ext4_utils = ext4_utils.o ext4_sb.o
fmtlib = format.o
libcutils = sockets.o sockets_unix.o socket_network_client_unix.o socket_inaddr_any_server_unix.o
liblog = logger_write.o properties.o
liblp = images.o reader.o writer.o utility.o partition_opener.o
libsparse = sparse.o sparse_read.o backed_block.o output_file.o sparse_crc32.o sparse_err.o
libziparchive = zip_error.o
libziparchive_cc = zip_archive.o zip_cd_entry_map.o

all_objs = $(fastboot) \
           $(base) \
           $(diagnose_usb) \
           $(ext4_utils) \
           $(fmtlib) \
           $(libcutils) \
           $(liblog) \
           $(liblp) \
           $(libsparse) \
           $(libziparchive) \
           $(libziparchive_cc)

# https://www.gnu.org/software/make/manual/html_node/Static-Usage.html#Static-Usage
# Can't use implicit rules and VPATH here, because there are duplicate names
$(fastboot): %.o: core/fastboot/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(base): %.o: libbase/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(diagnose_usb): %.o: core/diagnose_usb/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(ext4_utils): %.o: extras/ext4_utils/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(fmtlib): %.o: fmtlib/src/%.cc
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(libcutils): %.o: core/libcutils/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(liblog): %.o: logging/liblog/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(liblp): %.o: core/fs_mgr/liblp/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(libsparse): %.o: core/libsparse/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(libziparchive): %.o: libziparchive/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(libziparchive_cc): %.o: libziparchive/%.cc
	$(CXX) -c $(CXXFLAGS) $< -o $@

# Targets after | are run in-order only, this borks $^, but good enough...
fastboot: | libbase_patch $(all_objs)
	$(CXX) $(all_objs) $(LDFLAGS) -o $@

clean:
	rm -f $(all_objs) fastboot
ifeq ($(UNPATCHED),0)
	bash -c "git apply --reverse libbase.diff"
endif
