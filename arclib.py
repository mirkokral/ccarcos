def archive(filedata: [str, bytes]):
    out = b""
    coffset = 0
    for i in filedata:
        if i[1] is None:
            out += bytes(f"|{i[0]}|-1|\n", "ASCII")
        else:
            out += bytes(f"|{i[0]}|{coffset}|\n", "ASCII")
            coffset += len(i[1])
    out += b"--ENDTABLE\n"
    for i in filedata:
        if i[1]:
            out += i[1]
    return out

        
