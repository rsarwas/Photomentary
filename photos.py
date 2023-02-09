# Create/Analyze a photo list from the H drive

# cd /Volumes/share/Photos
# Delete hidden ds_store files
#  find . -type f -name .DS_Store -delete
# Create a list of files then run through:
#  extension_count(_filename_) to count files by type
#  caption(_filename_) to see the captions automatically generated
# All Files
#  find . -type f  -print > ~/Desktop/all_files.txt
# Photos:
#  find . -type f \( \( -name "*.[J|j]*" -or -name "*.[H|h]*" \) -or \( -name "*.[p|P][n|N]*" -or -name "*.[t|T][i|I]*" \) \) -print > ~/Desktop/photos.txt
# Not Photos:
#  find . -type f -not \( \( -name "*.[J|j]*" -or -name "*.[H|h]*" \) -or \( -name "*.[p|P][n|N]*" -or -name "*.[t|T][i|I]*" \) \) -print  > ~/Desktop/not_photos.txt

# Run the photos.txt file through the following command to remove the leading "./"
#   mv photos.txt photos_orig.txt; sed -e 's!^\./!!g photos_orig > photos.txt
# Then copy photos.txt to the root of the Photomentary repo, to be included with the executable bundle

# Changes to the captioning rules need to be translated to the Swift code in Photomentary

from collections import Counter

def extension_count(filename):
    """
    file input:
    cd /Volumes/share/Photos
    find . -type f \! -name .DS_Store -print > ~/Desktop/photos1.txt
    takes about 260 seconds ~4m20s
    """
    counts = None
    with open(filename) as in_file:
        exts = [line[line.rindex("."):] for line in in_file]
        exts = [ext.strip() for ext in exts]
        counts = Counter(exts)
    print(counts)

def captions(filename):
    def name(path):
        # path = "a/b/c/f.e"
        end = path.rindex("/")

        if "Traci's Web Page" in path:
            return path[7:end]
        
        if path.startswith("./Mom and Dad Slides"):
            return path[2:end].replace("/", " - ")

        if path.startswith("./2002/Spring Mexico Trip/"):
            return path[2:-5].replace("/", " - ")
        
        if path.startswith("./2002/"):
            return path[2:end].replace("/", " - ")

        if path.startswith("./Good Old Pictures/"):
            return path[20:path.rindex(".")]
        
        if path.startswith("./FIrst Day of School/"):
            return path[2:end].replace("/", " - ")

        # typical year folder
        if path.startswith("./19") or path.startswith("./20"):
            start = path.rindex("/", 0, end)
            return path[start+1:end]
        
         # default
        return path[2:path.rindex(".")].replace("/", " - ") 

    names = []
    with open(filename) as in_file:
        names = [name(line) for line in in_file]
        names = sorted(set(names))
    
    for name in names:
        print(name)

captions("/Users/regan/Desktop/photos.txt")
extension_count("/Users/regan/Desktop/photos.txt")