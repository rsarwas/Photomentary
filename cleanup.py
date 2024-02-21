RemoveLeft = """"""

RemoveRight = """"""

import os

for line in RemoveLeft.split("\n"):
    path = line.split("  ===  ")[0]
    path = "/volume1/share/Photos/" + path
    # print("rm ", path)
    try:
        os.remove(path)
    except:
        print(path)

for line in RemoveRight.split("\n"):
    path = line.split("  ===  ")[1]
    path = "/volume1/share/Photos/" + path
    # print("rm ", path)
    try:
        os.remove(path)
    except:
        print(path)
