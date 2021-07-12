# disable all implicit make rules
.SUFFIXES:

# if you define "._foo" as a file on this line, then it will zip up a
# folder called foo, adding a standard file into it to make foo.zip.
all:	._copy_snapshots_dest_docdb \
	._delete_old_snapshots_docdb \
	._take_snapshots_docdb

clean:
	rm -f ._*

._%: %.zip
	mv "$<" "zip_files"

# This rule is a BSD make style rule that says "to make foo.zip, call
# 'zip -jqr foo snapshot_tool_utils.py'"
%.zip: %
	zip -jqr "$@" "$<" snapshots_tool_utils.py