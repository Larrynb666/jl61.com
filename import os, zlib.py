import os, zlib

with open(r'C:\Users\Larry\Desktop\jl61.com\jl.61.com\version\version1527756161.swf', 'rb')as f:
    b = f.read()[8:]
    db = zlib.decompress(b)
    print(db[:16])
    with open(r'C:\Users\Larry\Desktop\jl61.com\jl.61.com\version\test-decompress', 'wb')as f:
        f.write(db)