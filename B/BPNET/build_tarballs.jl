# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "BPNET"
version = v"0.0.2"

# Collection of sources required to complete build
sources = [

    GitSource("https://github.com/cometscome/BPNET.git", "653b739af6b6f4e0b9d588f2483a8142cad57c48a58ea5e870dfaf4a4275a4fd"),
    DirectorySource("./bundled")
]

Dependency(PackageSpec(name="CompilerSupportLibraries_jll", uuid="e66e0078-7015-5450-92f7-15fbd957f2ae"))

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
for f in ${WORKSPACE}/srcdir/patches/*.patch; do
    atomic_patch -p1 ${f}
done
cd BPNET-0.0.2/
mkdir build 
cd build
cmake ..
make
cp ./bin/* ${prefix}/
cp ./lib/* ${prefix}/
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()
platforms = expand_gfortran_versions(platforms)
 

# The products that we will ensure are always built
products = [
    ExecutableProduct("trainbin2ASCII.x", :trainbin2ASCII),
    ExecutableProduct("bpnet_predict.x", :BPNET_predict),
    ExecutableProduct("nnASCII2bin.x", :nnASCII2bin),
    ExecutableProduct("bpnet_generate.x", :BPNET_generate)
]

# Dependencies that must be installed before this package can be built
dependencies = Dependency[
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6", preferred_gcc_version = v"13.2.0")
