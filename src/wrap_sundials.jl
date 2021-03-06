# This file is not an active part of the package. This is the code
# that uses the Clang.jl package to wrap Sundials using the headers.

cd("/home/tshort/tmp/sund")
ENV["JULIAHOME"] = "/home/tshort/julia/jul"

using Clang.wrap_c

if (!has(ENV, "JULIAHOME"))
  error("Please set JULIAHOME variable to the root of your julia install")
end

clang_includes = map(x->joinpath(ENV["JULIAHOME"], x), [
  "deps/llvm-3.2/build/Release/lib/clang/3.2/include",
  "deps/llvm-3.2/include",
  "deps/llvm-3.2/include",
  "deps/llvm-3.2/build/include/",
  "deps/llvm-3.2/include/"
  ])

sundials_names = ["nvector", "sundials", "cvode", "cvodes", "ida", "idas", "kinsol"]
check_use_header(path) = true
for name in sundials_names
    path = joinpath("/usr/local/include/", name)
    headers = map(x->joinpath(path, x),split(readall(`ls $path` | `sort`)) )
    @show headers
    wrap_c.wrap_c_headers(headers, [clang_includes, path], ASCIIString[], check_use_header, "$name.jl")
end
mv("sundials.jl", "libsundials.jl")  # avoid a name conflict for case-insensitive file systems
