# Create/Analyze a photo list from the H drive

# Create a list of files then run through:
#  extension_count(_filename_) to count files by type
#  caption(_filename_) to see the captions automatically generated
#
# To generate the files, run these commands in a ssh on the server
#   cd /volume1/share/Photos
# Clean up
#   find . -type f -name .DS_Store -delete
#   find . -type d  -name @eaDir -exec rm -rf {} \;
# All Files
#   find . -type f  -print > Tools/all_files.txt
# All Directories
#   find . -type d  -print > Tools/all_dirs.txt
# Photos:
#   find . -type f \( \( \( -name "*.[J|j]*" -or -name "*.[H|h]*" \) -or \( -name "*.[p|P][n|N]*" -or -name "*.[t|T][i|I]*" \) \) -or \( -name "*.bmp" -or -name "*.gif" \) \) -print > Tools/all_photos.txt
# Cleanup the Photos List
#    cd Tools
#    sed '/XHIDEX/d' all_photos.txt | sed -e '/^\.\/Tools/d' | sed -e 's!^\./!!' > photos.txt
# Not Photos:
#   find . -type f -not \( \( \( -name "*.[J|j]*" -or -name "*.[H|h]*" \) -or \( -name "*.[p|P][n|N]*" -or -name "*.[t|T][i|I]*" \) \) -or \( -name "*.bmp" -or -name "*.gif" \) \) -print > Tools/all_not_photos.txt
# Cleanup the Not Photos List
#    ignore these files: .pdf, .psd (photoshop), .xcf (GIMP), .alb (scrapbook album), .sbp (scrapbook page), .pub (Microsoft publisher)
#    cd Tools
#    sed '/.pdf$/d' all_not_photos.txt | sed -e '/^\.\/Tools/d' | sed '/.psd$/d' | sed '/.xcf$/d' | sed '/.alb$/d' | sed '/.sbp$/d' | sed '/.pub$/d' | sort > not_photos.txt

# Review the files for issues and revise the above commands as necessary
# Then copy photos.txt to the root of the Photomentary repo, to be included with the executable bundle

# Changes to the captioning rules need to be translated to the Swift code in Photomentary

from collections import Counter
import os


def extension_count(filename):
    """
    file input: all_files.txt
    On the server run
    cd /volume1/share/Photos
    find . -type f  -print > all_files.txt
    """
    counts = None
    with open(filename) as in_file:
        exts = [line[line.rindex(".") :] for line in in_file]
        exts = [ext.strip() for ext in exts]
        counts = Counter(exts)
    print(counts)


def captions(filename):
    def name(path):

        def named_image(path):
            fname = path[path.rindex("/") + 1 :]
            if (
                fname.startswith("IMG_")
                or fname.startswith("P000")
                or fname.startswith("p_v1")
            ):
                return False
            return True

        # path = "a/b/c/f.e"
        last_slash = path.rindex("/")
        last_dot = path.rindex(".")

        # exceptions to typical year folder
        if (
            (path.startswith("19") or path.startswith("20"))
            and path[4] == "/"
            and path[:4] != path[5:9]
        ):
            if named_image(path):
                return path[:last_dot].replace("/", " - ")
            else:
                return path[:last_slash].replace("/", " - ")

        # 2003/2003-05-03 Florida Day 19 - Discovery Cove/Discovery Cove/Dad Mali Liam Rubbing belly.jpg
        if "/Discovery Cove/" in path:
            path = path.replace("/Discovery Cove/", "/")
            last_dot = path.rindex(".")
            return path[5:last_dot].replace("/", " - ")

        # if "Traci's Web Page" in path:
        #     return path[5:last_slash].replace("/", " - ")
        # if "/Stitch Material/" in path:
        #     path = path.replace("/Stitch Material/", "/")
        #     last_slash = path.rindex("/")
        #     return path[5:last_slash].replace("/", " - ")
        #
        # 2004/2004-09-20 Photos for Traci's Web Page/*/
        # 2003/2003-05-30 View from Wolverine Peak/Stitch Material/
        # 2003/2003-06-10 Regan and Roberts 5 Peaker/Taniana Panorama Source/
        # 2003/2003-06-10 Regan and Roberts 5 Peaker/Knoya Panorama Source/
        # 2003/2003-10-12 Web Page stuff for Traci's Middle Group/I-Graphs/
        # 2003/2003-08-07 Williwaw Hike/Stitch source/
        # typical year folder
        if path.startswith("19") or path.startswith("20"):
            start = path.index("/")
            return path[start + 1 : last_slash].replace("/", " - ")

            # Miscellaneous folders
            # if path.startswith("Collections/Mom and Dad Slides/"):
            #     return path[2:last_slash].replace("/", " - ")

            # if path.startswith("Good Old Pictures/"):
            #     return path[20:last_dot]

            # if path.startswith("First Day of School/"):
            #     return path[:last_slash].replace("/", " - ")

        # default
        if named_image(path):
            return path[:last_dot].replace("/", " - ")
        else:
            return path[:last_slash].replace("/", " - ")

    names = []
    with open(filename) as in_file:
        names = [name(line.strip()) for line in in_file]
        names = sorted(set(names))

    for name in names:
        print(name)


def words(filename):
    """Takes an 'all_dirs.txt file and prints a sorted histogram of the words used in the names.
    the input file is generated with 'find . -type d -print > all_dirs.txt on the server.
    It works better if the all_dirs file is cleaned up first by removing all entries that don't
    stat with /19xx/ or /20xx/ and any other undated subdirectories of those directories.
    """
    counts = Counter()
    with open(filename) as in_file:
        for line in in_file:
            line = line.strip().split(" ", 1)[1]
            line = line.replace("'s", "").replace("!", "").replace(".", "")
            line = line.replace("(", " ").replace(",", " ").replace(")", " ")
            line = line.replace("-", " ")
            words = line.split()
            counts.update(words)
    words = list(counts.keys())
    words.sort()
    for word in words:
        print(f"{word}   {counts[word]}")


def fix_hyphens(path):
    """Replaces the underscore with a dash in the date prefix of folder names below path.
    I.e. 'path/2000_01_01 xxx' becomes 'path/2000-01-01 xxx'."""
    for dirpath, dirnames, _ in os.walk(path):
        # print(dirpath)
        for dirname in dirnames:
            if len(dirname) < 8:
                continue
            if dirname[4] != "_" or dirname[7] != "_":
                continue
            new_dirname = dirname[0:4] + "-" + dirname[5:7] + "-" + dirname[8:]
            old_path = os.path.join(dirpath, dirname)
            new_path = os.path.join(dirpath, new_dirname)
            # print("mv", old_path, new_path)
            os.rename(old_path, new_path)


def rename(old_name_file, new_name_file):
    with open(old_name_file) as from_file:
        old_names = list(from_file)
    with open(new_name_file) as to_file:
        new_names = list(to_file)
    if len(old_names) != len(new_names):
        print("Length of old and new name files is different. Aborting!")
        return
    for i, old_name in enumerate(old_names):
        old_name = old_name.strip()
        new_name = new_names[i].strip()
        if old_name == new_name:
            continue
        print("mv", old_name, new_name)
        # os.rename(old_name, new_name)


captions("Tools/photos.txt")
# extension_count("Tools/photos.txt")
# extension_count("Tools/all_not_photos.txt")
# words("Tools/all_dirs.txt")

# NOTE: The following commands change the file system and must be run from
#       The Photos directory on the server
# fix_hyphens("/volume1/share/Photos")
# rename("Tools/all_dirs.txt", "Tools/all_dirs_fixed.txt")
