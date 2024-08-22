import arclib

print(arclib.archive([["hello", None], ["hello/world", b"This is a test file, which is archived using the arc utility."], ["hello/arcu", b"This is the arc archive."]]))
