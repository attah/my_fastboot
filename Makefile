CXXFLAGS=-std=c++20 -Wno-attributes -Wno-ignored-attributes \
         -Wno-narrowing -Wno-deprecated-declarations

CXXFLAGS+=-I core/fastboot \
          -I mocks \
          -I avb \
          -I core/diagnose_usb/include \
          -I core/fs_mgr/liblp/include \
          -I core/fs_mgr/libstorage_literals \
          -I core/libcutils/include \
          -I core/libsparse/include \
          -I extras/ext4_utils/include \
          -I fmtlib/include \
          -I libbase \
          -I libbase/include \
          -I libziparchive/include \
          -I libziparchive/incfs_support/include \
          -I logging/liblog \
          -I logging/liblog/include \
          -I mkbootimg/include/bootimg

CXXFLAGS+=-DCORE_GIT_REV='"$(shell git describe --tags)"' -D_POSIX_C_SOURCE=200112L -DZLIB_CONST

LDFLAGS = -lssl -lcrypto -lz

MISSING_INCLUDES = -include functional -include iterator

all: fastboot

ifeq ($(findstring clang++,$(CXX)), clang++)
  CXXFLAGS+=-Wno-c99-designator -Wno-inconsistent-missing-override
else ifeq ($(findstring g++,$(CXX)), g++)
  CXXFLAGS+=-D '__builtin_available(X,Y)=false'
endif

fastboot = main.o fastboot.o fastboot_driver.o util.o tcp.o udp.o usb_linux.o \
           bootimg_utils.o vendor_boot_img_utils.o fs.o socket.o super_flash_helper.o \
           storage.o task.o filesystem.o
libbase = file.o strings.o parsenetaddress.o stringprintf.o mapped_file.o logging.o \
          errors_unix.o threads.o posix_strerror_r.o properties.o parsebool.o
diagnose_usb = diagnose_usb.o
ext4_utils = ext4_utils.o ext4_sb.o
fmtlib = format.o
libcutils = sockets.o sockets_unix.o socket_network_client_unix.o socket_inaddr_any_server_unix.o
liblog = liblog_logger_write.o liblog_properties.o
liblp = images.o reader.o writer.o utility.o partition_opener.o super_layout_builder.o builder.o \
        property_fetcher.o
libsparse = sparse.o sparse_read.o backed_block.o output_file.o sparse_crc32.o sparse_err.o
libziparchive = zip_error.o
libziparchive_cc = zip_archive.o zip_cd_entry_map.o

all_objs = $(fastboot) \
           $(libbase) \
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
	$(CXX) -c $(CXXFLAGS) $(MISSING_INCLUDES) $< -o $@

$(libbase): %.o: libbase/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(diagnose_usb): %.o: core/diagnose_usb/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(ext4_utils): %.o: extras/ext4_utils/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(fmtlib): %.o: fmtlib/src/%.cc
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(libcutils): %.o: core/libcutils/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(liblog): liblog_%.o: logging/liblog/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(liblp): %.o: core/fs_mgr/liblp/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(libsparse): %.o: core/libsparse/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(libziparchive): %.o: libziparchive/%.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(libziparchive_cc): %.o: libziparchive/%.cc
	$(CXX) -c $(CXXFLAGS) $< -o $@

fastboot: $(all_objs)
	$(CXX) $^ $(LDFLAGS) -o $@

clean:
	rm -f $(all_objs) fastboot
