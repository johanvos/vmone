JAVA := /opt/java

ifeq ($(strip $(JAVA_HOME)),)
else
    JAVA := $(JAVA_HOME)
endif

ifeq ($(shell uname), Linux)
    INCLUDE_FLAGS=-I$(JAVA)/include -I$(JAVA)/include/linux
    OS := linux
    CC = gcc
    CFLAGS = -D_GNU_SOURCE $(INCLUDE_FLAGS)
else ifeq ($(shell uname), Darwin)
    INCLUDE_FLAGS=-I$(JAVA)/include -I$(JAVA)/include/darwin
    OS := macosx
    CC = gcc
    CFLAGS = $(INCLUDE_FLAGS)
else
    OS := Unknown
endif

ifeq ($(TARGET), ios)
    OS := ios
    CC = clang
    CFLAGS = -arch arm64 \
             -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
             -miphoneos-version-min=12.0 \
             -fobjc-arc \
             -O2 \
             -Wall -Wextra \
             -g \
             -framework Foundation \
             $(INCLUDE_FLAGS)
else ifeq ($(TARGET), android)
else 
endif


SRCDIR = src
DARWIN_SRCDIR = src/darwin
OBJDIR = build
LIBDIR = lib

SRCS = $(wildcard $(SRCDIR)/*.c)
ifeq ($(TARGET), ios)
    SRCS = $(wildcard $(SRCDIR)/*.c) $(wildcard $(DARWIN_SRCDIR)/*.m)
#    SRCS += $(wildcard $(SRCDIR)/darwin/*.m)
    echo "SRCS = $(SRCS)"
endif

#OBJS = $(patsubst %.c,$(OBJDIR)/$(OS)/%.o,$(notdir $(SRCS)))
#OBJS += $(patsubst $(DARWIN_SRCDIR)/%.m,$(OBJDIR)/$(OS)/%.o,$(wildcard $(DARWIN_SRCDIR)/*.m))

OBJS_C = $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/$(OS)/%.o,$(filter %.c,$(SRCS)))
OBJS_M = $(patsubst $(DARWIN_SRCDIR)/%.m,$(OBJDIR)/$(OS)/%.o,$(filter %.m,$(SRCS)))
OBJS = $(OBJS_C) $(OBJS_M)


LIB = $(LIBDIR)/$(OS)/libvmone.a

all: $(LIB)

$(LIB): $(OBJS)
	@echo "OBJS = $(OBJS)"
	@mkdir -p $(LIBDIR)/$(OS)
	ar rcs $@ $^

debug:
	@echo "OS: $(OS)"
	@echo "SRCS: $(SRCS)"
	@echo "OBJS: $(OBJS)"
	@echo "OBJDIR: $(OBJDIR)"


$(OBJDIR)/$(OS)/%.o: $(SRCDIR)/%.c
	echo "Using Java from $(JAVA) and OS = $(OS) and OBJS = $(OBJS)"
	@mkdir -p $(OBJDIR)/$(OS)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/$(OS)/%.o: $(SRCDIR)/darwin/%.m
	@mkdir -p $(OBJDIR)/$(OS)
	$(CC) $(CFLAGS) -c $< -o $@

#$(OBJDIR)/$(OS)/%.o: $(SRCDIR)/darwin/%.m
#@mkdir -p $(OBJDIR)/$(OS)
#$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJDIR) $(LIBDIR) 
