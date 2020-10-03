CPPFLAGS=-std=c++17 -Wno-attributes -Wno-ignored-attributes
CFLAGS=-I core/fastboot \
       -I . \
       -I mkbootimg/include/bootimg/ \
       -I avb/ \
       -I core/base/include/ \
       -I core/base \
       -I core/diagnose_usb/include/ \
       -I core/fs_mgr/liblp/include/ \
       -I core/libsparse/include/ \
       -I core/libziparchive/include/ \
       -I core/libcutils/include \
       -I core/liblog/include \
       -I core/liblog/ \
       -I extras/ext4_utils/include/
LDFLAGS = -lssl -lcrypto -lz

all: fastboot

fastboot = main.o fastboot.o fastboot_driver.o util.o tcp.o udp.o usb_linux.o bootimg_utils.o fs.o socket.o
base = file.o strings.o parsenetaddress.o stringprintf.o mapped_file.o logging.o liblog_symbols.o errors_unix.o threads.o
diagnose_usb = diagnose_usb.o
libziparchive_cc = zip_archive.o zip_cd_entry_map.o
libziparchive = zip_error.o
libsparse = sparse.o sparse_read.o backed_block.o output_file.o sparse_crc32.o sparse_err.o
liblp = images.o reader.o writer.o utility.o partition_opener.o
libcutils = sockets.o sockets_unix.o socket_network_client_unix.o socket_inaddr_any_server_unix.o
liblog = logger_write.o properties.o
ext4_utils = ext4_utils.o ext4_sb.o

all_objs = $(fastboot) \
           $(base) \
           $(diagnose_usb) \
           $(libziparchive_cc) \
           $(libziparchive) \
           $(libsparse) \
           $(liblp) \
           $(libcutils) \
           $(liblog) \
           $(ext4_utils)

$(fastboot): %.o: core/fastboot/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(base): %.o: core/base/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(diagnose_usb): %.o: core/diagnose_usb/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(liblp): %.o: core/fs_mgr/liblp/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(libsparse): %.o: core/libsparse/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(libziparchive_cc): %.o: core/libziparchive/%.cc
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(libziparchive): %.o: core/libziparchive/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(libcutils): %.o: core/libcutils/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(liblog): %.o: core/liblog/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

$(ext4_utils): %.o: extras/ext4_utils/%.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

fastboot: $(all_objs)
	$(CXX) $^ $(LDFLAGS) -o $@

clean:
	rm -f $(all_objs) fastboot
