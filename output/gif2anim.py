from PIL import Image
import glob
import os
directories = sorted(glob.glob('./*/'))
file_suffix = '_3500-3900MHz'

print(directories)

for dirname in directories:
    files = sorted(glob.glob(dirname+'/*.png'))
    gifanim_filename = './'+dirname.replace('\\','').replace('.','')+file_suffix+'.gif'
    print(gifanim_filename)
    images = list(map(lambda file : Image.open(file) , files))
    images[0].save(gifanim_filename , save_all = True , append_images = images[1:] , duration = 20 , loop = 0)
